#!/bin/bash

# Script: launch_env.sh
# Purpose: Activate ML environment with all optimizations
# Usage: source launch_env.sh [--auto] [ENV_NAME|1-111]

WORKSPACE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

# Source bashrc to ensure environment is properly loaded
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

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
        export "$var_name=$dir:$current"
    else
        export "$var_name=$dir"
    fi
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
    local cuda_config="$ENV_PATH/.cuda_env"
    CUDA_ENV_MODE="bashrc"
    CUDA_ENV_HOME=""

    if [ -f "$cuda_config" ]; then
        source "$cuda_config"
    fi

    case "${CUDA_ENV_MODE:-bashrc}" in
        explicit)
            if ! cuda_home_is_valid "$CUDA_ENV_HOME"; then
                print_error "Selected CUDA toolkit is not available: $CUDA_ENV_HOME"
                print_error "Install CUDA first with ./installers/02_install_cuda.sh or rerun ./installers/05_setup_env.sh to select another CUDA version."
                return 1
            fi
            export CUDA_HOME="${CUDA_ENV_HOME%/}"
            export CUDA_PATH="$CUDA_HOME"
            export ML_ENV_CUDA_SOURCE="environment selection"
            ;;
        bashrc|"")
            local default_cuda_home
            if ! default_cuda_home=$(detect_default_cuda_home); then
                print_error "No CUDA toolkit detected. Install CUDA first with ./installers/02_install_cuda.sh."
                return 1
            fi
            export CUDA_HOME="${default_cuda_home%/}"
            export CUDA_PATH="$CUDA_HOME"
            export CUDA_ENV_MODE="bashrc"
            export ML_ENV_CUDA_SOURCE="bashrc default"
            ;;
        *)
            print_error "Invalid CUDA_ENV_MODE in $cuda_config: $CUDA_ENV_MODE"
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
    print_info "CUDA toolkit: $ML_ENV_CUDA_HOME (${ML_ENV_CUDA_VERSION:-unknown}, $ML_ENV_CUDA_SOURCE)"
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
        90|rtxpro6k_deepseek_v41_vllm_pr_56509|rtxpro6k-deepseek-v41-vllm-pr-56509)
            echo "rtxpro6k-deepseek-v41-vllm-pr-56509"
            ;;
        91|rtxpro6k_glm53_vllm_2617fe938|rtxpro6k-glm53-vllm-2617fe938)
            echo "rtxpro6k-glm53-vllm-2617fe938"
            ;;
        92|rtxpro6k_incoai_sglang_964c45cf3|rtxpro6k-incoai-sglang-964c45cf3)
            echo "rtxpro6k-incoai-sglang-964c45cf3"
            ;;
        93|rtxpro6k_incoai_sglang_pr_028ac64f7|rtxpro6k-incoai-sglang-pr-028ac64f7)
            echo "rtxpro6k-incoai-sglang-pr-028ac64f7"
            ;;
        94|rtxpro6k_incoai_vllm_73a583112|rtxpro6k-incoai-vllm-73a583112)
            echo "rtxpro6k-incoai-vllm-73a583112"
            ;;
        95|rtxpro6k_incoai_vllm_pr_417b0b6aa|rtxpro6k-incoai-vllm-pr-417b0b6aa)
            echo "rtxpro6k-incoai-vllm-pr-417b0b6aa"
            ;;
        96|rtxpro6k_intel_sglang|rtxpro6k-intel-sglang)
            echo "rtxpro6k-intel-sglang"
            ;;
        97|rtxpro6k_liquidai_sglang|rtxpro6k-liquidai-sglang)
            echo "rtxpro6k-liquidai-sglang"
            ;;
        98|rtxpro6k_liquidai_sglang_pr_31041|rtxpro6k-liquidai-sglang-pr-31041)
            echo "rtxpro6k-liquidai-sglang-pr-31041"
            ;;
        99|rtxpro6k_nanbeige_sglang|rtxpro6k-nanbeige-sglang)
            echo "rtxpro6k-nanbeige-sglang"
            ;;
        100|rtxpro6k_nvidia_glm53_sglang_26fd7fd|rtxpro6k-nvidia-glm53-sglang-26fd7fd)
            echo "rtxpro6k-nvidia-glm53-sglang-26fd7fd"
            ;;
        101|rtxpro6k_nvidia_glm53flash_sglang_pr_38430|rtxpro6k-nvidia-glm53flash-sglang-pr-38430)
            echo "rtxpro6k-nvidia-glm53flash-sglang-pr-38430"
            ;;
        102|rtxpro6k_nvidia_qwen38_vllm_9c2d21046|rtxpro6k-nvidia-qwen38-vllm-9c2d21046)
            echo "rtxpro6k-nvidia-qwen38-vllm-9c2d21046"
            ;;
        103|rtxpro6k_nvidia_sglang_964c45cf3|rtxpro6k-nvidia-sglang-964c45cf3)
            echo "rtxpro6k-nvidia-sglang-964c45cf3"
            ;;
        104|rtxpro6k_nvidia_vllm_pr_39e0ce172|rtxpro6k-nvidia-vllm-pr-39e0ce172)
            echo "rtxpro6k-nvidia-vllm-pr-39e0ce172"
            ;;
        105|rtxpro6k_primeintellect_sglang|rtxpro6k-primeintellect-sglang)
            echo "rtxpro6k-primeintellect-sglang"
            ;;
        106|rtxpro6k_qwen_flash_next_vllm|rtxpro6k-qwen-flash-next-vllm)
            echo "rtxpro6k-qwen-flash-next-vllm"
            ;;
        107|rtxpro6k_qwen_flash_next_vllm_pr_54129|rtxpro6k-qwen-flash-next-vllm-pr-54129)
            echo "rtxpro6k-qwen-flash-next-vllm-pr-54129"
            ;;
        108|rtxpro6k_qwen_sglang|rtxpro6k-qwen-sglang)
            echo "rtxpro6k-qwen-sglang"
            ;;
        109|rtxpro6k_xiaomimimo_flash_vllm_pr_58177|rtxpro6k-xiaomimimo-flash-vllm-pr-58177)
            echo "rtxpro6k-xiaomimimo-flash-vllm-pr-58177"
            ;;
        110|custom|custom_uv|custom-uv|env_custom_uv)
            echo "custom_uv"
            ;;
        111|custom_pip|custom-pip|env_custom_pip)
            echo "custom_pip"
            ;;
        *)
            return 1
            ;;
    esac
}

