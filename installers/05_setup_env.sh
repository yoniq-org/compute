#!/bin/bash

# Script: 05_setup_env.sh
# Purpose: Create ML virtual environment and set up environment variables
# Usage: source ./installers/05_setup_env.sh [--auto] [--refresh-activation] [ENV_NAME|1-118]
# --refresh-activation updates only generated architecture settings in an existing environment.
# Hardware recipe environments use env_h200-* or env_rtxpro6k-*.
# Menus sort by environment type, with Custom (uv) and Custom (pip) last.
# Catalogs retain recipe-referenced environments plus the two Custom environments.

WORKSPACE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"

# Source bashrc to ensure environment is properly loaded
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_command() { echo -e "${BLUE}[RUN]${NC} $1"; }

TORCH_CUDA_ARCH_BANNER="echo \"  - TORCH_CUDA_ARCH_LIST: \${TORCH_CUDA_ARCH_LIST:-unset}\""

fail_script() {
    local message="$1"
    print_error "$message"
    if [ "$BEING_SOURCED" = false ]; then
        exit 1
    else
        return 1
    fi
}

run_env_uv_pip_install() {
    local cmd=(uv pip install)
    cmd+=("$@")

    print_command "VIRTUAL_ENV=$ENV_PATH PATH=$ENV_PATH/bin:\$PATH $(printf '%q ' "${cmd[@]}")"
    VIRTUAL_ENV="$ENV_PATH" PATH="$ENV_PATH/bin:$PATH" "${cmd[@]}"
}

run_env_pip_install() {
    local cmd=(python -m pip install)
    cmd+=("$@")

    print_command "VIRTUAL_ENV=$ENV_PATH PATH=$ENV_PATH/bin:\$PATH $(printf '%q ' "${cmd[@]}")"
    VIRTUAL_ENV="$ENV_PATH" PATH="$ENV_PATH/bin:$PATH" "${cmd[@]}"
}

uses_pip_venv() {
    case "$ENV_TYPE" in
        h200-nanbeige-vllm|h200-zyphra-legacy-vllm|h200-zyphra-vllm|custom_pip)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

environment_is_usable() {
    [ -f "$ENV_PATH/pyvenv.cfg" ] || return 1
    [ -x "$ENV_PATH/bin/python" ] || return 1
    "$ENV_PATH/bin/python" -c 'import sys' >/dev/null 2>&1 || return 1

    if ! uses_pip_venv; then
        [ -x "$ENV_PATH/bin/python3" ] || return 1
    fi
}

install_huggingface_hub() {
    print_info "Installing Hugging Face Hub Python library into $ENV_NAME..."
    if uses_pip_venv; then
        run_env_pip_install -U pip huggingface_hub || return 1
    else
        run_env_uv_pip_install -U huggingface_hub || return 1
    fi

    VIRTUAL_ENV="$ENV_PATH" PATH="$ENV_PATH/bin:$PATH" python - <<'PY' || return 1
from importlib.metadata import version
import shutil

import huggingface_hub

print(f"huggingface_hub {version('huggingface_hub')} installed")
if shutil.which("hf") is None:
    raise SystemExit("hf CLI was not found on PATH")
PY

    VIRTUAL_ENV="$ENV_PATH" PATH="$ENV_PATH/bin:$PATH" hf --help >/dev/null || return 1
    print_info "✓ Hugging Face Hub Python library and hf CLI installed"
}

refresh_activation_script() {
    local activation_script="$ENV_PATH/activate_ml"
    if [ ! -f "$activation_script" ]; then
        print_error "Generated activation script not found: $activation_script"
        return 1
    fi

    python3 -I -S -B - "$activation_script" "$TORCH_CUDA_ARCH_BANNER" <<'PY'
import os
from pathlib import Path
import re
import sys
import tempfile

path = Path(sys.argv[1])
banner = sys.argv[2]
if path.is_symlink():
    raise SystemExit(f"Refusing to replace a symbolic-link activation script: {path}")
original = path.read_bytes().decode("utf-8")
if not original.startswith("#!/bin/bash\n# Activate virtual environment\n"):
    raise SystemExit(f"Unrecognized generated activation script: {path}")

updated = re.sub(
    r'^# GPU architecture for PyTorch\n'
    r'(?:export TORCH_CUDA_ARCH_LIST=(?:"[0-9]+\.[0-9]+"|[0-9]+\.[0-9]+)\n)?\n',
    "",
    original,
    flags=re.MULTILINE,
)
updated = re.sub(
    r'^echo[ \t]+(?:"[ \t]*- TORCH_CUDA_ARCH_LIST: [0-9]+\.[0-9]+"'
    r'|- TORCH_CUDA_ARCH_LIST: [0-9]+\.[0-9]+)\n',
    "",
    updated,
    flags=re.MULTILINE,
)
updated = re.sub(r'^[ \t]*#[ \t]*shellcheck\b[^\n]*(?:\n|$)', "", updated, flags=re.MULTILINE)
updated = updated.replace(banner + "\n", "")
if "TORCH_CUDA_ARCH_LIST" in updated:
    raise SystemExit(f"Unrecognized architecture configuration; leaving unchanged: {path}")

python_banner = 'echo "  - Python: $(python --version)"\n'
if updated.count(python_banner) != 1:
    raise SystemExit(f"Unrecognized activation reporting section; leaving unchanged: {path}")
updated = updated.replace(python_banner, banner + "\n" + python_banner, 1)
if updated == original:
    print(f"Activation architecture policy is already current: {path}")
    raise SystemExit(0)

metadata = path.stat()
temporary_path = None
try:
    with tempfile.NamedTemporaryFile(
        mode="wb", prefix=".activate_ml.", dir=path.parent, delete=False
    ) as temporary:
        temporary_path = Path(temporary.name)
        temporary.write(updated.encode("utf-8"))
        os.fchown(temporary.fileno(), metadata.st_uid, metadata.st_gid)
        os.fchmod(temporary.fileno(), metadata.st_mode & 0o7777)
    os.replace(temporary_path, path)
finally:
    if temporary_path is not None:
        temporary_path.unlink(missing_ok=True)
print(f"Refreshed activation architecture policy: {path}")
PY
}