resolve_env_name() {
    local env_type="$1"

    if [ -z "$env_type" ]; then
        echo "custom_uv"
        return 0
    fi

    echo "$env_type"
}

# This launcher mutates the caller's shell and therefore must be sourced.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_error "This script must be sourced, not executed!"
    print_error "Use: source $0 [--auto] [ENV_NAME|1-111]"
    exit 1
fi

# Parse arguments
AUTO_MODE=false
ENV_TYPE=""

for arg in "$@"; do
    case $arg in
        --auto)
            AUTO_MODE=true
            ;;
        *)
            if [[ ! "$arg" =~ ^-- ]]; then
                ENV_TYPE="$arg"
            fi
            ;;
    esac
done

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
    echo "90) RTX PRO 6000 DeepSeek V4.1 Flash (vLLM) PR 56509 SM120"
    echo "91) RTX PRO 6000 GLM 5.3 Flash (vLLM) 2617fe938 SM120"
    echo "92) RTX PRO 6000 incoai GLM-5.3 DFlash2 (SGLang 964c45cf3)"
    echo "93) RTX PRO 6000 incoai GLM-5.3 Flash (SGLang PR 38430, 028ac64f7)"
    echo "94) RTX PRO 6000 incoai GLM-5.3 Flash (vLLM 73a583112, b12x)"
    echo "95) RTX PRO 6000 incoai GLM-5.3 DFlash2 (vLLM PR 58773, 417b0b6aa)"
    echo "96) RTX PRO 6000 Intel (SGLang)"
    echo "97) RTX PRO 6000 LiquidAI (SGLang)"
    echo "98) RTX PRO 6000 LiquidAI (SGLang) PR 31041"
    echo "99) RTX PRO 6000 Nanbeige (SGLang)"
    echo "100) RTX PRO 6000 NVIDIA GLM-5.3 NVFP4 (SGLang 26fd7fd)"
    echo "101) RTX PRO 6000 NVIDIA GLM-5.3 Flash NVFP4 (SGLang) PR 38430"
    echo "102) RTX PRO 6000 NVIDIA Qwen3.8 Flash Next NVFP4 (vLLM) 9c2d21046"
    echo "103) RTX PRO 6000 NVIDIA Kimi-K2.6 NVFP4 (SGLang 964c45cf3)"
    echo "104) RTX PRO 6000 NVIDIA Kimi (vLLM PR 54013, 39e0ce172)"
    echo "105) RTX PRO 6000 PrimeIntellect (SGLang)"
    echo "106) RTX PRO 6000 Qwen Flash Next (vLLM)"
    echo "107) RTX PRO 6000 Qwen Flash Next disk PLE (vLLM PR 54129)"
    echo "108) RTX PRO 6000 Qwen (SGLang)"
    echo "109) RTX PRO 6000 XiaomiMiMo Flash (vLLM PR 58177, audio)"
    echo "110) Custom (uv)"
    echo "111) Custom (pip)"
    echo ""
    while true; do
        read -r -p "Enter your choice (1-111): " choice
        if ENV_TYPE=$(resolve_env_type "$choice"); then
            break
        else
            print_error "Invalid choice. Please enter a number between 1 and 111."
        fi
    done
elif [ -z "$ENV_TYPE" ]; then
    # Default to Custom (uv) in auto mode
    ENV_TYPE="custom_uv"
fi

# Normalize and validate the selected managed environment.
if [ -n "$ENV_TYPE" ]; then
    if ! ENV_TYPE_MAPPED=$(resolve_env_type "$ENV_TYPE"); then
        print_error "Invalid environment selection: $ENV_TYPE. Choose a listed environment name or a number from 1 to 111."
        return 1
    fi
    ENV_TYPE="$ENV_TYPE_MAPPED"