resolve_env_type() {
    local input="${1#env_}"

    case "$input" in
        1|h200_allenai_vllm|h200-allenai-vllm)
            echo "h200-allenai-vllm"
            ;;
        2|h200_arcee_nvfp4_vllm|h200-arcee-nvfp4-vllm)
            echo "h200-arcee-nvfp4-vllm"
            ;;
        3|h200_arcee_vllm|h200-arcee-vllm)
            echo "h200-arcee-vllm"
            ;;
        4|h200_arcee_vllm_pr_54479|h200-arcee-vllm-pr-54479)
            echo "h200-arcee-vllm-pr-54479"
            ;;
        5|h200_arcee_vllm_pr_54479_fp8_block|h200-arcee-vllm-pr-54479-fp8-block)
            echo "h200-arcee-vllm-pr-54479-fp8-block"
            ;;
        6|h200_arcee_vllm_pr_54479_thinking_fp8_block|h200-arcee-vllm-pr-54479-thinking-fp8-block)
            echo "h200-arcee-vllm-pr-54479-thinking-fp8-block"
            ;;
        7|h200_cohere_vllm|h200-cohere-vllm)
            echo "h200-cohere-vllm"
            ;;
        8|h200_cohere_vllm_pr_54479|h200-cohere-vllm-pr-54479)
            echo "h200-cohere-vllm-pr-54479"
            ;;
        9|h200_datalab_vllm|h200-datalab-vllm)
            echo "h200-datalab-vllm"
            ;;
        10|h200_deepseek_sglang|h200-deepseek-sglang)
            echo "h200-deepseek-sglang"
            ;;
        11|h200_deepseek_v41_vllm_e77daef89|h200-deepseek-v41-vllm-e77daef89)
            echo "h200-deepseek-v41-vllm-e77daef89"
            ;;
        12|h200_deepseek_vision_sglang_pr_37253|h200-deepseek-vision-sglang-pr-37253)
            echo "h200-deepseek-vision-sglang-pr-37253"
            ;;
        13|h200_deepseek_vision_vllm_pr_54566|h200-deepseek-vision-vllm-pr-54566)
            echo "h200-deepseek-vision-vllm-pr-54566"
            ;;
        14|h200_deepseek_vllm|h200-deepseek-vllm)
            echo "h200-deepseek-vllm"
            ;;
        15|h200_diffusiongemma_sglang|h200-diffusiongemma-sglang)
            echo "h200-diffusiongemma-sglang"
            ;;
        16|h200_gemma_sglang|h200-gemma-sglang)
            echo "h200-gemma-sglang"
            ;;
        17|h200_gemma_vllm|h200-gemma-vllm|h200_gemma4_vllm|h200-gemma4-vllm|h200_gemma_4_vllm|h200-gemma-4-vllm)
            echo "h200-gemma-vllm"
            ;;
        18|h200_gemma3n_vllm|h200-gemma3n-vllm)
            echo "h200-gemma3n-vllm"
            ;;
        19|h200_glm53_vllm_v0290|h200-glm53-vllm-v0290)
            echo "h200-glm53-vllm-v0290"
            ;;
        20|h200_glm53flash_dflash2_sglang_pr_37818|h200-glm53flash-dflash2-sglang-pr-37818)
            echo "h200-glm53flash-dflash2-sglang-pr-37818"
            ;;
        21|h200_glm53flash_dflash2_vllm_pr_55423|h200-glm53flash-dflash2-vllm-pr-55423)
            echo "h200-glm53flash-dflash2-vllm-pr-55423"
            ;;
        22|h200_glm53flash_vllm_pr_53906|h200-glm53flash-vllm-pr-53906)
            echo "h200-glm53flash-vllm-pr-53906"
            ;;
        23|h200_gpt_oss_sglang|h200_gptoss_sglang|h200_gpt-oss_sglang|h200-gptoss-sglang|h200-gpt-oss-sglang)
            echo "h200-gpt-oss-sglang"
            ;;
        24|h200_gpt_oss_vllm|h200_gptoss_vllm|h200_gpt-oss_vllm|h200_vllm_gptoss|h200-gptoss-vllm|h200-gpt-oss-vllm)
            echo "h200-gpt-oss-vllm"
            ;;
        25|h200_ibm_sglang|h200-ibm-sglang)
            echo "h200-ibm-sglang"
            ;;
        26|h200_ibm_vllm|h200-ibm-vllm)
            echo "h200-ibm-vllm"
            ;;
        27|h200_inclusionai_ling3_vllm|h200-inclusionai-ling3-vllm)
            echo "h200-inclusionai-ling3-vllm"
            ;;
        28|h200_inclusionai_sglang|h200-inclusionai-sglang)
            echo "h200-inclusionai-sglang"
            ;;
        29|h200_inclusionai_vllm|h200-inclusionai-vllm)
            echo "h200-inclusionai-vllm"
            ;;
        30|h200_incoai_sglang|h200-incoai-sglang)
            echo "h200-incoai-sglang"
            ;;
        31|h200_incoai_vllm|h200-incoai-vllm)
            echo "h200-incoai-vllm"
            ;;
        32|h200_intel_sglang|h200-intel-sglang)
            echo "h200-intel-sglang"
            ;;
        33|h200_intel_vllm|h200-intel-vllm)
            echo "h200-intel-vllm"
            ;;
        34|h200_liquidai_sglang|h200-liquidai-sglang)
            echo "h200-liquidai-sglang"
            ;;
        35|h200_liquidai_sglang_pr_31041|h200-liquidai-sglang-pr-31041)
            echo "h200-liquidai-sglang-pr-31041"
            ;;
        36|h200_liquidai_vllm|h200-liquidai-vllm)
            echo "h200-liquidai-vllm"
            ;;
        37|h200_meta_sglang|h200-meta-sglang)
            echo "h200-meta-sglang"
            ;;
        38|h200_meta_vllm|h200-meta-vllm)
            echo "h200-meta-vllm"
            ;;
        39|h200_microsoft_vllm|h200-microsoft-vllm)
            echo "h200-microsoft-vllm"
            ;;
        40|h200_minimax_m2_sglang_v0510_post1|h200-minimax-m2-sglang-v0510-post1)
            echo "h200-minimax-m2-sglang-v0510-post1"
            ;;
        41|h200_minimax_m2_vllm_0f3ce4c74|h200-minimax-m2-vllm-0f3ce4c74)
            echo "h200-minimax-m2-vllm-0f3ce4c74"
            ;;
        42|h200_minimax_m25_vllm_v0280|h200-minimax-m25-vllm-v0280)
            echo "h200-minimax-m25-vllm-v0280"
            ;;
        43|h200_mistralai_sglang|h200-mistralai-sglang)
            echo "h200-mistralai-sglang"
            ;;
        44|h200_mistralai_vllm|h200-mistralai-vllm)
            echo "h200-mistralai-vllm"
            ;;
        45|h200_nanbeige_sglang|h200-nanbeige-sglang)
            echo "h200-nanbeige-sglang"
            ;;
        46|h200_nanbeige_vllm|h200-nanbeige-vllm)
            echo "h200-nanbeige-vllm"
            ;;
        47|h200_nemotron_ultra_vllm_9c2d21046|h200-nemotron-ultra-vllm-9c2d21046)
            echo "h200-nemotron-ultra-vllm-9c2d21046"
            ;;
        48|h200_nex_n2_sglang_v0519|h200-nex-n2-sglang-v0519)
            echo "h200-nex-n2-sglang-v0519"
            ;;
        49|h200_nex_n2_vllm_v0290|h200-nex-n2-vllm-v0290)
            echo "h200-nex-n2-vllm-v0290"
            ;;
        50|h200_nvidia_deepseek_sglang|h200-nvidia-deepseek-sglang)
            echo "h200-nvidia-deepseek-sglang"
            ;;
        51|h200_nvidia_glm53_sglang_26fd7fd|h200-nvidia-glm53-sglang-26fd7fd)
            echo "h200-nvidia-glm53-sglang-26fd7fd"
            ;;
        52|h200_nvidia_muse_sglang_v0520|h200-nvidia-muse-sglang-v0520)
            echo "h200-nvidia-muse-sglang-v0520"
            ;;
        53|h200_nvidia_muse_vllm_v0290|h200-nvidia-muse-vllm-v0290)
            echo "h200-nvidia-muse-vllm-v0290"
            ;;
        54|h200_nvidia_nemotron|h200-nvidia-nemotron)
            echo "h200-nvidia-nemotron"
            ;;
        55|h200_nvidia_sglang|h200-nvidia-sglang)
            echo "h200-nvidia-sglang"
            ;;
        56|h200_nvidia_sglang_pr_33554|h200-nvidia-sglang-pr-33554)
            echo "h200-nvidia-sglang-pr-33554"
            ;;
        57|h200_nvidia_vllm|h200-nvidia-vllm)
            echo "h200-nvidia-vllm"
            ;;
        58|h200_nvidia_vllm_pr_55222|h200-nvidia-vllm-pr-55222)
            echo "h200-nvidia-vllm-pr-55222"
            ;;
        59|h200_openai_sglang_pr_38626|h200-openai-sglang-pr-38626)
            echo "h200-openai-sglang-pr-38626"
            ;;
        60|h200_openai_vllm_pr_53207|h200-openai-vllm-pr-53207)
            echo "h200-openai-vllm-pr-53207"
            ;;
        61|h200_paradigma_inc_vllm_v0260|h200-paradigma-inc-vllm-v0260)
            echo "h200-paradigma-inc-vllm-v0260"
            ;;
        62|h200_poolside_laguna_xs_vllm|h200-poolside-laguna-xs-vllm)
            echo "h200-poolside-laguna-xs-vllm"
            ;;
        63|h200_poolside_sglang|h200-poolside-sglang)
            echo "h200-poolside-sglang"
            ;;
        64|h200_poolside_vllm|h200-poolside-vllm)
            echo "h200-poolside-vllm"
            ;;
        65|h200_primeintellect_sglang|h200-primeintellect-sglang)
            echo "h200-primeintellect-sglang"
            ;;
        66|h200_primeintellect_vllm|h200-primeintellect-vllm)
            echo "h200-primeintellect-vllm"
            ;;
        67|h200_qwen_flash_next_sglang|h200-qwen-flash-next-sglang)
            echo "h200-qwen-flash-next-sglang"
            ;;
        68|h200_qwen_flash_next_vllm|h200-qwen-flash-next-vllm)
            echo "h200-qwen-flash-next-vllm"
            ;;
        69|h200_qwen_flash_next_vllm_pr_54129|h200-qwen-flash-next-vllm-pr-54129)
            echo "h200-qwen-flash-next-vllm-pr-54129"
            ;;
        70|h200_qwen_sglang|h200-qwen-sglang)
            echo "h200-qwen-sglang"
            ;;
        71|h200_qwen_sglang_pr_22121|h200-qwen-sglang-pr-22121)
            echo "h200-qwen-sglang-pr-22121"
            ;;
        72|h200_qwen_vllm|h200-qwen-vllm)
            echo "h200-qwen-vllm"
            ;;
        73|h200_radixark_qwen_sglang|h200-radixark-qwen-sglang)
            echo "h200-radixark-qwen-sglang"
            ;;
        74|h200_radixark_sglang|h200-radixark-sglang)
            echo "h200-radixark-sglang"
            ;;
        75|h200_redhat_sglang_pr_35809|h200-redhat-sglang-pr-35809)
            echo "h200-redhat-sglang-pr-35809"
            ;;
        76|h200_redhatai_sglang|h200-redhatai-sglang)
            echo "h200-redhatai-sglang"
            ;;
        77|h200_redhatai_vllm|h200-redhatai-vllm)
            echo "h200-redhatai-vllm"
            ;;
        78|h200_stepfun_sglang|h200-stepfun-sglang)
            echo "h200-stepfun-sglang"
            ;;
        79|h200_stepfun_vllm|h200-stepfun-vllm)
            echo "h200-stepfun-vllm"
            ;;
        80|h200_xiaomimimo_flash_vllm_1ea7c63|h200-xiaomimimo-flash-vllm-1ea7c63)
            echo "h200-xiaomimimo-flash-vllm-1ea7c63"
            ;;
        81|h200_xiaomimimo_sglang_v0520|h200-xiaomimimo-sglang-v0520)
            echo "h200-xiaomimimo-sglang-v0520"
            ;;
        82|h200_xiaomimimo_vllm_v0300|h200-xiaomimimo-vllm-v0300)
            echo "h200-xiaomimimo-vllm-v0300"
            ;;
        83|h200_z_lab_sglang|h200-z-lab-sglang)
            echo "h200-z-lab-sglang"
            ;;
        84|h200_z_lab_sglang_pr_35209|h200-z-lab-sglang-pr-35209)
            echo "h200-z-lab-sglang-pr-35209"
            ;;
        85|h200_z_lab_vllm|h200-z-lab-vllm)
            echo "h200-z-lab-vllm"
            ;;
        86|h200_zyphra_legacy_vllm|h200-zyphra-legacy-vllm)
            echo "h200-zyphra-legacy-vllm"
            ;;
        87|h200_zyphra_sglang|h200-zyphra-sglang)
            echo "h200-zyphra-sglang"
            ;;
        88|h200_zyphra_sglang_pr_32517|h200-zyphra-sglang-pr-32517)
            echo "h200-zyphra-sglang-pr-32517"
            ;;
        89|h200_zyphra_vllm|h200-zyphra-vllm)
            echo "h200-zyphra-vllm"
            ;;
        90|rtxpro6k_allenai_vllm_73a5831127a9|rtxpro6k-allenai-vllm-73a5831127a9)
            echo "rtxpro6k-allenai-vllm-73a5831127a9"
            ;;
        91|rtxpro6k_allenai_vllm_73a78e6f1f38|rtxpro6k-allenai-vllm-73a78e6f1f38)
            echo "rtxpro6k-allenai-vllm-73a78e6f1f38"
            ;;
        92|rtxpro6k_arcee_ai_vllm_73a5831127a9|rtxpro6k-arcee-ai-vllm-73a5831127a9)
            echo "rtxpro6k-arcee-ai-vllm-73a5831127a9"
            ;;
        93|rtxpro6k_arcee_ai_vllm_c8414a82712b|rtxpro6k-arcee-ai-vllm-c8414a82712b)
            echo "rtxpro6k-arcee-ai-vllm-c8414a82712b"
            ;;
        94|rtxpro6k_coherelabs_vllm_73a5831127a9|rtxpro6k-coherelabs-vllm-73a5831127a9)
            echo "rtxpro6k-coherelabs-vllm-73a5831127a9"
            ;;
        95|rtxpro6k_datalab_to_vllm_73a5831127a9|rtxpro6k-datalab-to-vllm-73a5831127a9)
            echo "rtxpro6k-datalab-to-vllm-73a5831127a9"
            ;;
        96|rtxpro6k_deepseek_v41_vllm_pr_56509|rtxpro6k-deepseek-v41-vllm-pr-56509)
            echo "rtxpro6k-deepseek-v41-vllm-pr-56509"
            ;;
        97|rtxpro6k_glm53_vllm_2617fe938|rtxpro6k-glm53-vllm-2617fe938)
            echo "rtxpro6k-glm53-vllm-2617fe938"
            ;;
        98|rtxpro6k_google_sglang_1093c501dfef|rtxpro6k-google-sglang-1093c501dfef)
            echo "rtxpro6k-google-sglang-1093c501dfef"
            ;;
        99|rtxpro6k_incoai_sglang_964c45cf3|rtxpro6k-incoai-sglang-964c45cf3)
            echo "rtxpro6k-incoai-sglang-964c45cf3"
            ;;
        100|rtxpro6k_incoai_sglang_pr_028ac64f7|rtxpro6k-incoai-sglang-pr-028ac64f7)
            echo "rtxpro6k-incoai-sglang-pr-028ac64f7"
            ;;
        101|rtxpro6k_incoai_vllm_73a583112|rtxpro6k-incoai-vllm-73a583112)
            echo "rtxpro6k-incoai-vllm-73a583112"
            ;;
        102|rtxpro6k_incoai_vllm_pr_417b0b6aa|rtxpro6k-incoai-vllm-pr-417b0b6aa)
            echo "rtxpro6k-incoai-vllm-pr-417b0b6aa"
            ;;
        103|rtxpro6k_intel_sglang|rtxpro6k-intel-sglang)
            echo "rtxpro6k-intel-sglang"
            ;;
        104|rtxpro6k_liquidai_sglang|rtxpro6k-liquidai-sglang)
            echo "rtxpro6k-liquidai-sglang"
            ;;
        105|rtxpro6k_liquidai_sglang_pr_31041|rtxpro6k-liquidai-sglang-pr-31041)
            echo "rtxpro6k-liquidai-sglang-pr-31041"
            ;;
        106|rtxpro6k_nanbeige_sglang|rtxpro6k-nanbeige-sglang)
            echo "rtxpro6k-nanbeige-sglang"
            ;;
        107|rtxpro6k_nvidia_glm53_sglang_26fd7fd|rtxpro6k-nvidia-glm53-sglang-26fd7fd)
            echo "rtxpro6k-nvidia-glm53-sglang-26fd7fd"
            ;;
        108|rtxpro6k_nvidia_glm53flash_sglang_pr_38430|rtxpro6k-nvidia-glm53flash-sglang-pr-38430)
            echo "rtxpro6k-nvidia-glm53flash-sglang-pr-38430"
            ;;
        109|rtxpro6k_nvidia_qwen38_vllm_9c2d21046|rtxpro6k-nvidia-qwen38-vllm-9c2d21046)
            echo "rtxpro6k-nvidia-qwen38-vllm-9c2d21046"
            ;;
        110|rtxpro6k_nvidia_sglang_964c45cf3|rtxpro6k-nvidia-sglang-964c45cf3)
            echo "rtxpro6k-nvidia-sglang-964c45cf3"
            ;;
        111|rtxpro6k_nvidia_vllm_pr_39e0ce172|rtxpro6k-nvidia-vllm-pr-39e0ce172)
            echo "rtxpro6k-nvidia-vllm-pr-39e0ce172"
            ;;
        112|rtxpro6k_primeintellect_sglang|rtxpro6k-primeintellect-sglang)
            echo "rtxpro6k-primeintellect-sglang"
            ;;
        113|rtxpro6k_qwen_flash_next_vllm|rtxpro6k-qwen-flash-next-vllm)
            echo "rtxpro6k-qwen-flash-next-vllm"
            ;;
        114|rtxpro6k_qwen_flash_next_vllm_pr_54129|rtxpro6k-qwen-flash-next-vllm-pr-54129)
            echo "rtxpro6k-qwen-flash-next-vllm-pr-54129"
            ;;
        115|rtxpro6k_qwen_sglang|rtxpro6k-qwen-sglang)
            echo "rtxpro6k-qwen-sglang"
            ;;
        116|rtxpro6k_xiaomimimo_flash_vllm_pr_58177|rtxpro6k-xiaomimimo-flash-vllm-pr-58177)
            echo "rtxpro6k-xiaomimimo-flash-vllm-pr-58177"
            ;;
        117|custom|custom_uv|custom-uv|env_custom_uv)
            echo "custom_uv"
            ;;
        118|custom_pip|custom-pip|env_custom_pip)
            echo "custom_pip"
            ;;
        *)
            return 1
            ;;
    esac
}

resolve_env_name() {
    local env_type="${1#env_}"

    if [ -z "$env_type" ]; then
        env_type="custom_uv"
    fi

    echo "env_$env_type"
}

CUDA_CANDIDATE_VERSIONS=()
CUDA_CANDIDATE_HOMES=()
SELECTED_CUDA_MODE=""
SELECTED_CUDA_HOME=""
SELECTED_CUDA_VERSION=""

cuda_home_is_valid() {
    local cuda_home="$1"

    [ -n "$cuda_home" ] || return 1
    cuda_home="${cuda_home%/}"
    [ -d "$cuda_home" ] || return 1
    [ -x "$cuda_home/bin/nvcc" ] || return 1
}

cuda_version_for_home() {
    local cuda_home="$1"

    cuda_home="${cuda_home%/}"
    if ! cuda_home_is_valid "$cuda_home"; then
        echo ""
        return 1
    fi

    "$cuda_home/bin/nvcc" --version 2>/dev/null | sed -n 's/.*release \([0-9][0-9]*\.[0-9][0-9]*\).*/\1/p' | head -1
}

detect_bashrc_cuda_home() {
    local candidates=()
    local nvcc_path=""

    candidates+=("/usr/local/cuda")
    if [ -n "${CUDA_HOME:-}" ]; then
        candidates+=("$CUDA_HOME")
    fi
    if [ -n "${CUDA_PATH:-}" ]; then
        candidates+=("$CUDA_PATH")
    fi
    if nvcc_path=$(command -v nvcc 2>/dev/null); then
        candidates+=("$(cd -- "$(dirname -- "$nvcc_path")/.." && pwd)")
    fi

    local candidate
    local seen=":"
    for candidate in "${candidates[@]}"; do
        [ -n "$candidate" ] || continue
        candidate="${candidate%/}"
        case "$seen" in
            *":$candidate:"*) continue ;;
        esac
        seen+="$candidate:"

        if cuda_home_is_valid "$candidate"; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