fi

# Set environment name based on type
ENV_NAME=$(resolve_env_name "$ENV_TYPE")

ENV_PATH="$HOME/env_${ENV_NAME}"

# Check if environment exists
if [ ! -d "$ENV_PATH" ]; then
    print_error "Environment '$ENV_NAME' not found at $ENV_PATH"
    print_info "Run ./installers/05_setup_env.sh first to create it"
    return 1
fi

# Check if already in a virtual environment
if [ -n "$VIRTUAL_ENV" ]; then
    print_warning "Already in virtual environment: $VIRTUAL_ENV"
    if [ "$AUTO_MODE" = false ]; then
        read -r -p "Deactivate and switch to $ENV_NAME? (y/n): " SWITCH
    else
        SWITCH="y"
        print_info "Auto mode: switching environment"
    fi
    if [[ "$SWITCH" =~ ^[Yy]$ ]]; then
        deactivate
    else
        return 0
    fi
fi

# Check if activate_ml script exists, use it if available
if [ -f "$ENV_PATH/activate_ml" ]; then
    print_info "Using activate_ml script..."
    if ! source "$ENV_PATH/activate_ml"; then
        print_error "Failed to activate environment '$ENV_NAME' with $ENV_PATH/activate_ml"
        return 1
    fi
elif [ -f "$ENV_PATH/bin/activate" ]; then
    # Fallback to manual activation
    print_info "Activating $ENV_NAME environment..."
    if ! source "$ENV_PATH/bin/activate"; then
        print_error "Failed to activate environment '$ENV_NAME' with $ENV_PATH/bin/activate"
        return 1
    fi
    
    # Determine HF_PATH - check if already set, otherwise use default
    if [ -n "$HF_HOME" ]; then
        HF_PATH="$HF_HOME"
    else
        HF_PATH="$WORKSPACE_DIR/models/huggingface"
    fi
    
    # Set ML environment variables
    export HF_HOME="$HF_PATH"
    export HF_HUB_CACHE="$HF_PATH/hub"

else
    print_error "No activation script found for environment '$ENV_NAME'"
    print_info "Expected $ENV_PATH/activate_ml or $ENV_PATH/bin/activate"
    return 1
fi

if [ "${ML_ENV_CUDA_APPLIED:-}" != "1" ]; then
    if ! apply_env_cuda_selection; then
        return 1
    fi
fi

export DG_JIT_CACHE_DIR="${VIRTUAL_ENV:-$ENV_PATH}/.cache/deep_gemm"
export FLASHINFER_WORKSPACE_BASE="${VIRTUAL_ENV:-$ENV_PATH}"
export SGLANG_DG_CACHE_DIR="${VIRTUAL_ENV:-$ENV_PATH}/.cache/deep_gemm"
export TORCH_EXTENSIONS_DIR="${VIRTUAL_ENV:-$ENV_PATH}/.cache/torch_extensions"
export TORCH_HOME="${VIRTUAL_ENV:-$ENV_PATH}/.cache/torch"
export TORCHINDUCTOR_CACHE_DIR="${VIRTUAL_ENV:-$ENV_PATH}/.cache/torchinductor"
export TRITON_CACHE_DIR="${VIRTUAL_ENV:-$ENV_PATH}/.cache/triton"
export TRITON_HOME="${VIRTUAL_ENV:-$ENV_PATH}"
export TVM_FFI_CACHE_DIR="${VIRTUAL_ENV:-$ENV_PATH}/.cache/tvm-ffi"
export VLLM_CACHE_ROOT="${VIRTUAL_ENV:-$ENV_PATH}/.cache/vllm"
export XDG_CACHE_HOME="${VIRTUAL_ENV:-$ENV_PATH}/.cache"

# Display activation info if not using activate_ml script
if [ ! -f "$ENV_PATH/activate_ml" ]; then
    echo ""
    print_info "✓ ML environment activated!"
    echo "  - Virtual env: $ENV_PATH"
    echo "  - Python: $(which python) ($(python --version 2>&1))"
    echo "  - HF_HOME: $HF_HOME"
    echo "  - HF_HUB_CACHE: $HF_HUB_CACHE"
    echo "  - CPU threads: $OMP_NUM_THREADS"
    echo "  - TORCH_CUDA_ARCH_LIST: ${TORCH_CUDA_ARCH_LIST:-unset}"
    if [ -n "${ML_ENV_CUDA_HOME:-}" ]; then
        echo "  - CUDA toolkit: $ML_ENV_CUDA_HOME (${ML_ENV_CUDA_VERSION:-unknown}, ${ML_ENV_CUDA_SOURCE:-configured})"
    elif command -v nvcc &> /dev/null; then
        echo "  - CUDA: $(nvcc --version | grep release | awk '{print $6}')"
    fi
fi

echo ""
print_info "To deactivate: deactivate"
print_info "To install or configure environment packages: ./installers/06_install_packages.sh"