collect_cuda_candidates() {
    CUDA_CANDIDATE_VERSIONS=()
    CUDA_CANDIDATE_HOMES=()

    local candidate_lines=()
    local cuda_dir
    for cuda_dir in /usr/local/cuda-*; do
        [ -d "$cuda_dir" ] || continue

        local dir_version=${cuda_dir##*/cuda-}
        [[ "$dir_version" =~ ^[0-9]+(\.[0-9]+){1,3}$ ]] || continue
        cuda_home_is_valid "$cuda_dir" || continue

        local actual_version
        actual_version=$(cuda_version_for_home "$cuda_dir")
        if [ -n "$actual_version" ]; then
            candidate_lines+=("${actual_version}	${cuda_dir}")
        fi
    done

    [ ${#candidate_lines[@]} -gt 0 ] || return 0

    local version
    local path
    while IFS=$'\t' read -r version path; do
        if [ -n "$version" ] && [ -n "$path" ]; then
            CUDA_CANDIDATE_VERSIONS+=("$version")
            CUDA_CANDIDATE_HOMES+=("$path")
        fi
    done < <(printf "%s\n" "${candidate_lines[@]}" | awk '!seen[$1]++' | sort -V -k1,1)
}

select_cuda_for_env() {
    collect_cuda_candidates

    local bashrc_cuda_home=""
    local bashrc_cuda_version=""
    if bashrc_cuda_home=$(detect_bashrc_cuda_home); then
        bashrc_cuda_version=$(cuda_version_for_home "$bashrc_cuda_home")
    fi

    if [ -z "$bashrc_cuda_home" ] && [ ${#CUDA_CANDIDATE_HOMES[@]} -eq 0 ]; then
        fail_script "No CUDA toolkit detected. Install CUDA first with ./installers/02_install_cuda.sh before setting up an ML environment."
        return 1
    fi

    if [ "$AUTO_MODE" = true ]; then
        if [ -n "$bashrc_cuda_home" ]; then
            SELECTED_CUDA_MODE="bashrc"
            SELECTED_CUDA_HOME=""
            SELECTED_CUDA_VERSION="$bashrc_cuda_version"
            print_info "Auto mode: using default bashrc CUDA for $ENV_NAME (CUDA $SELECTED_CUDA_VERSION at $bashrc_cuda_home)"
        else
            local last_index=$(( ${#CUDA_CANDIDATE_HOMES[@]} - 1 ))
            SELECTED_CUDA_MODE="explicit"
            SELECTED_CUDA_HOME="${CUDA_CANDIDATE_HOMES[$last_index]}"
            SELECTED_CUDA_VERSION="${CUDA_CANDIDATE_VERSIONS[$last_index]}"
            print_info "Auto mode: using CUDA $SELECTED_CUDA_VERSION for $ENV_NAME ($SELECTED_CUDA_HOME)"
        fi
        return 0
    fi

    echo ""
    print_info "Select CUDA toolkit for environment '$ENV_NAME':"

    local option_modes=()
    local option_homes=()
    local option_versions=()
    local option=1

    if [ -n "$bashrc_cuda_home" ]; then
        echo "  $option) Use default bashrc CUDA (CUDA $bashrc_cuda_version at $bashrc_cuda_home)"
        option_modes+=("bashrc")
        option_homes+=("")
        option_versions+=("$bashrc_cuda_version")
        option=$((option + 1))
    fi

    local index
    for index in "${!CUDA_CANDIDATE_HOMES[@]}"; do
        echo "  $option) CUDA ${CUDA_CANDIDATE_VERSIONS[$index]} - ${CUDA_CANDIDATE_HOMES[$index]}"
        option_modes+=("explicit")
        option_homes+=("${CUDA_CANDIDATE_HOMES[$index]}")
        option_versions+=("${CUDA_CANDIDATE_VERSIONS[$index]}")
        option=$((option + 1))
    done

    local max_choice=${#option_modes[@]}
    local cuda_choice=""
    read -r -p "Enter choice (1-$max_choice): " cuda_choice
    while ! [[ "$cuda_choice" =~ ^[0-9]+$ ]] || [ "$cuda_choice" -lt 1 ] || [ "$cuda_choice" -gt "$max_choice" ]; do
        read -r -p "Please enter a number from 1 to $max_choice: " cuda_choice
    done

    local selected_index=$((cuda_choice - 1))
    SELECTED_CUDA_MODE="${option_modes[$selected_index]}"
    SELECTED_CUDA_HOME="${option_homes[$selected_index]}"
    SELECTED_CUDA_VERSION="${option_versions[$selected_index]}"

    if [ "$SELECTED_CUDA_MODE" = "bashrc" ]; then
        print_info "Environment '$ENV_NAME' will use the default bashrc CUDA (CUDA $SELECTED_CUDA_VERSION)."
    else
        print_info "Environment '$ENV_NAME' will use CUDA $SELECTED_CUDA_VERSION at $SELECTED_CUDA_HOME."
    fi
}

write_cuda_env_config() {
    cat > "$ENV_PATH/.cuda_env" << EOF
# CUDA toolkit selection for this ML environment.
CUDA_ENV_MODE="$SELECTED_CUDA_MODE"
CUDA_ENV_HOME="$SELECTED_CUDA_HOME"
CUDA_ENV_VERSION="$SELECTED_CUDA_VERSION"
EOF
}

# Check if being sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    BEING_SOURCED=true
else
    BEING_SOURCED=false
fi

# Parse arguments
AUTO_MODE=false
REFRESH_ACTIVATION=false
ENV_TYPE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --auto)
            AUTO_MODE=true
            shift
            ;;
        --refresh-activation)
            REFRESH_ACTIVATION=true
            AUTO_MODE=true
            shift
            ;;
        -*)
            fail_script "Unknown option: $1"
            if [ "$BEING_SOURCED" = true ]; then
                return 1
            fi
            ;;
        *)
            if [ -n "$ENV_TYPE" ]; then
                fail_script "Only one environment may be specified."
                if [ "$BEING_SOURCED" = true ]; then
                    return 1
                fi
            fi
            ENV_TYPE="$1"
            shift
            ;;
    esac
done

if [ "$REFRESH_ACTIVATION" = true ] && [ -z "$ENV_TYPE" ]; then
    fail_script "--refresh-activation requires an existing environment name or number."
    if [ "$BEING_SOURCED" = true ]; then
        return 1
    fi
fi

# Prompt for environment type if not provided and not in auto mode
if [ -z "$ENV_TYPE" ] && [ "$AUTO_MODE" = false ]; then
    echo ""
    print_info "Select ML environment type:"
    echo "1) H200 AllenAI (vLLM)"
    echo "2) H200 Arcee NVFP4 (vLLM)"
    echo "3) H200 Arcee (vLLM)"
    echo "4) H200 Arcee (vLLM) PR 54479"
    echo "5) H200 Arcee FP8 Block (vLLM) PR 54479"
    echo "6) H200 Arcee Thinking FP8 Block (vLLM) PR 54479"
    echo "7) H200 Cohere (vLLM)"
    echo "8) H200 Cohere (vLLM) PR 54479"
    echo "9) H200 DataLab (vLLM)"
    echo "10) H200 DeepSeek (SGLang)"
    echo "11) H200 DeepSeek V4.1 Flash (vLLM) e77daef89"
    echo "12) H200 DeepSeek V4 Flash Vision Exp (SGLang) PR 37253"
    echo "13) H200 DeepSeek V4 Flash Vision Exp (vLLM) PR 54566"
    echo "14) H200 DeepSeek (vLLM)"
    echo "15) H200 DiffusionGemma (SGLang)"
    echo "16) H200 Gemma (SGLang)"
    echo "17) H200 Gemma (vLLM)"
    echo "18) H200 Gemma 3n (vLLM 0.10)"
    echo "19) H200 GLM 5.3 (vLLM 0.29.0)"
    echo "20) H200 GLM 5.3 Flash DFlash2 (SGLang) PR 37818"
    echo "21) H200 GLM 5.3 Flash DFlash2 (vLLM) PR 55423"
    echo "22) H200 GLM 5.3 Flash (vLLM) PR 53906 merge"
    echo "23) H200 GPT-OSS (SGLang)"
    echo "24) H200 gpt-oss (vLLM)"
    echo "25) H200 IBM (SGLang)"
    echo "26) H200 IBM (vLLM)"
    echo "27) H200 InclusionAI Ling 3 (vLLM)"
    echo "28) H200 InclusionAI (SGLang)"
    echo "29) H200 InclusionAI (vLLM)"
    echo "30) H200 IncoAI (SGLang)"
    echo "31) H200 IncoAI (vLLM)"
    echo "32) H200 Intel (SGLang)"
    echo "33) H200 Intel (vLLM)"
    echo "34) H200 LiquidAI (SGLang)"
    echo "35) H200 LiquidAI (SGLang) PR 31041"
    echo "36) H200 LiquidAI (vLLM)"
    echo "37) H200 Meta (SGLang)"
    echo "38) H200 Meta (vLLM)"
    echo "39) H200 Microsoft (vLLM)"
    echo "40) H200 MiniMax M2 family (SGLang) 0.5.10.post1"
    echo "41) H200 MiniMax M2 family (vLLM) 0f3ce4c74"
    echo "42) H200 MiniMax M2.5 (vLLM) 0.28.0"
    echo "43) H200 MistralAI (SGLang)"
    echo "44) H200 MistralAI (vLLM)"
    echo "45) H200 Nanbeige (SGLang)"
    echo "46) H200 Nanbeige (vLLM)"
    echo "47) H200 NVIDIA Nemotron Ultra (vLLM) PR54788 merge"
    echo "48) H200 Nex N2 (SGLang) 0.5.19"
    echo "49) H200 Nex N2 (vLLM) 0.29.0"
    echo "50) H200 NVIDIA DeepSeek (SGLang)"
    echo "51) H200 NVIDIA GLM-5.3 NVFP4 (SGLang 26fd7fd)"
    echo "52) H200 NVIDIA Muse Glimmer (SGLang) 0.5.20"
    echo "53) H200 NVIDIA Muse Glimmer (vLLM) 0.29.0"
    echo "54) H200 NVIDIA Nemotron (vLLM)"
    echo "55) H200 NVIDIA (SGLang)"
    echo "56) H200 NVIDIA (SGLang) PR 33554"
    echo "57) H200 NVIDIA (vLLM)"
    echo "58) H200 NVIDIA GLM 5.3 Flash (vLLM) PR 55222"
    echo "59) H200 OpenAI Whisper (SGLang) PR 38626"
    echo "60) H200 OpenAI Whisper (vLLM) PR 53207"
    echo "61) H200 Paradigma Limite (vLLM 0.26.0, official plugin)"
    echo "62) H200 Poolside Laguna XS (vLLM)"
    echo "63) H200 Poolside (SGLang)"
    echo "64) H200 Poolside (vLLM)"
    echo "65) H200 PrimeIntellect (SGLang)"
    echo "66) H200 PrimeIntellect (vLLM)"
    echo "67) H200 Qwen Flash Next (SGLang)"
    echo "68) H200 Qwen Flash Next (vLLM)"
    echo "69) H200 Qwen Flash Next disk PLE (vLLM PR 54129)"
    echo "70) H200 Qwen (SGLang)"
    echo "71) H200 Qwen (SGLang) PR 22121"
    echo "72) H200 Qwen (vLLM)"
    echo "73) H200 RadixArk Qwen Flash Next (SGLang)"
    echo "74) H200 RadixArk (SGLang)"
    echo "75) H200 RedHat (SGLang) PR 35809"
    echo "76) H200 RedHatAI (SGLang)"
    echo "77) H200 RedHatAI (vLLM)"
    echo "78) H200 StepFun (SGLang)"
    echo "79) H200 StepFun (vLLM)"
    echo "80) H200 XiaomiMiMo Flash (vLLM 1ea7c63, audio)"
    echo "81) H200 XiaomiMiMo Distill (SGLang 0.5.20)"
    echo "82) H200 XiaomiMiMo Distill (vLLM 0.30.0)"
    echo "83) H200 z-lab (SGLang)"
    echo "84) H200 z-lab (SGLang) PR 35209"
    echo "85) H200 z-lab (vLLM)"
    echo "86) H200 Zyphra Legacy (vLLM)"
    echo "87) H200 Zyphra (SGLang)"
    echo "88) H200 Zyphra (SGLang) PR 32517"
    echo "89) H200 Zyphra (vLLM)"
    echo "90) RTX PRO 6000 AllenAI (vLLM) 73a5831127a9"
    echo "91) RTX PRO 6000 AllenAI (vLLM) 73a78e6f1f38"
    echo "92) RTX PRO 6000 Arcee AI (vLLM) 73a5831127a9"
    echo "93) RTX PRO 6000 Arcee AI (vLLM) c8414a82712b NVFP4"
    echo "94) RTX PRO 6000 CohereLabs (vLLM) 73a5831127a9"
    echo "95) RTX PRO 6000 Datalab (vLLM) 73a5831127a9"
    echo "96) RTX PRO 6000 DeepSeek V4.1 Flash (vLLM) PR 56509 SM120"
    echo "97) RTX PRO 6000 GLM 5.3 Flash (vLLM) 2617fe938 SM120"
    echo "98) RTX PRO 6000 Google Gemma 4 (SGLang 1093c501dfef)"
    echo "99) RTX PRO 6000 incoai GLM-5.3 DFlash2 (SGLang 964c45cf3)"
    echo "100) RTX PRO 6000 incoai GLM-5.3 Flash (SGLang PR 38430, 028ac64f7)"
    echo "101) RTX PRO 6000 incoai GLM-5.3 Flash (vLLM 73a583112, b12x)"
    echo "102) RTX PRO 6000 incoai GLM-5.3 DFlash2 (vLLM PR 58773, 417b0b6aa)"
    echo "103) RTX PRO 6000 Intel (SGLang)"
    echo "104) RTX PRO 6000 LiquidAI (SGLang)"
    echo "105) RTX PRO 6000 LiquidAI (SGLang) PR 31041"
    echo "106) RTX PRO 6000 Nanbeige (SGLang)"
    echo "107) RTX PRO 6000 NVIDIA GLM-5.3 NVFP4 (SGLang 26fd7fd)"
    echo "108) RTX PRO 6000 NVIDIA GLM-5.3 Flash NVFP4 (SGLang) PR 38430"
    echo "109) RTX PRO 6000 NVIDIA Qwen3.8 Flash Next NVFP4 (vLLM) 9c2d21046"
    echo "110) RTX PRO 6000 NVIDIA Kimi-K2.6 NVFP4 (SGLang 964c45cf3)"
    echo "111) RTX PRO 6000 NVIDIA Kimi (vLLM PR 54013, 39e0ce172)"
    echo "112) RTX PRO 6000 PrimeIntellect (SGLang)"
    echo "113) RTX PRO 6000 Qwen Flash Next (vLLM)"
    echo "114) RTX PRO 6000 Qwen Flash Next disk PLE (vLLM PR 54129)"
    echo "115) RTX PRO 6000 Qwen (SGLang)"
    echo "116) RTX PRO 6000 XiaomiMiMo Flash (vLLM PR 58177, audio)"
    echo "117) Custom (uv)"
    echo "118) Custom (pip)"
    echo ""
    while true; do
        read -r -p "Enter your choice (1-118): " choice
        if ENV_TYPE=$(resolve_env_type "$choice"); then
            break
        else
            print_error "Invalid choice. Please enter a number between 1 and 118."
        fi
    done
elif [ -z "$ENV_TYPE" ]; then
    # Default to Custom (uv) in auto mode
    ENV_TYPE="custom_uv"
fi

# Normalize and validate the selected managed environment.
if [ -n "$ENV_TYPE" ]; then
    if ! ENV_TYPE_MAPPED=$(resolve_env_type "$ENV_TYPE"); then
        fail_script "Invalid environment selection: $ENV_TYPE. Choose a listed environment name or a number from 1 to 118."
        if [ "$BEING_SOURCED" = true ]; then
            return 1
        fi
    fi
    ENV_TYPE="$ENV_TYPE_MAPPED"
fi

# Set environment name based on type
ENV_NAME=$(resolve_env_name "$ENV_TYPE")

ENV_PATH="$HOME/${ENV_NAME}"

if [ "$REFRESH_ACTIVATION" = true ]; then
    if ! refresh_activation_script; then
        fail_script "Failed to refresh the activation script for $ENV_NAME."
        if [ "$BEING_SOURCED" = true ]; then
            return 1
        fi
    fi
    if [ "$BEING_SOURCED" = true ]; then
        return 0
    fi
    exit 0
fi

# Ask for HuggingFace model storage location
DEFAULT_HF_PATH="$WORKSPACE_DIR/models/huggingface"
if [ "$AUTO_MODE" = false ]; then
    echo ""
    print_info "Where would you like to store HuggingFace models?"
    print_info "Default: $DEFAULT_HF_PATH"
    read -r -p "Enter path (press Enter for default): " HF_PATH_INPUT
    
    if [ -z "$HF_PATH_INPUT" ]; then
        HF_PATH="$DEFAULT_HF_PATH"
        print_info "Using default path: $HF_PATH"
    else
        # Expand tilde if present
        HF_PATH="${HF_PATH_INPUT/#\~/$HOME}"
        print_info "Using custom path: $HF_PATH"
    fi
else
    HF_PATH="$DEFAULT_HF_PATH"
    print_info "Using default HuggingFace path: $HF_PATH"
fi

export HF_HOME="$HF_PATH"
export HF_HUB_CACHE="$HF_PATH/hub"

if ! select_cuda_for_env; then
    if [ "$BEING_SOURCED" = false ]; then
        exit 1
    else
        return 1
    fi
fi

# Check prerequisites
print_info "Checking prerequisites..."

if ! command -v python &> /dev/null; then
    print_error "Python is not available on PATH. Please ensure Python is installed and accessible before running this script."
    if [ "$BEING_SOURCED" = false ]; then
        exit 1
    else
        return 1
    fi
fi

if [ "$ENV_TYPE" = "h200-paradigma-inc-vllm-v0260" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 required by the official Limite plugin"
elif [ "$ENV_TYPE" = "rtxpro6k-allenai-vllm-73a5831127a9" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for AllenAI vLLM 73a5831127a9"
elif [ "$ENV_TYPE" = "rtxpro6k-allenai-vllm-73a78e6f1f38" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for AllenAI vLLM 73a78e6f1f38"
elif [ "$ENV_TYPE" = "rtxpro6k-arcee-ai-vllm-73a5831127a9" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for Arcee AI vLLM 73a5831127a9"
elif [ "$ENV_TYPE" = "rtxpro6k-arcee-ai-vllm-c8414a82712b" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for Arcee AI vLLM c8414a82712b"
elif [ "$ENV_TYPE" = "rtxpro6k-coherelabs-vllm-73a5831127a9" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for CohereLabs vLLM 73a5831127a9"
elif [ "$ENV_TYPE" = "rtxpro6k-datalab-to-vllm-73a5831127a9" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for Datalab vLLM 73a5831127a9"
elif [ "$ENV_TYPE" = "rtxpro6k-glm53-vllm-2617fe938" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for GLM 5.3 Flash vLLM 2617fe938"
elif [ "$ENV_TYPE" = "rtxpro6k-google-sglang-1093c501dfef" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for Google Gemma 4 SGLang 1093c501dfef"
elif [ "$ENV_TYPE" = "rtxpro6k-incoai-sglang-964c45cf3" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for incoai GLM-5.3 DFlash2 SGLang 964c45cf3"
elif [ "$ENV_TYPE" = "rtxpro6k-incoai-sglang-pr-028ac64f7" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for GLM-5.3 Flash SGLang PR 38430"
elif [ "$ENV_TYPE" = "rtxpro6k-incoai-vllm-73a583112" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for GLM-5.3 Flash vLLM 73a583112 with b12x"
elif [ "$ENV_TYPE" = "rtxpro6k-incoai-vllm-pr-417b0b6aa" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for incoai GLM-5.3 DFlash2 vLLM PR 58773"
elif [ "$ENV_TYPE" = "rtxpro6k-nvidia-vllm-pr-39e0ce172" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for NVIDIA Kimi vLLM PR 54013, 39e0ce172"
elif [ "$ENV_TYPE" = "rtxpro6k-xiaomimimo-flash-vllm-pr-58177" ]; then
    PYTHON_BIN="3.12"
    PYTHON_VERSION="Python 3.12 validated for XiaomiMiMo vLLM PR 58177"
else
    PYTHON_BIN=$(python -c 'import sys; print(sys._base_executable)')
    PYTHON_VERSION=$("$PYTHON_BIN" --version 2>&1)
fi
print_info "Using Python from: $PYTHON_BIN ($PYTHON_VERSION)"

if ! uses_pip_venv && ! command -v uv &> /dev/null; then
    print_error "uv is not installed. Please run ./installers/03_install_python.sh first."
    if [ "$BEING_SOURCED" = false ]; then
        exit 1
    else
        return 1
    fi
fi

# Check if environment exists and handle rebuild
if [ -d "$ENV_PATH" ]; then
    print_warning "⚠️  Environment $ENV_NAME already exists at $ENV_PATH"

    ENVIRONMENT_USABLE=true
    if ! environment_is_usable; then
        ENVIRONMENT_USABLE=false
        print_warning "Environment $ENV_NAME does not contain a working virtual-environment interpreter."
    fi

    if [ "$AUTO_MODE" = false ]; then
        echo ""
        print_info "Do you want to rebuild it? This will:"
        print_info "  • Delete the existing environment directory"
        print_info "  • Remove all installed packages"
        print_info "  • Create a fresh environment"
        echo ""

        while true; do
            read -r -p "Rebuild environment? (y/n): " RECREATE
            case ${RECREATE,,} in
                y|yes)
                    break
                    ;;
                n|no)
                    break
                    ;;
                *)
                    print_error "Please answer 'y' for yes or 'n' for no"
                    ;;
            esac
        done
    elif [ "$ENVIRONMENT_USABLE" = false ]; then
        RECREATE="y"
        print_warning "Auto mode: rebuilding the unusable environment."
    else
        RECREATE="n"
    fi
    if [[ "$RECREATE" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; then
        print_info "Destroying existing environment..."
        print_command "rm -rf $ENV_PATH"
        if ! rm -rf "$ENV_PATH"; then
            fail_script "Failed to remove unusable environment at $ENV_PATH"
            if [ "$BEING_SOURCED" = true ]; then
                return 1
            fi
        fi
        print_info "✓ Environment destroyed"
    elif [ "$ENVIRONMENT_USABLE" = false ]; then
        fail_script "Environment $ENV_NAME cannot be used without rebuilding it."
        if [ "$BEING_SOURCED" = true ]; then
            return 1
        fi
    elif [ "$AUTO_MODE" = true ]; then
        print_info "Using existing environment (use without --auto to be prompted)"
    else
        print_info "Keeping existing environment"
    fi
fi

if [ ! -d "$ENV_PATH" ]; then
    if uses_pip_venv; then
        print_info "Creating pip virtual environment at $ENV_PATH using $PYTHON_BIN..."
        VENV_CREATED=false
        if "$PYTHON_BIN" -m venv "$ENV_PATH"; then
            VENV_CREATED=true
        fi
    else
        print_info "Creating uv virtual environment at $ENV_PATH using $PYTHON_BIN..."
        VENV_CREATED=false
        if uv venv --no-cache "$ENV_PATH" --python "$PYTHON_BIN"; then
            VENV_CREATED=true
        fi
    fi
    
    if [ "$VENV_CREATED" = true ]; then
        print_info "✓ Virtual environment created successfully"
    else
        print_error "Failed to create virtual environment"
        if [ "$BEING_SOURCED" = false ]; then
            exit 1
        else
            return 1
        fi
    fi
fi

write_cuda_env_config

# Install baseline Hugging Face Hub tooling into the selected environment.
if ! install_huggingface_hub; then
    fail_script "Failed to install Hugging Face Hub"
    if [ "$BEING_SOURCED" = true ]; then
        return 1
    fi
fi

# Create activation script with environment variables
print_info "Creating activation script with ML environment variables..."

CUDA_ACTIVATE_SNIPPET=$(cat <<'CUDA_ACTIVATE_SNIPPET'

prepend_env_path_once() {
    local var_name="$1"
    local dir="$2"
    local current="${!var_name:-}"

    [ -n "$dir" ] || return 0
    [ -d "$dir" ] || return 0
    case ":$current:" in
        *":$dir:"*) return 0 ;;
    esac

    if [ -n "$current" ]; then
        printf -v "$var_name" '%s' "$dir:$current"
    else
        printf -v "$var_name" '%s' "$dir"
    fi
    export "$var_name"
}

cuda_home_is_valid() {
    local cuda_home="$1"

    [ -n "$cuda_home" ] || return 1
    cuda_home="${cuda_home%/}"
    [ -d "$cuda_home" ] || return 1
    [ -x "$cuda_home/bin/nvcc" ] || return 1
}

cuda_version_for_home() {
    local cuda_home="$1"

    cuda_home="${cuda_home%/}"
    if ! cuda_home_is_valid "$cuda_home"; then
        echo ""
        return 1
    fi

    "$cuda_home/bin/nvcc" --version 2>/dev/null | sed -n 's/.*release \([0-9][0-9]*\.[0-9][0-9]*\).*/\1/p' | head -1
}

detect_default_cuda_home() {
    local candidates=()
    local nvcc_path=""

    candidates+=("/usr/local/cuda")
    if [ -n "${CUDA_HOME:-}" ]; then
        candidates+=("$CUDA_HOME")
    fi
    if [ -n "${CUDA_PATH:-}" ]; then
        candidates+=("$CUDA_PATH")
    fi
    if nvcc_path=$(command -v nvcc 2>/dev/null); then
        candidates+=("$(cd -- "$(dirname -- "$nvcc_path")/.." && pwd)")
    fi

    local candidate
    local seen=":"
    for candidate in "${candidates[@]}"; do
        [ -n "$candidate" ] || continue
        candidate="${candidate%/}"
        case "$seen" in
            *":$candidate:"*) continue ;;
        esac
        seen+="$candidate:"

        if cuda_home_is_valid "$candidate"; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

apply_env_cuda_selection() {
    local cuda_config="${VIRTUAL_ENV:-}/.cuda_env"
    CUDA_ENV_MODE="bashrc"
    CUDA_ENV_HOME=""
    CUDA_ENV_VERSION=""

    if [ -f "$cuda_config" ]; then
        source "$cuda_config"
    fi

    case "${CUDA_ENV_MODE:-bashrc}" in
        explicit)
            if ! cuda_home_is_valid "$CUDA_ENV_HOME"; then
                echo "[ERROR] Selected CUDA toolkit is not available: $CUDA_ENV_HOME"
                echo "[ERROR] Install CUDA first with ./installers/02_install_cuda.sh or rerun ./installers/05_setup_env.sh to select another CUDA version."
                return 1
            fi
            export CUDA_HOME="${CUDA_ENV_HOME%/}"
            export CUDA_PATH="$CUDA_HOME"
            export ML_ENV_CUDA_SOURCE="environment selection"
            ;;
        bashrc|"")
            local default_cuda_home
            if ! default_cuda_home=$(detect_default_cuda_home); then
                echo "[ERROR] No CUDA toolkit detected. Install CUDA first with ./installers/02_install_cuda.sh."
                return 1
            fi
            export CUDA_HOME="${default_cuda_home%/}"
            export CUDA_PATH="$CUDA_HOME"
            export CUDA_ENV_MODE="bashrc"
            export ML_ENV_CUDA_SOURCE="bashrc default"
            ;;
        *)
            echo "[ERROR] Invalid CUDA_ENV_MODE in $cuda_config: $CUDA_ENV_MODE"
            return 1
            ;;
    esac

    prepend_env_path_once PATH "$CUDA_HOME/bin"
    prepend_env_path_once LD_LIBRARY_PATH "$CUDA_HOME/lib64"
    prepend_env_path_once LD_LIBRARY_PATH "$CUDA_HOME/lib"
    prepend_env_path_once LIBRARY_PATH "$CUDA_HOME/lib64"
    prepend_env_path_once LIBRARY_PATH "$CUDA_HOME/lib"
    if [ -d "$CUDA_HOME/include/cccl" ]; then
        prepend_env_path_once CPATH "$CUDA_HOME/include/cccl"
    fi

    export ML_ENV_CUDA_APPLIED=1
    export ML_ENV_CUDA_HOME="$CUDA_HOME"
    export ML_ENV_CUDA_VERSION
    ML_ENV_CUDA_VERSION=$(cuda_version_for_home "$CUDA_HOME")
}

apply_env_cuda_selection || return 1 2>/dev/null || exit 1
CUDA_ACTIVATE_SNIPPET
)

cat > "$ENV_PATH/activate_ml" << EOF
#!/bin/bash
# Activate virtual environment
source "$ENV_PATH/bin/activate"
export DG_JIT_CACHE_DIR="\${VIRTUAL_ENV:-$ENV_PATH}/.cache/deep_gemm"
export FLASHINFER_WORKSPACE_BASE="\${VIRTUAL_ENV:-$ENV_PATH}"
export SGLANG_DG_CACHE_DIR="\${VIRTUAL_ENV:-$ENV_PATH}/.cache/deep_gemm"
export TORCH_EXTENSIONS_DIR="\${VIRTUAL_ENV:-$ENV_PATH}/.cache/torch_extensions"
export TORCH_HOME="\${VIRTUAL_ENV:-$ENV_PATH}/.cache/torch"
export TORCHINDUCTOR_CACHE_DIR="\${VIRTUAL_ENV:-$ENV_PATH}/.cache/torchinductor"
export TRITON_CACHE_DIR="\${VIRTUAL_ENV:-$ENV_PATH}/.cache/triton"
export TRITON_HOME="\${VIRTUAL_ENV:-$ENV_PATH}"
export TVM_FFI_CACHE_DIR="\${VIRTUAL_ENV:-$ENV_PATH}/.cache/tvm-ffi"
export VLLM_CACHE_ROOT="\${VIRTUAL_ENV:-$ENV_PATH}/.cache/vllm"
export XDG_CACHE_HOME="\${VIRTUAL_ENV:-$ENV_PATH}/.cache"

# Set ML environment variables
export HF_HOME="$HF_PATH"
export HF_HUB_CACHE="$HF_PATH/hub"
${CUDA_ACTIVATE_SNIPPET}

echo "ML environment activated with:"
echo "  - Virtual env: $ENV_PATH"
echo "  - HF_HOME: $HF_PATH"
echo "  - HF_HUB_CACHE: $HF_PATH/hub"
if [ -n "\${ML_ENV_CUDA_HOME:-}" ]; then
    echo "  - CUDA toolkit: \${ML_ENV_CUDA_HOME} (\${ML_ENV_CUDA_VERSION:-unknown}, \${ML_ENV_CUDA_SOURCE:-configured})"
fi
${TORCH_CUDA_ARCH_BANNER}
echo "  - Python: \$(python --version)"
EOF

chmod +x "$ENV_PATH/activate_ml"

# Create directory structure
print_info "Creating directory structure..."
# Get parent directories from HF_PATH
HF_PARENT=$(dirname "$HF_PATH")
HF_GRANDPARENT=$(dirname "$HF_PARENT")

DIRS=(
    "$HF_GRANDPARENT"
    "$HF_PARENT"
    "$HF_PATH"
    "$HF_PATH/hub"
)

for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" 2>/dev/null || {
            print_warning "Could not create $dir - you may need to create it manually"
        }
    else
        print_info "✓ $dir exists"
    fi
done

echo ""
print_info "✓ ML environment setup complete!"
echo ""

# ACTIVATE IF BEING SOURCED
if [ "$BEING_SOURCED" = true ]; then
    print_info "Activating ML environment..."
    if ! source "$ENV_PATH/activate_ml"; then
        fail_script "Failed to activate ML environment"
        return 1
    fi
else
    # Show activation instructions when run as script
    print_info "To activate the environment:"
    echo ""
    print_command "source $ENV_PATH/activate_ml"
    echo ""
    print_info "Or use the alias (after reloading shell):"
    print_command "source ~/.bashrc"
    print_command "$ENV_NAME"
    echo ""
    print_info "Or source this script to create and activate:"
    print_command "source $0"
fi
