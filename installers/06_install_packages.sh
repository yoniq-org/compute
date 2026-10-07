#!/bin/bash

# Script: 06_install_packages.sh
# Purpose: Install recipe-specific packages into the selected environment.
# Usage: ./installers/06_install_packages.sh [ENV_NAME]

if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_command() { echo -e "${BLUE}[RUN]${NC} $1"; }



ENV_TYPES=(
  "h200-allenai-vllm"
  "h200-arcee-nvfp4-vllm"
  "h200-arcee-vllm"
  "h200-arcee-vllm-pr-54479"
  "h200-arcee-vllm-pr-54479-fp8-block"
  "h200-arcee-vllm-pr-54479-thinking-fp8-block"
  "h200-cohere-vllm"
  "h200-cohere-vllm-pr-54479"
  "h200-datalab-vllm"
  "h200-deepseek-sglang"
  "h200-deepseek-v41-vllm-e77daef89"
  "h200-deepseek-vision-sglang-pr-37253"
  "h200-deepseek-vision-vllm-pr-54566"
  "h200-deepseek-vllm"
  "h200-diffusiongemma-sglang"
  "h200-gemma-sglang"
  "h200-gemma-vllm"
  "h200-gemma3n-vllm"
  "h200-glm53-vllm-v0290"
  "h200-glm53flash-dflash2-sglang-pr-37818"
  "h200-glm53flash-dflash2-vllm-pr-55423"
  "h200-glm53flash-vllm-pr-53906"
  "h200-gpt-oss-sglang"
  "h200-gpt-oss-vllm"
  "h200-ibm-sglang"
  "h200-ibm-vllm"
  "h200-inclusionai-ling3-vllm"
  "h200-inclusionai-sglang"
  "h200-inclusionai-vllm"
  "h200-incoai-sglang"
  "h200-incoai-vllm"
  "h200-intel-sglang"
  "h200-intel-vllm"
  "h200-liquidai-sglang"
  "h200-liquidai-sglang-pr-31041"
  "h200-liquidai-vllm"
  "h200-meta-sglang"
  "h200-meta-vllm"
  "h200-microsoft-vllm"
  "h200-minimax-m2-sglang-v0510-post1"
  "h200-minimax-m2-vllm-0f3ce4c74"
  "h200-minimax-m25-vllm-v0280"
  "h200-mistralai-sglang"
  "h200-mistralai-vllm"
  "h200-nanbeige-sglang"
  "h200-nanbeige-vllm"
  "h200-nemotron-ultra-vllm-9c2d21046"
  "h200-nex-n2-sglang-v0519"
  "h200-nex-n2-vllm-v0290"
  "h200-nvidia-deepseek-sglang"
  "h200-nvidia-glm53-sglang-26fd7fd"
  "h200-nvidia-muse-sglang-v0520"
  "h200-nvidia-muse-vllm-v0290"
  "h200-nvidia-nemotron"
  "h200-nvidia-sglang"
  "h200-nvidia-sglang-pr-33554"
  "h200-nvidia-vllm"
  "h200-nvidia-vllm-pr-55222"
  "h200-openai-sglang-pr-38626"
  "h200-openai-vllm-pr-53207"
  "h200-paradigma-inc-vllm-v0260"
  "h200-poolside-laguna-xs-vllm"
  "h200-poolside-sglang"
  "h200-poolside-vllm"
  "h200-primeintellect-sglang"
  "h200-primeintellect-vllm"
  "h200-qwen-flash-next-sglang"
  "h200-qwen-flash-next-vllm"
  "h200-qwen-flash-next-vllm-pr-54129"
  "h200-qwen-sglang"
  "h200-qwen-sglang-pr-22121"
  "h200-qwen-vllm"
  "h200-radixark-qwen-sglang"
  "h200-radixark-sglang"
  "h200-redhat-sglang-pr-35809"
  "h200-redhatai-sglang"
  "h200-redhatai-vllm"
  "h200-stepfun-sglang"
  "h200-stepfun-vllm"
  "h200-xiaomimimo-flash-vllm-1ea7c63"
  "h200-xiaomimimo-sglang-v0520"
  "h200-xiaomimimo-vllm-v0300"
  "h200-z-lab-sglang"
  "h200-z-lab-sglang-pr-35209"
  "h200-z-lab-vllm"
  "h200-zyphra-legacy-vllm"
  "h200-zyphra-sglang"
  "h200-zyphra-sglang-pr-32517"
  "h200-zyphra-vllm"
  "rtxpro6k-allenai-vllm-73a5831127a9"
  "rtxpro6k-allenai-vllm-73a78e6f1f38"
  "rtxpro6k-arcee-ai-vllm-73a5831127a9"
  "rtxpro6k-arcee-ai-vllm-c8414a82712b"
  "rtxpro6k-coherelabs-vllm-73a5831127a9"
  "rtxpro6k-datalab-to-vllm-73a5831127a9"
  "rtxpro6k-deepseek-v41-vllm-pr-56509"
  "rtxpro6k-glm53-vllm-2617fe938"
  "rtxpro6k-google-sglang-1093c501dfef"
  "rtxpro6k-google-vllm-73a5831127a9"
  "rtxpro6k-ibm-granite-sglang-fa7784d140ee"
  "rtxpro6k-ibm-granite-vllm-73a5831127a9"
  "rtxpro6k-incoai-sglang-964c45cf3"
  "rtxpro6k-incoai-sglang-fa7784d140ee"
  "rtxpro6k-incoai-sglang-pr-028ac64f7"
  "rtxpro6k-incoai-vllm-73a583112"
  "rtxpro6k-incoai-vllm-pr-417b0b6aa"
  "rtxpro6k-intel-sglang"
  "rtxpro6k-intel-vllm-73a5831127a9"
  "rtxpro6k-liquidai-sglang"
  "rtxpro6k-liquidai-sglang-pr-31041"
  "rtxpro6k-mistralai-sglang-fa7784d140ee"
  "rtxpro6k-mistralai-vllm-73a5831127a9"
  "rtxpro6k-mistralai-vllm-pr-678ef33584da"
  "rtxpro6k-nanbeige-sglang"
  "rtxpro6k-nvidia-glm53-sglang-26fd7fd"
  "rtxpro6k-nvidia-glm53flash-sglang-pr-38430"
  "rtxpro6k-nvidia-qwen38-vllm-9c2d21046"
  "rtxpro6k-nvidia-sglang-964c45cf3"
  "rtxpro6k-nvidia-vllm-pr-39e0ce172"
  "rtxpro6k-primeintellect-sglang"
  "rtxpro6k-qwen-flash-next-vllm"
  "rtxpro6k-qwen-flash-next-vllm-pr-54129"
  "rtxpro6k-qwen-sglang"
  "rtxpro6k-xiaomimimo-flash-vllm-pr-58177"
  "custom_uv"
  "custom_pip"
)

declare -A ENV_DESCRIPTIONS=(
  ["h200-allenai-vllm"]="H200 AllenAI (vLLM)"
  ["h200-arcee-nvfp4-vllm"]="H200 Arcee NVFP4 (vLLM)"
  ["h200-arcee-vllm"]="H200 Arcee (vLLM)"
  ["h200-arcee-vllm-pr-54479"]="H200 Arcee (vLLM) PR 54479"
  ["h200-arcee-vllm-pr-54479-fp8-block"]="H200 Arcee FP8 Block (vLLM) PR 54479"
  ["h200-arcee-vllm-pr-54479-thinking-fp8-block"]="H200 Arcee Thinking FP8 Block (vLLM) PR 54479"
  ["h200-cohere-vllm"]="H200 Cohere (vLLM)"
  ["h200-cohere-vllm-pr-54479"]="H200 Cohere (vLLM) PR 54479"
  ["h200-datalab-vllm"]="H200 DataLab (vLLM)"
  ["h200-deepseek-sglang"]="H200 DeepSeek (SGLang)"
  ["h200-deepseek-v41-vllm-e77daef89"]="H200 DeepSeek V4.1 Flash (vLLM) e77daef89"
  ["h200-deepseek-vision-sglang-pr-37253"]="H200 DeepSeek V4 Flash Vision Exp (SGLang) PR 37253"
  ["h200-deepseek-vision-vllm-pr-54566"]="H200 DeepSeek V4 Flash Vision Exp (vLLM) PR 54566"
  ["h200-deepseek-vllm"]="H200 DeepSeek (vLLM)"
  ["h200-diffusiongemma-sglang"]="H200 DiffusionGemma (SGLang)"
  ["h200-gemma-sglang"]="H200 Gemma (SGLang)"
  ["h200-gemma-vllm"]="H200 Gemma (vLLM)"
  ["h200-gemma3n-vllm"]="H200 Gemma 3n (vLLM 0.10)"
  ["h200-glm53-vllm-v0290"]="H200 GLM 5.3 (vLLM 0.29.0)"
  ["h200-glm53flash-dflash2-sglang-pr-37818"]="H200 GLM 5.3 Flash DFlash2 (SGLang) PR 37818"
  ["h200-glm53flash-dflash2-vllm-pr-55423"]="H200 GLM 5.3 Flash DFlash2 (vLLM) PR 55423"
  ["h200-glm53flash-vllm-pr-53906"]="H200 GLM 5.3 Flash (vLLM) PR 53906 merge"
  ["h200-gpt-oss-sglang"]="H200 GPT-OSS (SGLang)"
  ["h200-gpt-oss-vllm"]="H200 gpt-oss (vLLM)"
  ["h200-ibm-sglang"]="H200 IBM (SGLang)"
  ["h200-ibm-vllm"]="H200 IBM (vLLM)"
  ["h200-inclusionai-ling3-vllm"]="H200 InclusionAI Ling 3 (vLLM)"
  ["h200-inclusionai-sglang"]="H200 InclusionAI (SGLang)"
  ["h200-inclusionai-vllm"]="H200 InclusionAI (vLLM)"
  ["h200-incoai-sglang"]="H200 IncoAI (SGLang)"
  ["h200-incoai-vllm"]="H200 IncoAI (vLLM)"
  ["h200-intel-sglang"]="H200 Intel (SGLang)"
  ["h200-intel-vllm"]="H200 Intel (vLLM)"
  ["h200-liquidai-sglang"]="H200 LiquidAI (SGLang)"
  ["h200-liquidai-sglang-pr-31041"]="H200 LiquidAI (SGLang) PR 31041"
  ["h200-liquidai-vllm"]="H200 LiquidAI (vLLM)"
  ["h200-meta-sglang"]="H200 Meta (SGLang)"
  ["h200-meta-vllm"]="H200 Meta (vLLM)"
  ["h200-microsoft-vllm"]="H200 Microsoft (vLLM)"
  ["h200-minimax-m2-sglang-v0510-post1"]="H200 MiniMax M2 family (SGLang) 0.5.10.post1"
  ["h200-minimax-m2-vllm-0f3ce4c74"]="H200 MiniMax M2 family (vLLM) 0f3ce4c74"
  ["h200-minimax-m25-vllm-v0280"]="H200 MiniMax M2.5 (vLLM) 0.28.0"
  ["h200-mistralai-sglang"]="H200 MistralAI (SGLang)"
  ["h200-mistralai-vllm"]="H200 MistralAI (vLLM)"
  ["h200-nanbeige-sglang"]="H200 Nanbeige (SGLang)"
  ["h200-nanbeige-vllm"]="H200 Nanbeige (vLLM)"
  ["h200-nemotron-ultra-vllm-9c2d21046"]="H200 NVIDIA Nemotron Ultra (vLLM) PR54788 merge"
  ["h200-nex-n2-sglang-v0519"]="H200 Nex N2 (SGLang) 0.5.19"
  ["h200-nex-n2-vllm-v0290"]="H200 Nex N2 (vLLM) 0.29.0"
  ["h200-nvidia-deepseek-sglang"]="H200 NVIDIA DeepSeek (SGLang)"
  ["h200-nvidia-glm53-sglang-26fd7fd"]="H200 NVIDIA GLM-5.3 NVFP4 (SGLang 26fd7fd)"
  ["h200-nvidia-muse-sglang-v0520"]="H200 NVIDIA Muse Glimmer (SGLang) 0.5.20"
  ["h200-nvidia-muse-vllm-v0290"]="H200 NVIDIA Muse Glimmer (vLLM) 0.29.0"
  ["h200-nvidia-nemotron"]="H200 NVIDIA Nemotron (vLLM)"
  ["h200-nvidia-sglang"]="H200 NVIDIA (SGLang)"
  ["h200-nvidia-sglang-pr-33554"]="H200 NVIDIA (SGLang) PR 33554"
  ["h200-nvidia-vllm"]="H200 NVIDIA (vLLM)"
  ["h200-nvidia-vllm-pr-55222"]="H200 NVIDIA GLM 5.3 Flash (vLLM) PR 55222"
  ["h200-openai-sglang-pr-38626"]="H200 OpenAI Whisper (SGLang) PR 38626"
  ["h200-openai-vllm-pr-53207"]="H200 OpenAI Whisper (vLLM) PR 53207"
  ["h200-paradigma-inc-vllm-v0260"]="H200 Paradigma Limite (vLLM 0.26.0, official plugin)"
  ["h200-poolside-laguna-xs-vllm"]="H200 Poolside Laguna XS (vLLM)"
  ["h200-poolside-sglang"]="H200 Poolside (SGLang)"
  ["h200-poolside-vllm"]="H200 Poolside (vLLM)"
  ["h200-primeintellect-sglang"]="H200 PrimeIntellect (SGLang)"
  ["h200-primeintellect-vllm"]="H200 PrimeIntellect (vLLM)"
  ["h200-qwen-flash-next-sglang"]="H200 Qwen Flash Next (SGLang)"
  ["h200-qwen-flash-next-vllm"]="H200 Qwen Flash Next (vLLM)"
  ["h200-qwen-flash-next-vllm-pr-54129"]="H200 Qwen Flash Next disk PLE (vLLM PR 54129)"
  ["h200-qwen-sglang"]="H200 Qwen (SGLang)"
  ["h200-qwen-sglang-pr-22121"]="H200 Qwen (SGLang) PR 22121"
  ["h200-qwen-vllm"]="H200 Qwen (vLLM)"
  ["h200-radixark-qwen-sglang"]="H200 RadixArk Qwen Flash Next (SGLang)"
  ["h200-radixark-sglang"]="H200 RadixArk (SGLang)"
  ["h200-redhat-sglang-pr-35809"]="H200 RedHat (SGLang) PR 35809"
  ["h200-redhatai-sglang"]="H200 RedHatAI (SGLang)"
  ["h200-redhatai-vllm"]="H200 RedHatAI (vLLM)"
  ["h200-stepfun-sglang"]="H200 StepFun (SGLang)"
  ["h200-stepfun-vllm"]="H200 StepFun (vLLM)"
  ["h200-xiaomimimo-flash-vllm-1ea7c63"]="H200 XiaomiMiMo Flash (vLLM 1ea7c63, audio)"
  ["h200-xiaomimimo-sglang-v0520"]="H200 XiaomiMiMo Distill (SGLang 0.5.20)"
  ["h200-xiaomimimo-vllm-v0300"]="H200 XiaomiMiMo Distill (vLLM 0.30.0)"
  ["h200-z-lab-sglang"]="H200 z-lab (SGLang)"
  ["h200-z-lab-sglang-pr-35209"]="H200 z-lab (SGLang) PR 35209"
  ["h200-z-lab-vllm"]="H200 z-lab (vLLM)"
  ["h200-zyphra-legacy-vllm"]="H200 Zyphra Legacy (vLLM)"
  ["h200-zyphra-sglang"]="H200 Zyphra (SGLang)"
  ["h200-zyphra-sglang-pr-32517"]="H200 Zyphra (SGLang) PR 32517"
  ["h200-zyphra-vllm"]="H200 Zyphra (vLLM)"
  ["rtxpro6k-allenai-vllm-73a5831127a9"]="RTX PRO 6000 AllenAI (vLLM) 73a5831127a9"
  ["rtxpro6k-allenai-vllm-73a78e6f1f38"]="RTX PRO 6000 AllenAI (vLLM) 73a78e6f1f38"
  ["rtxpro6k-arcee-ai-vllm-73a5831127a9"]="RTX PRO 6000 Arcee AI (vLLM) 73a5831127a9"
  ["rtxpro6k-arcee-ai-vllm-c8414a82712b"]="RTX PRO 6000 Arcee AI (vLLM) c8414a82712b NVFP4"
  ["rtxpro6k-coherelabs-vllm-73a5831127a9"]="RTX PRO 6000 CohereLabs (vLLM) 73a5831127a9"
  ["rtxpro6k-datalab-to-vllm-73a5831127a9"]="RTX PRO 6000 Datalab (vLLM) 73a5831127a9"
  ["rtxpro6k-deepseek-v41-vllm-pr-56509"]="RTX PRO 6000 DeepSeek V4.1 Flash (vLLM) PR 56509 SM120"
  ["rtxpro6k-glm53-vllm-2617fe938"]="RTX PRO 6000 GLM 5.3 Flash (vLLM) 2617fe938 SM120"
  ["rtxpro6k-google-sglang-1093c501dfef"]="RTX PRO 6000 Google Gemma 4 (SGLang 1093c501dfef)"
  ["rtxpro6k-google-vllm-73a5831127a9"]="RTX PRO 6000 Google Gemma (vLLM 73a5831127a9, audio)"
  ["rtxpro6k-ibm-granite-sglang-fa7784d140ee"]="RTX PRO 6000 IBM Granite (SGLang fa7784d140ee)"
  ["rtxpro6k-ibm-granite-vllm-73a5831127a9"]="RTX PRO 6000 IBM Granite (vLLM 73a5831127a9)"
  ["rtxpro6k-incoai-sglang-964c45cf3"]="RTX PRO 6000 incoai GLM-5.3 DFlash2 (SGLang 964c45cf3)"
  ["rtxpro6k-incoai-sglang-fa7784d140ee"]="RTX PRO 6000 incoai Qwen3.8 DFlash2 (SGLang fa7784d140ee)"
  ["rtxpro6k-incoai-sglang-pr-028ac64f7"]="RTX PRO 6000 incoai GLM-5.3 Flash (SGLang PR 38430, 028ac64f7)"
  ["rtxpro6k-incoai-vllm-73a583112"]="RTX PRO 6000 incoai GLM-5.3 Flash (vLLM 73a583112, b12x)"
  ["rtxpro6k-incoai-vllm-pr-417b0b6aa"]="RTX PRO 6000 incoai GLM-5.3 DFlash2 (vLLM PR 58773, 417b0b6aa)"
  ["rtxpro6k-intel-sglang"]="RTX PRO 6000 Intel (SGLang)"
  ["rtxpro6k-intel-vllm-73a5831127a9"]="RTX PRO 6000 Intel AutoRound (vLLM 73a5831127a9)"
  ["rtxpro6k-liquidai-sglang"]="RTX PRO 6000 LiquidAI (SGLang)"
  ["rtxpro6k-liquidai-sglang-pr-31041"]="RTX PRO 6000 LiquidAI (SGLang) PR 31041"
  ["rtxpro6k-mistralai-sglang-fa7784d140ee"]="RTX PRO 6000 MistralAI (SGLang fa7784d140ee)"
  ["rtxpro6k-mistralai-vllm-73a5831127a9"]="RTX PRO 6000 MistralAI (vLLM 73a5831127a9)"
  ["rtxpro6k-mistralai-vllm-pr-678ef33584da"]="RTX PRO 6000 MistralAI (vLLM PR 58172, 678ef33584da)"
  ["rtxpro6k-nanbeige-sglang"]="RTX PRO 6000 Nanbeige (SGLang)"
  ["rtxpro6k-nvidia-glm53-sglang-26fd7fd"]="RTX PRO 6000 NVIDIA GLM-5.3 NVFP4 (SGLang 26fd7fd)"
  ["rtxpro6k-nvidia-glm53flash-sglang-pr-38430"]="RTX PRO 6000 NVIDIA GLM-5.3 Flash NVFP4 (SGLang) PR 38430"
  ["rtxpro6k-nvidia-qwen38-vllm-9c2d21046"]="RTX PRO 6000 NVIDIA Qwen3.8 Flash Next NVFP4 (vLLM) 9c2d21046"
  ["rtxpro6k-nvidia-sglang-964c45cf3"]="RTX PRO 6000 NVIDIA Kimi-K2.6 NVFP4 (SGLang 964c45cf3)"
  ["rtxpro6k-nvidia-vllm-pr-39e0ce172"]="RTX PRO 6000 NVIDIA Kimi (vLLM PR 54013, 39e0ce172)"
  ["rtxpro6k-primeintellect-sglang"]="RTX PRO 6000 PrimeIntellect (SGLang)"
  ["rtxpro6k-qwen-flash-next-vllm"]="RTX PRO 6000 Qwen Flash Next (vLLM)"
  ["rtxpro6k-qwen-flash-next-vllm-pr-54129"]="RTX PRO 6000 Qwen Flash Next disk PLE (vLLM PR 54129)"
  ["rtxpro6k-qwen-sglang"]="RTX PRO 6000 Qwen (SGLang)"
  ["rtxpro6k-xiaomimimo-flash-vllm-pr-58177"]="RTX PRO 6000 XiaomiMiMo Flash (vLLM PR 58177, audio)"
  ["custom_uv"]="Custom (uv)"
  ["custom_pip"]="Custom (pip)"
)

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
        99|rtxpro6k_google_vllm_73a5831127a9|rtxpro6k-google-vllm-73a5831127a9)
            echo "rtxpro6k-google-vllm-73a5831127a9"
            ;;
        100|rtxpro6k_ibm_granite_sglang_fa7784d140ee|rtxpro6k-ibm-granite-sglang-fa7784d140ee)
            echo "rtxpro6k-ibm-granite-sglang-fa7784d140ee"
            ;;
        101|rtxpro6k_ibm_granite_vllm_73a5831127a9|rtxpro6k-ibm-granite-vllm-73a5831127a9)
            echo "rtxpro6k-ibm-granite-vllm-73a5831127a9"
            ;;
        102|rtxpro6k_incoai_sglang_964c45cf3|rtxpro6k-incoai-sglang-964c45cf3)
            echo "rtxpro6k-incoai-sglang-964c45cf3"
            ;;
        103|rtxpro6k_incoai_sglang_fa7784d140ee|rtxpro6k-incoai-sglang-fa7784d140ee)
            echo "rtxpro6k-incoai-sglang-fa7784d140ee"
            ;;
        104|rtxpro6k_incoai_sglang_pr_028ac64f7|rtxpro6k-incoai-sglang-pr-028ac64f7)
            echo "rtxpro6k-incoai-sglang-pr-028ac64f7"
            ;;
        105|rtxpro6k_incoai_vllm_73a583112|rtxpro6k-incoai-vllm-73a583112)
            echo "rtxpro6k-incoai-vllm-73a583112"
            ;;
        106|rtxpro6k_incoai_vllm_pr_417b0b6aa|rtxpro6k-incoai-vllm-pr-417b0b6aa)
            echo "rtxpro6k-incoai-vllm-pr-417b0b6aa"
            ;;
        107|rtxpro6k_intel_sglang|rtxpro6k-intel-sglang)
            echo "rtxpro6k-intel-sglang"
            ;;
        108|rtxpro6k_intel_vllm_73a5831127a9|rtxpro6k-intel-vllm-73a5831127a9)
            echo "rtxpro6k-intel-vllm-73a5831127a9"
            ;;
        109|rtxpro6k_liquidai_sglang|rtxpro6k-liquidai-sglang)
            echo "rtxpro6k-liquidai-sglang"
            ;;
        110|rtxpro6k_liquidai_sglang_pr_31041|rtxpro6k-liquidai-sglang-pr-31041)
            echo "rtxpro6k-liquidai-sglang-pr-31041"
            ;;
        111|rtxpro6k_mistralai_sglang_fa7784d140ee|rtxpro6k-mistralai-sglang-fa7784d140ee)
            echo "rtxpro6k-mistralai-sglang-fa7784d140ee"
            ;;
        112|rtxpro6k_mistralai_vllm_73a5831127a9|rtxpro6k-mistralai-vllm-73a5831127a9)
            echo "rtxpro6k-mistralai-vllm-73a5831127a9"
            ;;
        113|rtxpro6k_mistralai_vllm_pr_678ef33584da|rtxpro6k-mistralai-vllm-pr-678ef33584da)
            echo "rtxpro6k-mistralai-vllm-pr-678ef33584da"
            ;;
        114|rtxpro6k_nanbeige_sglang|rtxpro6k-nanbeige-sglang)
            echo "rtxpro6k-nanbeige-sglang"
            ;;
        115|rtxpro6k_nvidia_glm53_sglang_26fd7fd|rtxpro6k-nvidia-glm53-sglang-26fd7fd)
            echo "rtxpro6k-nvidia-glm53-sglang-26fd7fd"
            ;;
        116|rtxpro6k_nvidia_glm53flash_sglang_pr_38430|rtxpro6k-nvidia-glm53flash-sglang-pr-38430)
            echo "rtxpro6k-nvidia-glm53flash-sglang-pr-38430"
            ;;
        117|rtxpro6k_nvidia_qwen38_vllm_9c2d21046|rtxpro6k-nvidia-qwen38-vllm-9c2d21046)
            echo "rtxpro6k-nvidia-qwen38-vllm-9c2d21046"
            ;;
        118|rtxpro6k_nvidia_sglang_964c45cf3|rtxpro6k-nvidia-sglang-964c45cf3)
            echo "rtxpro6k-nvidia-sglang-964c45cf3"
            ;;
        119|rtxpro6k_nvidia_vllm_pr_39e0ce172|rtxpro6k-nvidia-vllm-pr-39e0ce172)
            echo "rtxpro6k-nvidia-vllm-pr-39e0ce172"
            ;;
        120|rtxpro6k_primeintellect_sglang|rtxpro6k-primeintellect-sglang)
            echo "rtxpro6k-primeintellect-sglang"
            ;;
        121|rtxpro6k_qwen_flash_next_vllm|rtxpro6k-qwen-flash-next-vllm)
            echo "rtxpro6k-qwen-flash-next-vllm"
            ;;
        122|rtxpro6k_qwen_flash_next_vllm_pr_54129|rtxpro6k-qwen-flash-next-vllm-pr-54129)
            echo "rtxpro6k-qwen-flash-next-vllm-pr-54129"
            ;;
        123|rtxpro6k_qwen_sglang|rtxpro6k-qwen-sglang)
            echo "rtxpro6k-qwen-sglang"
            ;;
        124|rtxpro6k_xiaomimimo_flash_vllm_pr_58177|rtxpro6k-xiaomimimo-flash-vllm-pr-58177)
            echo "rtxpro6k-xiaomimimo-flash-vllm-pr-58177"
            ;;
        125|custom|custom_uv|custom-uv|env_custom_uv)
            echo "custom_uv"
            ;;
        126|custom_pip|custom-pip|env_custom_pip)
            echo "custom_pip"
            ;;
        *)
            return 1
            ;;
    esac
}

print_env_options() {
    print_info "Available environments from installers/05_setup_env.sh:"
    local index=1
    for key in "${ENV_TYPES[@]}"; do
        printf "  %2d) %s (%s)\n" "$index" "${ENV_DESCRIPTIONS[$key]}" "$key"
        index=$((index + 1))
    done
}

normalize_env_name() {
    local raw="$1"
    raw="${raw%/}"
    raw=$(basename "$raw")
    raw="${raw#env_}"
    echo "$raw"
}

activate_environment_override() {
    local env_type="$1"
    local env_path="$HOME/env_${env_type}"
    local activate_script=""

    if [ ! -d "$env_path" ]; then
        print_error "Requested environment not found: $env_path"
        print_info "Create it first: ./installers/05_setup_env.sh env_${env_type} --auto"
        return 1
    fi

    if [ ! -x "$env_path/bin/python" ]; then
        print_error "Requested environment has no working Python interpreter: $env_path/bin/python"
        print_info "Rebuild it with: ./installers/05_setup_env.sh env_${env_type} --auto"
        return 1
    fi

    if [ -f "$env_path/activate_ml" ]; then
        activate_script="$env_path/activate_ml"
    elif [ -f "$env_path/bin/activate" ]; then
        activate_script="$env_path/bin/activate"
    else
        print_error "Requested environment has no activation script: $env_path"
        print_info "Rebuild it with: ./installers/05_setup_env.sh env_${env_type} --auto"
        return 1
    fi

    print_info "Activating requested environment: $env_path"
    if ! source "$activate_script"; then
        print_error "Failed to activate requested environment: $env_path"
        return 1
    fi

    if [ "${VIRTUAL_ENV:-}" != "$env_path" ]; then
        print_error "Activation did not select the requested environment: $env_path"
        return 1
    fi
}

detect_environment() {
    local virtual_env="${VIRTUAL_ENV:-}"
    if [ -z "$virtual_env" ]; then
        return 1
    fi

    local base
    base=$(normalize_env_name "$virtual_env")

    if resolved=$(resolve_env_type "$base"); then
        echo "$resolved"
        return 0
    fi

    for key in "${ENV_TYPES[@]}"; do
        if [[ "$virtual_env" == *"/env_${key}"* ]] || [[ "$virtual_env" == *"/$key"* ]]; then
            echo "$key"
            return 0
        fi
    done

    return 1
}

ensure_active_environment_matches() {
    local expected="$1"

    if [ -z "${VIRTUAL_ENV:-}" ]; then
        print_error "No active virtual environment detected."
        print_info "Activate the environment first: source ./launch_env.sh $expected"
        return 1
    fi

    local active=""
    if active=$(detect_environment); then
        if [ "$active" != "$expected" ]; then
            print_error "Active virtual environment is '$active', but requested '$expected'."
            print_info "Activate the requested environment first: source ./launch_env.sh $expected"
            return 1
        fi
        return 0
    fi

    print_error "Active virtual environment '$VIRTUAL_ENV' is not managed by this script."
    print_info "Activate the requested environment first: source ./launch_env.sh $expected"
    return 1
}

handle_environment() {
    local env="$1"
    local desc="${ENV_DESCRIPTIONS[$env]}"

    if [ -z "$desc" ]; then
        desc="$env"
    fi

    print_info "Environment: $desc"
}

run_command() {
    local cmd=("$@")
    print_command "$(printf '%q ' "${cmd[@]}")"
    if "${cmd[@]}"; then
        return 0
    fi
    return 1
}

run_uv_install() {
    if ! command -v uv >/dev/null 2>&1; then
        print_error "uv is not available on PATH."
        return 1
    fi

    local cmd=(uv pip install)
    cmd+=("$@")

    if run_command "${cmd[@]}"; then
        print_info "Packages installed successfully."
        return 0
    fi

    print_error "Package installation failed."
    return 1
}

run_pip_install() {
    if [ -z "${VIRTUAL_ENV:-}" ]; then
        print_error "No active virtual environment detected for pip install."
        return 1
    fi

    local python_path
    python_path=$(command -v python 2>/dev/null || true)
    if [[ "$python_path" != "$VIRTUAL_ENV/bin/python" ]]; then
        print_error "Active python is not from VIRTUAL_ENV: ${python_path:-not found}"
        print_info "Activate the expected environment first with ./launch_env.sh."
        return 1
    fi

    local cmd=(python -m pip install)
    cmd+=("$@")

    if run_command "${cmd[@]}"; then
        print_info "Packages installed successfully."
        return 0
    fi

    print_error "Package installation failed."
    return 1
}




install_arcee_deepgemm() {
    if [ -z "${VIRTUAL_ENV:-}" ]; then
        print_error "No active virtual environment detected for DeepGEMM install."
        return 1
    fi

    local vllm_ref="${1:-v0.18.0}"
    local deepgemm_installer="$VIRTUAL_ENV/install_deepgemm.sh"
    local deepgemm_installer_url="https://raw.githubusercontent.com/vllm-project/vllm/$vllm_ref/tools/install_deepgemm.sh"

    print_info "Downloading vLLM $vllm_ref DeepGEMM installer into $VIRTUAL_ENV..."
    run_command curl -fsSL "$deepgemm_installer_url" -o "$deepgemm_installer" || return 1
    run_command chmod +x "$deepgemm_installer" || return 1

    print_info "Installing vLLM $vllm_ref's pinned DeepGEMM build for Arcee..."
    # The child Bash expands its positional arguments.
    run_command env VIRTUAL_ENV="$VIRTUAL_ENV" PATH="$VIRTUAL_ENV/bin:$PATH" \
        bash -c 'cd "$1" && bash "$2"' _ "$VIRTUAL_ENV" "$deepgemm_installer" || return 1
}


install_dflash_vllm_for_environment() {
    local environment_name="$1"
    local owner_name="$2"
    local upstream_commit="31840cf3ead3632f3c99db4a24e4aba39ad54ef6"
    local proven_commit="c3dabcddc328e00990892370317d36cda31745e6"
    local binary_commit="9842d701450214d4b78cd9aefb8eee0c616bce33"
    local source_dir=""
    local actual_commit=""

    print_info "Installing the proven DFlash vLLM patchset $proven_commit for $owner_name..."
    ensure_active_environment_matches "$environment_name" || return 1
    source_dir="$VIRTUAL_ENV/vllm"

    if [ -e "$source_dir" ] && [ ! -d "$source_dir/.git" ]; then
        print_error "vLLM target exists but is not a git checkout: $source_dir"
        return 1
    fi

    if [ ! -d "$source_dir/.git" ]; then
        run_command git clone --filter=blob:none \
            https://github.com/vllm-project/vllm.git "$source_dir" || return 1
    fi

    run_command git -C "$source_dir" fetch origin \
        refs/pull/52816/head --tags || return 1
    run_command git -C "$source_dir" checkout --force "$upstream_commit" || return 1

    print_command "git -C $source_dir apply DFlash compatibility patch"
    if git -C "$source_dir" apply <<'DFLASH_VLLM_PATCH'
diff --git a/vllm/model_executor/layers/attention/attention.py b/vllm/model_executor/layers/attention/attention.py
index b4831e2a0b..cf19311915 100644
--- a/vllm/model_executor/layers/attention/attention.py
+++ b/vllm/model_executor/layers/attention/attention.py
@@ -247,6 +247,7 @@ class Attention(nn.Module, AttentionLayerBase):
         attn_type: str = AttentionType.DECODER,
         kv_sharing_target_layer_name: str | None = None,
         mm_prefix_clamp_sliding_window: bool = False,
+        use_mm_prefix: bool | None = None,
         attn_backend: type[AttentionBackend] | None = None,
         head_size_v: int | None = None,
         **extra_impl_args,
@@ -333,9 +334,15 @@ class Attention(nn.Module, AttentionLayerBase):
         self.sliding_window = sliding_window
         self.has_sink = extra_impl_args.get("sinks") is not None
 
-        # NOTE: model_config may be None during certain tests
+        # NOTE: model_config may be None during certain tests. Draft models can
+        # opt out because they process text/query tokens only and must not
+        # inherit a multimodal-prefix requirement from the target model.
         model_config = vllm_config.model_config
-        self.use_mm_prefix = model_config is not None and model_config.is_mm_prefix_lm
+        self.use_mm_prefix = (
+            model_config is not None and model_config.is_mm_prefix_lm
+            if use_mm_prefix is None
+            else use_mm_prefix
+        )
 
         # During model initialization, the default dtype is set as the model
         # weight and activation dtype.
diff --git a/vllm/model_executor/models/qwen3_dflash.py b/vllm/model_executor/models/qwen3_dflash.py
index 410204490e..aab8d8c9c8 100644
--- a/vllm/model_executor/models/qwen3_dflash.py
+++ b/vllm/model_executor/models/qwen3_dflash.py
@@ -255,6 +255,7 @@ class DFlashQwen3Attention(nn.Module):
             prefix=f"{prefix}.attn",
             attn_type=attn_type,
             sinks=self.attention_sink_bias,
+            use_mm_prefix=False,
         )
         self.causal = causal
         self.q_norm = RMSNorm(self.head_dim, eps=rms_norm_eps)
@@ -425,6 +426,13 @@ class DFlashQwen3Model(nn.Module):
             prefix=maybe_prefix(prefix, "embed_tokens"),
         )
 
+        target_config = vllm_config.model_config.hf_text_config
+        self.embed_normalizer: float | None = None
+        if str(getattr(target_config, "model_type", "")).startswith("gemma4"):
+            # Gemma4 scales token embeddings by sqrt(hidden_size). DFlash
+            # shares the target embeddings, so the draft path must match.
+            self.embed_normalizer = target_config.hidden_size**0.5
+
         # Masked query slots are fed to the draft as `mask_token_id`. Most DFlash
         # checkpoints will have the mask embedding in the vocabulary embedding table
         # at that slot id. Some checkpoints (XiaomiMiMo/MiMo-V2.5-Pro-FP4-DFlash) ship
@@ -477,6 +485,8 @@ class DFlashQwen3Model(nn.Module):
             # Replace masked slots with the dedicated mask embedding.
             is_mask = (input_ids == self.mask_token_id).unsqueeze(-1)
             embeds = torch.where(is_mask, self.mask_embedding.to(embeds.dtype), embeds)
+        if self.embed_normalizer is not None:
+            embeds = embeds * self.embed_normalizer
         return embeds
 
     def _build_context_kv_buffers(
@@ -728,7 +738,9 @@ class DFlashQwen3ForCausalLM(Qwen3ForCausalLM):
             prefix=maybe_prefix(prefix, "lm_head"),
         )
         self.logits_processor = LogitsProcessor(
-            self.config.draft_vocab_size, scale=logit_scale
+            self.config.draft_vocab_size,
+            scale=logit_scale,
+            soft_cap=getattr(self.config, "final_logit_softcapping", None),
         )
         target_vocab_size = vllm_config.model_config.get_vocab_size()
         if self.config.draft_vocab_size != target_vocab_size:
diff --git a/vllm/v1/attention/backends/triton_attn.py b/vllm/v1/attention/backends/triton_attn.py
index 4b1c167e7f..014a390dba 100644
--- a/vllm/v1/attention/backends/triton_attn.py
+++ b/vllm/v1/attention/backends/triton_attn.py
@@ -119,8 +119,8 @@ class TritonAttentionMetadataBuilder(AttentionMetadataBuilder[TritonAttentionMet
         self.num_heads_q = get_num_attention_heads_from_layers(
             vllm_config, layer_names
         ) or model_config.get_num_attention_heads(vllm_config.parallel_config)
-        self.num_heads_kv = model_config.get_num_kv_heads(vllm_config.parallel_config)
-        self.headdim = model_config.get_head_size()
+        self.num_heads_kv = kv_cache_spec.num_kv_heads
+        self.headdim = kv_cache_spec.head_size
 
         # Check if CUDA Graphs are enabled for decode
         self.decode_cudagraph_enabled = (
DFLASH_VLLM_PATCH
    then
        :
    else
        print_error "Failed to apply the proven DFlash vLLM compatibility patch."
        return 1
    fi

    run_command git -C "$source_dir" add \
        vllm/model_executor/layers/attention/attention.py \
        vllm/model_executor/models/qwen3_dflash.py \
        vllm/v1/attention/backends/triton_attn.py || return 1

    run_command env \
        "GIT_AUTHOR_NAME=OMP Integration" \
        "GIT_AUTHOR_EMAIL=omp@localhost" \
        "GIT_AUTHOR_DATE=2026-08-19T14:39:58+00:00" \
        "GIT_COMMITTER_NAME=OMP Integration" \
        "GIT_COMMITTER_EMAIL=omp@localhost" \
        "GIT_COMMITTER_DATE=2026-08-19T14:39:58+00:00" \
        git -C "$source_dir" commit --no-gpg-sign \
        -m "Port Gemma4 DFlash fixes onto DFlash2 branch" || return 1

    actual_commit=$(git -C "$source_dir" rev-parse HEAD) || return 1
    if [ "$actual_commit" != "$proven_commit" ]; then
        print_error "Recreated DFlash vLLM commit is $actual_commit; expected $proven_commit."
        return 1
    fi

    VLLM_USE_PRECOMPILED=1 \
        VLLM_PRECOMPILED_WHEEL_COMMIT="$binary_commit" \
        run_uv_install -U --reinstall --prerelease=allow \
        -e "$source_dir" --torch-backend=auto || return 1

    install_flashinfer_python311_compatible || return 1
}

install_flashinfer_python311_compatible() {
    local incompatible_package

    if ! python -c 'import sys; raise SystemExit(0 if sys.version_info < (3, 12) else 1)'; then
        return 0
    fi

    print_info "Installing FlashInfer 0.6.17 for Python 3.10/3.11 annotation compatibility..."
    run_uv_install --upgrade --no-deps "flashinfer-python==0.6.17" || return 1

    for incompatible_package in flashinfer-cubin flashinfer-jit-cache; do
        if python -c 'import importlib.metadata as m, sys; m.version(sys.argv[1])' \
            "$incompatible_package" >/dev/null 2>&1; then
            print_info "Removing incompatible $incompatible_package companion package..."
            run_command uv pip uninstall "$incompatible_package" || return 1
        fi
    done
}


install_pinned_sglang_commit() {
    local expected_env="$1"
    local description="$2"
    local repository="$3"
    local commit="$4"

    ensure_active_environment_matches "$expected_env" || return 1
    print_info "Installing $description..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+$repository@$commit#subdirectory=python" || return 1
}


install_vllm_pinned_commit_python311_compatible() {
    local source_commit="52be12cfac0c5a18ba906814b2d2bcadb40a9c4b"
    local source_dir=""

    if [ -z "${VIRTUAL_ENV:-}" ]; then
        print_error "No active virtual environment detected for the vLLM source checkout."
        return 1
    fi
    source_dir="$VIRTUAL_ENV/vllm"

    if [ -e "$source_dir" ] && [ ! -d "$source_dir/.git" ]; then
        print_error "vLLM target exists but is not a git checkout: $source_dir"
        return 1
    fi

    if [ ! -d "$source_dir/.git" ]; then
        run_command git clone https://github.com/vllm-project/vllm.git \
            "$source_dir" || return 1
    fi

    run_command git -C "$source_dir" fetch origin --tags || return 1
    run_command git -C "$source_dir" checkout --force "$source_commit" || return 1

    print_info "Installing pinned GitHub commit $source_commit from $source_dir..."
    VLLM_USE_PRECOMPILED=1 \
        VLLM_PRECOMPILED_WHEEL_COMMIT="$source_commit" \
        run_uv_install -U --reinstall --prerelease=allow \
        -e "$source_dir" --torch-backend=auto || return 1

    install_flashinfer_python311_compatible || return 1
}

install_vllm_pr_54479() {
    ensure_active_environment_matches "$1" || return 1
    # Upstream PR https://github.com/vllm-project/vllm/pull/54479 separates compilation from KV-memory profiling.
    local source_commit="22f931fe2177912ddf33e5a033948473fe9720f2"
    # This Python-only PR uses unmodified binaries from its exact upstream merge base.
    local wheel_url="https://wheels.vllm.ai/144e79c8106da23141ac010394b782f730cc7fe8/vllm-0.28.1rc1.dev452%2Bg144e79c81-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing upstream vLLM PR 54479 at ${source_commit}..."
    VLLM_USE_PRECOMPILED=1 \
        VLLM_PRECOMPILED_WHEEL_LOCATION="${wheel_url}" \
        run_uv_install -U --reinstall --prerelease=allow \
        "vllm @ git+https://github.com/vllm-project/vllm.git@${source_commit}" \
        --torch-backend=cu130 || return 1
}













install_h200_allenai_vllm() {
    print_info "Installing the pinned GitHub vLLM commit for AllenAI..."
    install_vllm_pinned_commit_python311_compatible || return 1
}

install_h200_arcee_nvfp4_vllm() {
    print_info "Installing vLLM 0.18.0 for Arcee NVFP4..."
    run_uv_install -U "vllm==0.18.0" || return 1
    install_arcee_deepgemm "v0.18.0" || return 1
}

install_h200_arcee_vllm() {
    print_info "Installing the pinned GitHub vLLM commit for Arcee..."
    install_vllm_pinned_commit_python311_compatible || return 1
    install_arcee_deepgemm "52be12cfac0c5a18ba906814b2d2bcadb40a9c4b" || return 1
}

install_h200_cohere_vllm() {
    print_info "Installing the pinned GitHub vLLM commit and Cohere Melody for Cohere..."
    install_vllm_pinned_commit_python311_compatible || return 1
    run_uv_install "transformers>=5,<6" || return 1
    run_uv_install "cohere_melody>=0.9.0" || return 1
}

install_h200_cohere_vllm_pr_54479() {
    install_vllm_pr_54479 "h200-cohere-vllm-pr-54479" || return 1
    run_uv_install "transformers==5.17.0" || return 1
    run_uv_install "cohere_melody==0.13.4" || return 1
}

install_h200_datalab_vllm() {
    print_info "Installing the pinned GitHub vLLM commit for DataLab..."
    install_vllm_pinned_commit_python311_compatible || return 1
}

install_h200_deepseek_sglang() {
    print_info "Installing SGLang 0.5.16 for DeepSeek..."
    run_uv_install -U --prerelease=allow "sglang[all]==0.5.16" || return 1
}

install_h200_deepseek_v41_vllm_e77daef89() {
    ensure_active_environment_matches "h200-deepseek-v41-vllm-e77daef89" || return 1
    # Native DeepSeek V4.1 support: https://github.com/vllm-project/vllm/pull/56214
    local source_commit="e77daef89e18e08321ae7b8b24827eedd5fe8673"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.1.1.dev5%2Bge77daef89-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the official DeepSeek V4.1 vLLM e77daef89 wheel..."
    run_uv_install -U --reinstall --prerelease=allow \
        "vllm @ ${wheel_url}" "uvicorn==0.53.0" --torch-backend=cu130 || return 1
    # Required by the pinned CUDA manifest; this cubin release is not published on PyPI.
    run_uv_install \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18.post1/flashinfer_cubin-0.6.18.post1-py3-none-any.whl#sha256=bbacb5b8bbf429e43bf2740bb45551d981f41d0462842e36ee6fb3e3452763ab" || return 1
}

install_h200_deepseek_vision_sglang_pr_37253() {
    ensure_active_environment_matches "h200-deepseek-vision-sglang-pr-37253" || return 1
    # Native Vision and bundled DSpark: https://github.com/sgl-project/sglang/pull/37253
    local source_commit="d5a3b7725374070669f4d23c1e99e186f4dfc309"
    print_info "Installing upstream DeepSeek Vision SGLang PR 37253 at ${source_commit}..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang @ git+https://github.com/sgl-project/sglang.git@${source_commit}#subdirectory=python" \
        --torch-backend=cu130 || return 1
}

install_h200_deepseek_vision_vllm_pr_54566() {
    ensure_active_environment_matches "h200-deepseek-vision-vllm-pr-54566" || return 1
    # Native Vision CUDA support: https://github.com/vllm-project/vllm/pull/54566
    # Official merge: 1356635d837c4ef002ec98c1a0296e7ff60be3c1; PR head: 047c353c99a6ab5f2ad09a70c3ccc6aa67deddfc.
    local wheel_url="https://wheels.vllm.ai/1356635d837c4ef002ec98c1a0296e7ff60be3c1/vllm-0.28.1rc1.dev317%2Bg1356635d8-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the official DeepSeek Vision vLLM PR 54566 merge wheel..."
    run_uv_install -U --reinstall --prerelease=allow \
        "vllm @ ${wheel_url}" --torch-backend=cu130 || return 1
    # Required by the pinned CUDA manifest; this cubin release is not published on PyPI.
    run_uv_install \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18/flashinfer_cubin-0.6.18-py3-none-any.whl#sha256=2dd65c0fcfc6bc44c67f148530de5372979c2e3d260e47935730f94156d4d873" || return 1
}

install_h200_deepseek_vllm() {
    print_info "Installing vLLM 0.25.0 for DeepSeek..."
    run_uv_install "vllm==0.25.0" || return 1
}

install_h200_diffusiongemma_sglang() {
    print_info "Installing the DiffusionGemma SGLang commit..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@11ffa55479124f85aabeb6db264c3b337395a55d#subdirectory=python" || return 1
    run_uv_install --force-reinstall --no-deps "transformers==5.12.1" || return 1
}

install_h200_gemma_sglang() {
    print_info "Installing the tested Gemma SGLang commit..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@f7d4e44d82ac35b9b10ce80348e4a5421f89435a#subdirectory=python" || return 1
    run_uv_install "git+https://github.com/huggingface/transformers.git@1423d22f7a3b62e8c70ad67b58ec25cd9b675897" || return 1
}

install_h200_gemma_vllm() {
    print_info "Installing the pinned GitHub vLLM commit for Gemma..."
    install_vllm_pinned_commit_python311_compatible || return 1
}

install_h200_gemma3n_vllm() {
    print_info "Installing the model-card validated vLLM stack for Gemma 3n..."
    ensure_active_environment_matches h200-gemma3n-vllm || return 1
    run_uv_install --upgrade --reinstall \
        "vllm==0.10.0" \
        "transformers==4.53.2" \
        "numpy==2.2.6" \
        "timm" \
        --torch-backend=auto || return 1
}

install_h200_glm53_vllm_v0290() {
    ensure_active_environment_matches "h200-glm53-vllm-v0290" || return 1
    # Official GLM-5.3 recipe requires vLLM 0.28.0+ and Transformers 5.15.0+.
    print_info "Installing official vLLM 0.29.0 for GLM 5.3..."
    run_uv_install -U --reinstall \
        "vllm==0.29.0" "transformers==5.15.0" "tokenizers==0.22.2" \
        --index-url https://pypi.org/simple --torch-backend=cu130 || return 1
    run_uv_install \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18/flashinfer_cubin-0.6.18-py3-none-any.whl#sha256=2dd65c0fcfc6bc44c67f148530de5372979c2e3d260e47935730f94156d4d873" \
        "flashinfer-jit-cache @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18/flashinfer_jit_cache-0.6.18+cu130-cp39-abi3-manylinux_2_28_x86_64.whl#sha256=428a47a554ade93c30a818e142b781df58582bf056bab94611fb4c906cc366bf" || return 1
    run_uv_install --no-deps "nvidia-cudnn-cu13==9.26.0.51" || return 1
}

install_h200_glm53flash_dflash2_sglang_pr_37818() {
    ensure_active_environment_matches "h200-glm53flash-dflash2-sglang-pr-37818" || return 1
    # Native DFlash Mamba checkpoint tracking: https://github.com/sgl-project/sglang/pull/37818
    # Official test merge retains GLM5Next support; PR head: df464a48213f5e40e29c7453a7db07880435f777.
    local source_commit="787299797931749c8f9bb15453f375bd1f9bed5c"
    print_info "Installing upstream SGLang PR 37818 test merge at ${source_commit}..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang @ git+https://github.com/sgl-project/sglang.git@${source_commit}#subdirectory=python" \
        --torch-backend=cu130 || return 1
    # Native GLM5Next image/video processors need the newer HF stack.
    # SGLang's declared pins lag this integration: https://github.com/sgl-project/sglang/pull/38522
    run_uv_install --force-reinstall --no-deps \
        "transformers==5.17.0" "tokenizers==0.23.2" || return 1
    # Keep native BF16 vision convolutions on a matching cuDNN sublibrary set.
    run_uv_install --no-deps "nvidia-cudnn-cu13==9.26.0.51" || return 1
}

install_h200_glm53flash_dflash2_vllm_pr_55423() {
    ensure_active_environment_matches "h200-glm53flash-dflash2-vllm-pr-55423" || return 1
    # Native DFlash2/mHC and hybrid draft-cache integration: https://github.com/vllm-project/vllm/pull/55423
    local source_commit="374e367e2b87ee65332b03468b76dc4c40e69519"
    # This Python-only PR uses unmodified binaries from its exact upstream parent.
    local wheel_url="https://wheels.vllm.ai/c81ace18596f75660bbc04efc2075a5f17a76791/vllm-0.28.1rc1.dev420%2Bgc81ace185-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing native vLLM Flash DFlash2 PR 55423 at ${source_commit}..."
    VLLM_USE_PRECOMPILED=1 \
        VLLM_PRECOMPILED_WHEEL_LOCATION="${wheel_url}" \
        run_uv_install -U --reinstall --prerelease=allow \
        "vllm @ git+https://github.com/vllm-project/vllm.git@${source_commit}" \
        --torch-backend=cu130 || return 1
    run_uv_install \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18/flashinfer_cubin-0.6.18-py3-none-any.whl#sha256=2dd65c0fcfc6bc44c67f148530de5372979c2e3d260e47935730f94156d4d873" \
        "flashinfer-jit-cache @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18/flashinfer_jit_cache-0.6.18+cu130-cp39-abi3-manylinux_2_28_x86_64.whl#sha256=428a47a554ade93c30a818e142b781df58582bf056bab94611fb4c906cc366bf" || return 1
    # Torch's 9.20 wheel loads the host's 9.26 tensor-IR sublibrary during BF16 Conv2d.
    # Keep the native cuDNN sublibraries aligned; this overrides Torch's exact 9.20 pin.
    run_uv_install --no-deps "nvidia-cudnn-cu13==9.26.0.51" || return 1
}

install_h200_glm53flash_vllm_pr_53906() {
    ensure_active_environment_matches "h200-glm53flash-vllm-pr-53906" || return 1
    # Native GLM-5.3-Flash integration: https://github.com/vllm-project/vllm/pull/53906
    # Official merge commit: 98ed0856f31fa3aaf5e27464e2b4ef5a8ee6b2f5.
    local wheel_url="https://wheels.vllm.ai/98ed0856f31fa3aaf5e27464e2b4ef5a8ee6b2f5/vllm-0.28.1rc1.dev359%2Bg98ed0856f-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the official vLLM GLM-5.3-Flash PR 53906 merge wheel..."
    run_uv_install -U --reinstall --prerelease=allow         "vllm @ ${wheel_url}" --torch-backend=cu130 || return 1
    run_uv_install         "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18/flashinfer_cubin-0.6.18-py3-none-any.whl#sha256=2dd65c0fcfc6bc44c67f148530de5372979c2e3d260e47935730f94156d4d873"         "flashinfer-jit-cache @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18/flashinfer_jit_cache-0.6.18+cu130-cp39-abi3-manylinux_2_28_x86_64.whl#sha256=428a47a554ade93c30a818e142b781df58582bf056bab94611fb4c906cc366bf" || return 1
    # Keep native BF16 vision convolutions on a matching cuDNN sublibrary set.
    run_uv_install --no-deps "nvidia-cudnn-cu13==9.26.0.51" || return 1
}

install_h200_gptoss_sglang() {
    print_info "Installing the pinned SGLang main commit for GPT-OSS..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@834400705f2de2378a327121340f57e324ca5a36#subdirectory=python" || return 1
}

install_h200_gptoss_vllm() {
    print_info "Installing the pinned GitHub vLLM commit for GPT-OSS..."
    install_vllm_pinned_commit_python311_compatible || return 1
}

install_h200_ibm_sglang() {
    print_info "Installing SGLang 0.5.18 for IBM Granite..."
    run_uv_install -U --prerelease=allow "sglang[all]==0.5.18" || return 1
}

install_h200_ibm_vllm() {
    print_info "Installing vLLM 0.25.0 for IBM Granite..."
    run_uv_install "vllm==0.25.0" || return 1
}

install_h200_inclusionai_ling3_vllm() {
    print_info "Installing upstream vLLM 0.29.0 with native Ling 3 support..."
    run_uv_install --upgrade --reinstall \
        "vllm==0.29.0" --index-url https://pypi.org/simple --torch-backend=cu130 || return 1
}

install_h200_inclusionai_sglang() {
    print_info "Installing the validated Ling 3.0 SGLang commit..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@e1a24a189fe4164596c3a6472e96715717df9012#subdirectory=python" || return 1
}

install_h200_inclusionai_vllm() {
    local vllm_version="0.27.2rc1.dev113+g5cecfc013"
    local vllm_wheel="https://wheels.vllm.ai/5cecfc01375052698823fc401e31518fb32a981e/vllm-0.27.2rc1.dev113%2Bg5cecfc013-cp38-abi3-manylinux_2_28_x86_64.whl#sha256=7858cbbd1fbf426a6eac5a9e2dc3779e04ee63705f65c90ab5baca4705a4a638"

    print_info "Installing vLLM $vllm_version for InclusionAI from its immutable commit wheel..."
    run_uv_install --upgrade --reinstall --prerelease=allow \
        "$vllm_wheel" --torch-backend=auto || return 1
    install_flashinfer_python311_compatible || return 1
}

install_h200_incoai_sglang() {
    install_pinned_sglang_commit \
        "h200-incoai-sglang" \
        "IncoAI (SGLang) commit 05c584c44fb0450c894cf9d08a7827c10cd5b2c5" \
        "https://github.com/sgl-project/sglang.git" \
        "05c584c44fb0450c894cf9d08a7827c10cd5b2c5" || return 1
    run_uv_install "transformers==5.12.1" || return 1
}

install_h200_incoai_vllm() {
    install_dflash_vllm_for_environment "h200-incoai-vllm" "IncoAI" || return 1
}

install_h200_intel_sglang() {
    install_pinned_sglang_commit \
        "h200-intel-sglang" \
        "Intel (SGLang) commit f7d4e44d82ac35b9b10ce80348e4a5421f89435a" \
        "https://github.com/sgl-project/sglang.git" \
        "f7d4e44d82ac35b9b10ce80348e4a5421f89435a" || return 1
    run_uv_install \
        "git+https://github.com/huggingface/transformers.git@1423d22f7a3b62e8c70ad67b58ec25cd9b675897" || return 1
}


install_h200_intel_vllm() {
    print_info "Installing the pinned GitHub vLLM commit for Intel..."
    install_vllm_pinned_commit_python311_compatible || return 1
}

install_h200_liquidai_sglang() {
    print_info "Installing the pinned SGLang main commit for LiquidAI..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@05c584c44fb0450c894cf9d08a7827c10cd5b2c5#subdirectory=python" || return 1
}

install_h200_liquidai_sglang_pr_31041() {
    install_pinned_sglang_commit \
        "h200-liquidai-sglang-pr-31041" \
        "LiquidAI (SGLang) PR 31041 commit c26ae043924fffe413df8a90329f8734869d7fd1" \
        "https://github.com/tugot17/sglang.git" \
        "c26ae043924fffe413df8a90329f8734869d7fd1"
}

install_h200_liquidai_vllm() {
    print_info "Installing the pinned GitHub vLLM commit for LiquidAI..."
    install_vllm_pinned_commit_python311_compatible || return 1
}

install_h200_meta_sglang() {
    print_info "Installing the pinned SGLang main commit for Meta..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@05c584c44fb0450c894cf9d08a7827c10cd5b2c5#subdirectory=python" || return 1
}

install_h200_meta_vllm() {
    local vllm_version="0.27.2rc1.dev113+g5cecfc013"
    local vllm_wheel="https://wheels.vllm.ai/5cecfc01375052698823fc401e31518fb32a981e/vllm-0.27.2rc1.dev113%2Bg5cecfc013-cp38-abi3-manylinux_2_28_x86_64.whl#sha256=7858cbbd1fbf426a6eac5a9e2dc3779e04ee63705f65c90ab5baca4705a4a638"

    print_info "Installing vLLM $vllm_version for Meta from its immutable commit wheel..."
    ensure_active_environment_matches h200-meta-vllm || return 1
    run_uv_install --upgrade --reinstall --prerelease=allow \
        "$vllm_wheel" --torch-backend=auto || return 1
    install_flashinfer_python311_compatible || return 1
    run_uv_install timm || return 1
}

install_h200_microsoft_vllm() {
    print_info "Installing the pinned GitHub vLLM commit for Microsoft..."
    install_vllm_pinned_commit_python311_compatible || return 1
}

install_h200_minimax_m2_sglang_v0510_post1() {
    ensure_active_environment_matches "h200-minimax-m2-sglang-v0510-post1" || return 1
    # Official v0.5.10.post1: 7c35342c10e201899e22fe2972d40e60da19ff3e.
    # Includes the native MiniMax partial-RoPE fix for Transformers 5.
    # This required TorchAO release is on PyPI, not the selected PyTorch CUDA index.
    local torchao_wheel="https://files.pythonhosted.org/packages/7d/fe/a24225d30775192a4c5d9cea3ecb95e6adc69d0a8b5ed98eb8e58d362344/torchao-0.9.0-cp39-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.manylinux_2_28_x86_64.whl#sha256=bc708910301a9f98344d43f3fe2aa6d5e1fab706d772b6df47ff05087d664145"
    print_info "Installing official SGLang 0.5.10.post1 for MiniMax M2..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang==0.5.10.post1" "torchao @ ${torchao_wheel}" --torch-backend=cu128 || return 1
}

install_h200_minimax_m2_vllm_0f3ce4c74() {
    ensure_active_environment_matches "h200-minimax-m2-vllm-0f3ce4c74" || return 1
    # Accuracy-verified official MiniMax recipe commit: 0f3ce4c74b1875791d6604e006b6e905fde9f698.
    # https://docs.vllm.ai/projects/recipes/en/latest/MiniMax/MiniMax-M2.html
    local wheel_url="https://wheels.vllm.ai/0f3ce4c74b1875791d6604e006b6e905fde9f698/vllm-0.19.1rc1.dev203%2Bg0f3ce4c74-cp38-abi3-manylinux_2_31_x86_64.whl"
    print_info "Installing the official MiniMax vLLM 0f3ce4c74 wheel..."
    # CUDA bindings 13.4 removed IPC handle fields used by the native Lamport workspace.
    # https://github.com/smg-project/smg/pull/2494 validates the compatible 13.3.1 pin.
    run_uv_install -U --reinstall --prerelease=allow \
        "vllm @ ${wheel_url}" wheel "cuda-python==13.3.1" "cuda-bindings==13.3.1" \
        --torch-backend=cu130 || return 1
    # Exact upstream ref from this vLLM commit's tools/install_deepgemm.sh.
    # The wheel's vendored extension is CPython 3.12-only; build for the active interpreter.
    local source_dir
    source_dir=$(mktemp -d -t minimax-m2-deepgemm.XXXXXX) || return 1
    (
        trap 'rm -rf "$source_dir"' EXIT
        run_command git clone --filter=blob:none --no-checkout \
            https://github.com/deepseek-ai/DeepGEMM.git "$source_dir" || exit 1
        run_command git -C "$source_dir" checkout --detach \
            477618cd51baffca09c4b0b87e97c03fe827ef03 || exit 1
        run_command git -C "$source_dir" submodule update --init --recursive --depth 1 || exit 1
        run_uv_install --no-build-isolation --no-deps "$source_dir"
    ) || return 1
}

install_h200_minimax_m25_vllm_v0280() {
    ensure_active_environment_matches "h200-minimax-m25-vllm-v0280" || return 1
    # Official H200 recipe: https://recipes.vllm.ai/MiniMaxAI/MiniMax-M2.5/hw/h200.json
    # v0.28.0: 2cf0a6915ce544dc493a0990f2ea38d81601128a.
    # CUDA bindings 13.4 removed IPC handle fields used by native MiniMax Lamport QK norm.
    # https://github.com/smg-project/smg/pull/2494 validates the compatible 13.3.1 pin.
    print_info "Installing official vLLM 0.28.0 for MiniMax M2.5..."
    run_uv_install -U --reinstall \
        "vllm==0.28.0" "cuda-python==13.3.1" "cuda-bindings==13.3.1" \
        --index-url https://pypi.org/simple --torch-backend=cu130 || return 1
    # FlashInfer 0.6.17 fixes Python 3.10/3.11 imports; vLLM's exact 0.6.16.post3 pin is affected.
    # https://github.com/flashinfer-ai/flashinfer/pull/4354; runtime dependencies are unchanged.
    run_uv_install --upgrade --no-deps "flashinfer-python==0.6.17" || return 1
}

install_h200_mistralai_sglang() {
    install_pinned_sglang_commit \
        "h200-mistralai-sglang" \
        "MistralAI (SGLang) commit dd15fb57b5ef7d13419f92ddc9b241591b71c0b5" \
        "https://github.com/sgl-project/sglang.git" \
        "dd15fb57b5ef7d13419f92ddc9b241591b71c0b5"
}

install_h200_mistralai_vllm() {
    print_info "Installing the pinned GitHub vLLM commit for MistralAI..."
    install_vllm_pinned_commit_python311_compatible || return 1
}



install_h200_nanbeige_sglang() {
    local source_commit="3e59d89e53490d3b6957cb72754abf6a98c2b8a8"
    print_info "Installing the pinned Nanbeige SGLang fork commit $source_commit..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/Nanbeige/sglang.git@${source_commit}#subdirectory=python" || return 1
}

install_h200_nanbeige_vllm() {
    local source_commit="62f6de733d7ae63b759329993bc209e67afdf431"

    print_info "Installing the proven Nanbeige vLLM commit $source_commit..."
    ensure_active_environment_matches h200-nanbeige-vllm || return 1

    local target_dir="$VIRTUAL_ENV/vllm"

    if [ -e "$target_dir" ] && [ ! -d "$target_dir/.git" ]; then
        print_error "vLLM target exists but is not a git checkout: $target_dir"
        return 1
    fi

    if [ ! -d "$target_dir/.git" ]; then
        run_command git clone -b nanbeige42 \
            https://github.com/Nanbeige/vllm.git "$target_dir" || return 1
    fi

    run_command git -C "$target_dir" fetch origin nanbeige42 --tags || return 1
    run_command git -C "$target_dir" checkout --force "$source_commit" || return 1

    run_pip_install -e "$target_dir" || return 1
}



install_h200_nemotron_ultra_vllm_9c2d21046() {
    ensure_active_environment_matches "h200-nemotron-ultra-vllm-9c2d21046" || return 1
    # Complete upstream PR54788 merge: native V2 draft MoE backend isolation.
    # https://github.com/vllm-project/vllm/pull/54788
    local source_commit="9c2d21046bb39f56ee93a5fab4f899714a5579ef"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.28.1rc1.dev562%2Bg9c2d21046-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing native Nemotron Ultra vLLM PR54788 merge..."
    run_uv_install -U --prerelease=allow \
        "vllm @ ${wheel_url}" "transformers==5.12.1" "tokenizers==0.22.2" \
        --index-url https://pypi.org/simple --torch-backend=cu130 || return 1
    # Released CUDA requirements keep FlashInfer cubin outside PyPI install_requires.
    run_uv_install \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18/flashinfer_cubin-0.6.18-py3-none-any.whl#sha256=2dd65c0fcfc6bc44c67f148530de5372979c2e3d260e47935730f94156d4d873" || return 1
}

install_h200_nex_n2_sglang_v0519() {
    ensure_active_environment_matches "h200-nex-n2-sglang-v0519" || return 1
    # Native Qwen3.5 MoE backend for Nex-N2: https://github.com/nex-agi/Nex-N2.
    # SGLang v0.5.19: 0bcd822377da7b5718e674eaf9c870d349424dd1; CPython 3.11 wheels.
    # NVIDIA publishes the required cuda-tile RC wheel outside its PyPI sdist listing.
    print_info "Installing official SGLang 0.5.19 for Nex N2..."
    run_uv_install -U --reinstall \
        'sglang @ https://files.pythonhosted.org/packages/97/f3/53f3a6c074be264bb389bb7e620fb99c26950a0f452a5d1415e5c5f58af9/sglang-0.5.19-cp311-cp311-manylinux_2_34_x86_64.whl#sha256=425e87377e725d03db8262382008f3fd9561a6cf5d82f485f8b9929f02ffe12b' \
        'cuda-tile @ https://pypi.nvidia.com/cuda-tile/cuda_tile-1.6.0rc5-cp311-cp311-manylinux2014_x86_64.whl#sha256=a14ff257522a017430e98f16aabdfd514bbcf38ecb64a0fba1d3f86cd02a21bb' \
        'torchvision==0.28.0' \
        --index-url https://pypi.org/simple --torch-backend=cu130 || return 1
    # Keep native BF16 vision convolutions on the host-matched cuDNN 9.26 family.
    # This source-backed repair overrides Torch's 9.20 pin: pytorch/pytorch#188892.
    run_uv_install --no-deps "nvidia-cudnn-cu13==9.26.0.51" || return 1
}

install_h200_nex_n2_vllm_v0290() {
    ensure_active_environment_matches "h200-nex-n2-vllm-v0290" || return 1
    # Native Nex-N2/Qwen3.5 MoE and incremental tools: vLLM v0.29.0.
    # Upstream commit: 98dff2a81d747d1dba01a47f939f48c3526d4206.
    print_info "Installing official vLLM 0.29.0 for Nex N2..."
    run_uv_install -U --reinstall \
        "vllm==0.29.0" "transformers==5.12.1" "tokenizers==0.22.2" \
        --index-url https://pypi.org/simple --torch-backend=cu130 || return 1
    run_uv_install \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18/flashinfer_cubin-0.6.18-py3-none-any.whl#sha256=2dd65c0fcfc6bc44c67f148530de5372979c2e3d260e47935730f94156d4d873" \
        "flashinfer-jit-cache @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18/flashinfer_jit_cache-0.6.18+cu130-cp39-abi3-manylinux_2_28_x86_64.whl#sha256=428a47a554ade93c30a818e142b781df58582bf056bab94611fb4c906cc366bf" || return 1
    # Preserve native Conv3d with version-aligned cuDNN sublibraries.
    # This source-backed repair overrides Torch's 9.20 pin: pytorch/pytorch#188892.
    run_uv_install --no-deps "nvidia-cudnn-cu13==9.26.0.51" || return 1
}

install_h200_nvidia_deepseek_sglang() {
    print_info "Installing SGLang 0.5.16 for NVIDIA DeepSeek..."
    run_uv_install -U --prerelease=allow "sglang[all]==0.5.16" || return 1
}

install_h200_nvidia_glm53_sglang_26fd7fd() {
    ensure_active_environment_matches "h200-nvidia-glm53-sglang-26fd7fd" || return 1
    print_info "Installing the validated SGLang commit for NVIDIA GLM-5.3 NVFP4..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@26fd7fdaa2732abbad6d63b21cf0944aa88e977e#subdirectory=python" \
        "compressed-tensors==0.19.1a20260923" || return 1
}

install_h200_nvidia_muse_sglang_v0520() {
    ensure_active_environment_matches "h200-nvidia-muse-sglang-v0520" || return 1
    print_info "Installing official SGLang 0.5.20 for NVIDIA Muse Glimmer..."
    run_uv_install "sglang[all]==0.5.20" "mistral-common==1.11.7" --prerelease=allow || return 1
}

install_h200_nvidia_muse_vllm_v0290() {
    ensure_active_environment_matches "h200-nvidia-muse-vllm-v0290" || return 1
    print_info "Installing official vLLM 0.29.0 for NVIDIA Muse Glimmer..."
    run_uv_install "vllm==0.29.0" "mistral-common==1.11.7" --torch-backend=cu130 || return 1
}

install_h200_nvidia_nemotron() {
    print_info "Installing the pinned GitHub vLLM commit for NVIDIA Nemotron..."
    install_vllm_pinned_commit_python311_compatible || return 1

    if [ -z "${VIRTUAL_ENV:-}" ]; then
        print_error "No active virtual environment detected for DeepGEMM install."
        return 1
    fi

    local deepgemm_installer="$VIRTUAL_ENV/install_deepgemm.sh"
    local deepgemm_installer_url="https://raw.githubusercontent.com/vllm-project/vllm/v0.20.0/tools/install_deepgemm.sh"

    print_info "Installing the proven vLLM 0.20.0 DeepGEMM companion build for NVIDIA Nemotron..."
    run_command curl -fsSL "$deepgemm_installer_url" -o "$deepgemm_installer" || return 1
    run_command env VIRTUAL_ENV="$VIRTUAL_ENV" PATH="$VIRTUAL_ENV/bin:$PATH" \
        bash "$deepgemm_installer" || return 1
}

install_h200_nvidia_sglang() {
    install_pinned_sglang_commit \
        "h200-nvidia-sglang" \
        "NVIDIA (SGLang) commit dd15fb57b5ef7d13419f92ddc9b241591b71c0b5" \
        "https://github.com/sgl-project/sglang.git" \
        "dd15fb57b5ef7d13419f92ddc9b241591b71c0b5" || return 1
    run_uv_install librosa || return 1
}

install_h200_nvidia_sglang_pr_33554() {
    install_pinned_sglang_commit \
        "h200-nvidia-sglang-pr-33554" \
        "NVIDIA (SGLang) PR 33554 commit ccfcdd93a8c21b21d37b6036f3071ff2d9171f9b" \
        "https://github.com/rystewart-nvidia/sglang.git" \
        "ccfcdd93a8c21b21d37b6036f3071ff2d9171f9b" || return 1
    run_uv_install librosa || return 1
}

install_h200_nvidia_vllm() {
    print_info "Installing the pinned GitHub vLLM commit for NVIDIA..."
    install_vllm_pinned_commit_python311_compatible || return 1
}

install_h200_nvidia_vllm_pr_55222() {
    ensure_active_environment_matches "h200-nvidia-vllm-pr-55222" || return 1
    # Hopper sparse-MLA FP8 KV planning repair: https://github.com/vllm-project/vllm/pull/55222
    # Exact tested PR head: 24b07cd3b099400b10a4a4bd58626216ebbd5b9f.
    # This Python-only PR uses unmodified binaries from its exact upstream parent.
    local source_commit="24b07cd3b099400b10a4a4bd58626216ebbd5b9f"
    local wheel_url="https://wheels.vllm.ai/21a22110404d98dcab5f51cd90e9acb0acc15e47/vllm-0.28.1rc1.dev364%2Bg21a221104-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing upstream vLLM PR 55222 at ${source_commit}..."
    VLLM_USE_PRECOMPILED=1 \
        VLLM_PRECOMPILED_WHEEL_LOCATION="${wheel_url}" \
        run_uv_install -U --reinstall --prerelease=allow \
        "vllm @ git+https://github.com/vllm-project/vllm.git@${source_commit}" \
        --torch-backend=cu130 || return 1
    # Pin the exact native GLM-5.3 multimodal stack used by the validated candidate.
    run_uv_install --force-reinstall --no-deps \
        "transformers==5.17.0" "tokenizers==0.23.2" || return 1
    run_uv_install \
        "flashinfer-python==0.6.18" \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18/flashinfer_cubin-0.6.18-py3-none-any.whl#sha256=2dd65c0fcfc6bc44c67f148530de5372979c2e3d260e47935730f94156d4d873" \
        "flashinfer-jit-cache @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18/flashinfer_jit_cache-0.6.18+cu130-cp39-abi3-manylinux_2_28_x86_64.whl#sha256=428a47a554ade93c30a818e142b781df58582bf056bab94611fb4c906cc366bf" || return 1
    # Keep native BF16 vision convolutions on a matching cuDNN sublibrary set.
    run_uv_install --no-deps "nvidia-cudnn-cu13==9.26.0.51" || return 1
}

install_h200_openai_sglang_pr_38626() {
    ensure_active_environment_matches "h200-openai-sglang-pr-38626" || return 1
    # Complete upstream encoder-decoder atomic-prefill repair, not a local overlay.
    # https://github.com/sgl-project/sglang/pull/38626
    local source_commit="409c5280782dacef59fb7c878f3321ffd59cca46"
    print_info "Installing native Whisper SGLang PR38626..."
    run_uv_install -U --prerelease=allow \
        "sglang @ git+https://github.com/sgl-project/sglang.git@${source_commit}#subdirectory=python" \
        "cuda-tile @ https://pypi.nvidia.com/cuda-tile/cuda_tile-1.6.0rc5-cp311-cp311-manylinux2014_x86_64.whl#sha256=a14ff257522a017430e98f16aabdfd514bbcf38ecb64a0fba1d3f86cd02a21bb" \
        "torchvision==0.28.0" \
        --index-url https://pypi.org/simple --torch-backend=cu130 || return 1
    # Keep Whisper Conv1d on the host-matched cuDNN 9.26 family.
    # Source-backed repair for the sublibrary mismatch: pytorch/pytorch#188892.
    run_uv_install --no-deps "nvidia-cudnn-cu13==9.26.0.51" || return 1
}

install_h200_openai_vllm_pr_53207() {
    ensure_active_environment_matches "h200-openai-vllm-pr-53207" || return 1
    # Complete upstream Whisper conditioning-token repair, including native audio extras.
    # https://github.com/vllm-project/vllm/pull/53207
    local source_commit="070f6e70937e60379d2e85414753513425b1d6f4"
    print_info "Installing native Whisper vLLM PR53207..."
    run_uv_install -U --prerelease=allow \
        "vllm[audio] @ git+https://github.com/vllm-project/vllm.git@${source_commit}" \
        "transformers==5.12.1" "tokenizers==0.22.2" \
        --index-url https://pypi.org/simple --torch-backend=cu130 || return 1
    # This source requires FlashInfer 0.6.17; cubin is outside wheel install_requires.
    run_uv_install \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.17/flashinfer_cubin-0.6.17-py3-none-any.whl#sha256=771f037a828cdf3f15db1c3784574197546d1b09735fb9058f384bdd12010afa" || return 1
    # Whisper uses the same native Torch Conv1d path as the validated SGLang candidate.
    # Source-backed sublibrary alignment: pytorch/pytorch#188892.
    run_uv_install --no-deps "nvidia-cudnn-cu13==9.26.0.51" || return 1
}

install_h200_paradigma_inc_vllm_v0260() {
    ensure_active_environment_matches "h200-paradigma-inc-vllm-v0260" || return 1
    # Official plugin: https://github.com/paradigma-inc/limite-violetto/tree/cd68d27f100ebb7c84f05603d5af0e8f934b28b5
    print_info "Installing the official Limite plugin with vLLM 0.26.0..."
    run_uv_install "vllm==0.26.0" "torch==2.11.0" "transformers==5.6.2" \
        "$(dirname -- "${BASH_SOURCE[0]}")/../recipes/paradigma-inc/plugin/limite_vllm-0.1.0-py3-none-any.whl" \
        --torch-backend=cu130 || return 1
}

install_h200_poolside_laguna_xs_vllm() {
    print_info "Installing vLLM 0.26.0 for Poolside Laguna XS..."
    run_uv_install "vllm==0.26.0" || return 1
}

install_h200_poolside_sglang() {
    print_info "Installing the pinned SGLang main commit for Poolside..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@834400705f2de2378a327121340f57e324ca5a36#subdirectory=python" || return 1
}

install_h200_poolside_vllm() {
    print_info "Installing vLLM 0.27.1 for Poolside..."
    run_uv_install -U "vllm==0.27.1" || return 1
    install_flashinfer_python311_compatible || return 1
}

install_h200_primeintellect_sglang() {
    install_pinned_sglang_commit \
        "h200-primeintellect-sglang" \
        "PrimeIntellect (SGLang) commit dd15fb57b5ef7d13419f92ddc9b241591b71c0b5" \
        "https://github.com/sgl-project/sglang.git" \
        "dd15fb57b5ef7d13419f92ddc9b241591b71c0b5"
}

install_h200_primeintellect_vllm() {
    print_info "Installing the pinned GitHub vLLM commit for PrimeIntellect..."
    install_vllm_pinned_commit_python311_compatible || return 1
}

install_h200_qwen_flash_next_sglang() {
    install_pinned_sglang_commit \
        "h200-qwen-flash-next-sglang" \
        "Qwen Flash Next (SGLang) PR 36497 commit 73a255206f916366c8d26d4022f82ddfb0ab558d" \
        "https://github.com/sgl-project/sglang.git" \
        "73a255206f916366c8d26d4022f82ddfb0ab558d"
}

install_h200_qwen_flash_next_vllm() {
    local source_commit="e77daef89e18e08321ae7b8b24827eedd5fe8673"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.1.1.dev5%2Bge77daef89-cp38-abi3-manylinux_2_28_x86_64.whl"

    ensure_active_environment_matches h200-qwen-flash-next-vllm || return 1
    print_info "Installing the official vLLM e77daef89 wheel for Qwen Flash Next..."
    run_uv_install -U --reinstall --prerelease=allow \
        "vllm @ ${wheel_url}" --torch-backend=cu130 || return 1
    # Required by the pinned CUDA manifest; this cubin release is not published on PyPI.
    run_uv_install \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18.post1/flashinfer_cubin-0.6.18.post1-py3-none-any.whl#sha256=bbacb5b8bbf429e43bf2740bb45551d981f41d0462842e36ee6fb3e3452763ab" || return 1
}

install_h200_qwen_flash_next_vllm_pr_54129() {
    local source_commit="50a061f792f36364f5f95a93eee21f1e9d77f65e"
    local binary_commit="3b45d053b4bbc61ce437f00891b52ce5ddde7c5a"
    local source_dir=""

    ensure_active_environment_matches h200-qwen-flash-next-vllm-pr-54129 || return 1
    source_dir="$VIRTUAL_ENV/vllm-pr-54129"
    if [ -e "$source_dir" ] && [ ! -d "$source_dir/.git" ]; then
        print_error "vLLM PR 54129 target exists but is not a git checkout: $source_dir"
        return 1
    fi
    if [ ! -d "$source_dir/.git" ]; then
        run_command git init "$source_dir" || return 1
        run_command git -C "$source_dir" remote add origin \
            https://github.com/vllm-project/vllm.git || return 1
    fi
    run_command git -C "$source_dir" fetch --depth 1 \
        origin refs/pull/54129/head || return 1
    run_command git -C "$source_dir" checkout --force "$source_commit" || return 1

    print_info "Installing upstream vLLM PR 54129 at ${source_commit}..."
    VLLM_USE_PRECOMPILED=1 \
        VLLM_PRECOMPILED_WHEEL_COMMIT="$binary_commit" \
        run_uv_install -U --reinstall --prerelease=allow \
        -e "$source_dir" --torch-backend=cu130 || return 1
    install_flashinfer_python311_compatible || return 1
}

install_h200_qwen_sglang() {
    print_info "Installing the validated Qwen DFlash2 SGLang commit..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@1cf2b8c54d81802abc15dcf23a29b9cc687bc01e#subdirectory=python" || return 1
}

install_h200_qwen_sglang_pr_22121() {
    install_pinned_sglang_commit \
        "h200-qwen-sglang-pr-22121" \
        "Qwen (SGLang) PR 22121 commit ce79bc7e3964613c87f79181353f09838d1c7459" \
        "https://github.com/Chevron7Locked/sglang.git" \
        "ce79bc7e3964613c87f79181353f09838d1c7459"
}

install_h200_qwen_vllm() {
    print_info "Installing the pinned GitHub vLLM commit for Qwen..."
    install_vllm_pinned_commit_python311_compatible || return 1
}

install_h200_radixark_qwen_sglang() {
    install_pinned_sglang_commit \
        "h200-radixark-qwen-sglang" \
        "RadixArk Qwen Flash Next (SGLang) PR 36497 commit 73a255206f916366c8d26d4022f82ddfb0ab558d" \
        "https://github.com/sgl-project/sglang.git" \
        "73a255206f916366c8d26d4022f82ddfb0ab558d" || return 1
    run_uv_install "transformers==5.12.1" "nvidia-modelopt[torch]==0.46.0" || return 1
}

install_h200_radixark_sglang() {
    install_pinned_sglang_commit \
        "h200-radixark-sglang" \
        "RadixArk (SGLang) PR 35292 commit 0c088029ccba502c6aa4c408cd516a706af5b253" \
        "https://github.com/alphabetc1/sglang.git" \
        "0c088029ccba502c6aa4c408cd516a706af5b253" || return 1
    run_uv_install "transformers==5.12.1" || return 1
}

install_h200_redhat_sglang_pr_35809() {
    install_pinned_sglang_commit \
        "h200-redhat-sglang-pr-35809" \
        "RedHat (SGLang) PR 35809 commit d5bd07850f6200eff1cf0529e5ba31de1fc3abff" \
        "https://github.com/fechaMe/sglang.git" \
        "d5bd07850f6200eff1cf0529e5ba31de1fc3abff" || return 1
    run_uv_install "transformers==5.12.1" || return 1
}

install_h200_redhatai_sglang() {
    install_pinned_sglang_commit \
        "h200-redhatai-sglang" \
        "RedHatAI (SGLang) commit 05c584c44fb0450c894cf9d08a7827c10cd5b2c5" \
        "https://github.com/sgl-project/sglang.git" \
        "05c584c44fb0450c894cf9d08a7827c10cd5b2c5" || return 1
    run_uv_install "transformers==5.12.1" || return 1
}

install_h200_redhatai_vllm() {
    local vllm_version="0.27.2rc1.dev113+g5cecfc013"
    local vllm_wheel="https://wheels.vllm.ai/5cecfc01375052698823fc401e31518fb32a981e/vllm-0.27.2rc1.dev113%2Bg5cecfc013-cp38-abi3-manylinux_2_28_x86_64.whl#sha256=7858cbbd1fbf426a6eac5a9e2dc3779e04ee63705f65c90ab5baca4705a4a638"

    print_info "Installing vLLM $vllm_version for RedHatAI from its immutable commit wheel..."
    ensure_active_environment_matches h200-redhatai-vllm || return 1
    run_uv_install --upgrade --reinstall --prerelease=allow \
        "$vllm_wheel" --torch-backend=auto || return 1
    install_flashinfer_python311_compatible || return 1
    run_uv_install timm || return 1
}

install_h200_stepfun_sglang() {
    print_info "Installing the pinned SGLang main commit for StepFun..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@834400705f2de2378a327121340f57e324ca5a36#subdirectory=python" || return 1
}

install_h200_stepfun_vllm() {
    print_info "Installing the pinned GitHub vLLM commit and required Transformers 5 for StepFun..."
    install_vllm_pinned_commit_python311_compatible || return 1
    run_uv_install "transformers>=5,<6" || return 1
}


install_h200_xiaomimimo_flash_vllm_1ea7c63() {
    ensure_active_environment_matches "h200-xiaomimimo-flash-vllm-1ea7c63" || return 1
    # Official MiMo V2.6 support: https://github.com/vllm-project/vllm/pull/57784
    local source_commit="1ea7c63f4af7bb4fd6f025c8db44434ab274cb51"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.29.1rc1.dev533%2Bg1ea7c63f4-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the official Flash vLLM wheel with audio support..."
    run_uv_install -U --prerelease=allow "vllm[audio] @ ${wheel_url}" --torch-backend=cu130 || return 1
}

install_h200_xiaomimimo_sglang_v0520() {
    ensure_active_environment_matches "h200-xiaomimimo-sglang-v0520" || return 1
    print_info "Installing official SGLang 0.5.20 for XiaomiMiMo Distill..."
    run_uv_install "sglang[all]==0.5.20" "mistral-common==1.11.7" --prerelease=allow || return 1
}

install_h200_xiaomimimo_vllm_v0300() {
    ensure_active_environment_matches "h200-xiaomimimo-vllm-v0300" || return 1
    print_info "Installing official vLLM 0.30.0 for XiaomiMiMo Distill..."
    run_uv_install "vllm==0.30.0" --torch-backend=cu130 || return 1
}

install_h200_zlab_sglang() {
    print_info "Installing the pinned SGLang main commit for z-lab DFlash recipes..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@834400705f2de2378a327121340f57e324ca5a36#subdirectory=python" || return 1
    run_uv_install \
        "git+https://github.com/huggingface/transformers.git@1423d22f7a3b62e8c70ad67b58ec25cd9b675897" || return 1
}
install_h200_zlab_sglang_pr_35209() {
    install_pinned_sglang_commit \
        "h200-z-lab-sglang-pr-35209" \
        "z-lab (SGLang) PR 35209 commit 6283bde44381262b893d0141a529e58041a5d54d" \
        "https://github.com/SubSir/sglang.git" \
        "6283bde44381262b893d0141a529e58041a5d54d"
    run_uv_install "transformers==5.12.1" || return 1
}


install_h200_zlab_vllm() {
    install_dflash_vllm_for_environment "h200-z-lab-vllm" "z-lab" || return 1
}

install_h200_zyphra_legacy_vllm() {
    local source_commit="8df704c5258830b18ca19722bcfd40357b410f66"

    print_info "Installing the proven Zyphra Legacy vLLM commit $source_commit..."
    ensure_active_environment_matches h200-zyphra-legacy-vllm || return 1
    run_pip_install "vllm @ git+https://github.com/Zyphra/vllm.git@$source_commit" || return 1
}

install_h200_zyphra_sglang() {
    install_pinned_sglang_commit \
        "h200-zyphra-sglang" \
        "Zyphra (SGLang) commit 1cf2b8c54d81802abc15dcf23a29b9cc687bc01e" \
        "https://github.com/sgl-project/sglang.git" \
        "1cf2b8c54d81802abc15dcf23a29b9cc687bc01e"
}

install_h200_zyphra_sglang_pr_32517() {
    install_pinned_sglang_commit \
        "h200-zyphra-sglang-pr-32517" \
        "Zyphra (SGLang) PR 32517 commit a43c7793f95609db15cd1c4060de4e3424af171d" \
        "https://github.com/zaddle55/sglang.git" \
        "a43c7793f95609db15cd1c4060de4e3424af171d"
}

install_h200_zyphra_vllm() {
    local source_commit="b1b99a08b20f858035894f7f2a8080c556423844"

    print_info "Installing the proven Zyphra vLLM commit $source_commit..."
    ensure_active_environment_matches h200-zyphra-vllm || return 1
    run_pip_install "vllm @ git+https://github.com/Zyphra/vllm.git@$source_commit" || return 1
}















install_rtxpro6k_allenai_vllm_73a5831127a9() {
    ensure_active_environment_matches "rtxpro6k-allenai-vllm-73a5831127a9" || return 1
    # Official vLLM main ancestor, validated with Python 3.12 on SM120.
    local source_commit="73a5831127a9d2b87102da8a6e7c96b6f7f64fcd"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.30.1rc1.dev452%2Bg73a583112-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the official AllenAI vLLM SM120 wheel at ${source_commit}..."
    run_uv_install --prerelease=allow "vllm @ ${wheel_url}" \
        "torch==2.13.0+cu130" "transformers==5.18.0" "tokenizers==0.23.2" \
        "flashinfer-python==0.7.0.post1" --torch-backend=cu130 || return 1
}

install_rtxpro6k_allenai_vllm_73a78e6f1f38() {
    ensure_active_environment_matches "rtxpro6k-allenai-vllm-73a78e6f1f38" || return 1
    # Official main commit before the Olmo tool-template startup regression.
    local source_commit="73a78e6f1f38e280986b81e0f2a9aa5e1ee6fe47"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.30.1rc1.dev151%2Bg73a78e6f1-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the official AllenAI vLLM SM120 wheel at ${source_commit}..."
    run_uv_install --prerelease=allow "vllm @ ${wheel_url}" \
        "torch==2.13.0+cu130" "transformers==5.18.0" "tokenizers==0.23.2" \
        "flashinfer-python==0.7.0" --torch-backend=cu130 || return 1
}

install_rtxpro6k_arcee_ai_vllm_73a5831127a9() {
    ensure_active_environment_matches "rtxpro6k-arcee-ai-vllm-73a5831127a9" || return 1
    # Official vLLM main ancestor, validated with Python 3.12 on SM120.
    local source_commit="73a5831127a9d2b87102da8a6e7c96b6f7f64fcd"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.30.1rc1.dev452%2Bg73a583112-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the official Arcee AI vLLM SM120 wheel at ${source_commit}..."
    run_uv_install --prerelease=allow "vllm @ ${wheel_url}" \
        "torch==2.13.0+cu130" "transformers==5.18.0" "tokenizers==0.23.2" \
        "flashinfer-python==0.7.0.post1" \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.7.0.post1/flashinfer_cubin-0.7.0.post1-py3-none-any.whl" \
        --torch-backend=cu130 || return 1
}

install_rtxpro6k_arcee_ai_vllm_c8414a82712b() {
    ensure_active_environment_matches "rtxpro6k-arcee-ai-vllm-c8414a82712b" || return 1
    # Official main ancestor before the ModelOpt LM-head regression; validated on SM120.
    local source_commit="c8414a82712bd775b7243b19a264d9623c3bb369"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.21.1rc1.dev305%2Bgc8414a827-cp38-abi3-manylinux_2_28_x86_64.whl"
    local jit_wheel_url="https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.11.post2/flashinfer_jit_cache-0.6.11.post2+cu130-cp39-abi3-manylinux_2_28_x86_64.whl#sha256=c2af38703704ab66ddb8e9ee2fae4a46455a5d9b9547123f66bcdd7006c9a2e4"
    print_info "Installing the official Arcee AI NVFP4 vLLM SM120 wheel at ${source_commit}..."
    run_uv_install --torch-backend=cu130 "vllm @ ${wheel_url}" \
        "torch==2.11.0+cu130" "torchaudio==2.11.0+cu130" "torchvision==0.26.0+cu130" \
        "transformers==5.5.3" "tokenizers==0.22.2" \
        "flashinfer-python==0.6.11.post2" "flashinfer-cubin==0.6.11.post2" \
        "compressed-tensors==0.15.0.1" || return 1
    run_uv_install "flashinfer-jit-cache @ ${jit_wheel_url}" || return 1
}

install_rtxpro6k_coherelabs_vllm_73a5831127a9() {
    ensure_active_environment_matches "rtxpro6k-coherelabs-vllm-73a5831127a9" || return 1
    local source_commit="73a5831127a9d2b87102da8a6e7c96b6f7f64fcd"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.30.1rc1.dev452%2Bg73a583112-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the official CohereLabs vLLM SM120 wheel at ${source_commit}..."
    run_uv_install --prerelease=allow "vllm @ ${wheel_url}" \
        "torch==2.13.0+cu130" "transformers==5.18.0" "tokenizers==0.23.2" \
        "flashinfer-python==0.7.0.post1" \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.7.0.post1/flashinfer_cubin-0.7.0.post1-py3-none-any.whl" \
        "cohere-melody==0.14.0" --torch-backend=cu130 || return 1
}

install_rtxpro6k_datalab_to_vllm_73a5831127a9() {
    ensure_active_environment_matches "rtxpro6k-datalab-to-vllm-73a5831127a9" || return 1
    local source_commit="73a5831127a9d2b87102da8a6e7c96b6f7f64fcd"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.30.1rc1.dev452%2Bg73a583112-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the official Datalab vLLM SM120 wheel at ${source_commit}..."
    run_uv_install --prerelease=allow "vllm @ ${wheel_url}" \
        "torch==2.13.0+cu130" "transformers==5.18.0" "tokenizers==0.23.2" \
        "flashinfer-python==0.7.0.post1" \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.7.0.post1/flashinfer_cubin-0.7.0.post1-py3-none-any.whl" \
        --torch-backend=cu130 || return 1
}

install_rtxpro6k_deepseek_v41_vllm_pr_56509() {
    ensure_active_environment_matches "rtxpro6k-deepseek-v41-vllm-pr-56509" || return 1
    # Complete official SM120 sparse-attention integration: https://github.com/vllm-project/vllm/pull/56509
    # This Python-only PR uses its direct parent's unchanged CUDA 13.0 binaries.
    local source_commit="02ee13be210777a86fe61180d33135ebaa728a08"
    local binary_commit="378504a5442b8a9240b359dae3e6f75f35c38f19"
    local wheel_url="https://wheels.vllm.ai/${binary_commit}/vllm-0.30.1rc1.dev146%2Bg378504a54-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing native DeepSeek V4.1 vLLM PR 56509 at ${source_commit}..."
    VLLM_USE_PRECOMPILED=1 \
        VLLM_PRECOMPILED_WHEEL_LOCATION="${wheel_url}" \
        run_uv_install -U --reinstall --prerelease=allow \
        "vllm @ git+https://github.com/vllm-project/vllm.git@${source_commit}" \
        "flashinfer-python @ git+https://github.com/flashinfer-ai/flashinfer.git@dc04f50c9aa3eabcdaa5feb0934edb3d85e9529a" \
        "filelock==4.0.3" \
        --torch-backend=cu130 || return 1
    # Native SM120 NVFP4 TP padding and narrow-gated prefill recovery.
    # Keep engine CUTLASS 4.7.1; B12X 1.2.6 declares 4.6.2 (recorded exception).
    run_uv_install --no-deps --reinstall-package b12x \
        "b12x @ git+https://github.com/local-inference-lab/b12x.git@11e27c04977875aed3c0cbf03c9c211b71fcdc68" || return 1
}

install_rtxpro6k_glm53_vllm_2617fe938() {
    ensure_active_environment_matches "rtxpro6k-glm53-vllm-2617fe938" || return 1
    # Official main commit and merged KPool MTP fix: https://github.com/vllm-project/vllm/pull/58454
    local source_commit="2617fe938355594c48d4512a2ef6b470962aac1a"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.30.1rc1.dev162%2Bg2617fe938-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the official vLLM GLM-5.3-Flash SM120 wheel at ${source_commit}..."
    run_uv_install "vllm @ ${wheel_url}" \
        "transformers==5.17.0" "tokenizers==0.23.2" "torchcodec==0.16.0+cu130" \
        "blake3==1.0.9" "msgspec==0.21.1" \
        --torch-backend=cu130 || return 1
    # Official merged GLM NoPE eight-head scratch fix: https://github.com/flashinfer-ai/flashinfer/pull/5075
    local flashinfer_commit="915e7c49aececa5ba4fdf60ac0f4038ca1455fc1"
    BUILD_NVEP=0 FLASHINFER_BUILD_NO_PIP=1 FLASHINFER_LOCAL_VERSION=g915e7c49 \
        run_uv_install --reinstall-package flashinfer-python --no-deps \
        "flashinfer-python @ git+https://github.com/flashinfer-ai/flashinfer.git@${flashinfer_commit}" || return 1
    run_command uv pip check --python "$VIRTUAL_ENV/bin/python" || return 1
}

install_rtxpro6k_google_sglang_1093c501dfef() {
    ensure_active_environment_matches "rtxpro6k-google-sglang-1093c501dfef" || return 1
    local source_commit="1093c501dfef0789b46fc3afe44949e35867a11a"
    local repository="https://github.com/sgl-project/sglang.git"
    local source_dir="$HOME/.local/share/rtxpro6k-sources/google-sglang-1093c501dfef"

    if [ -e "$source_dir" ] && [ ! -d "$source_dir/.git" ]; then
        print_error "SGLang target exists but is not a git checkout: $source_dir"
        return 1
    fi
    if [ ! -d "$source_dir/.git" ]; then
        run_command mkdir -p "$HOME/.local/share/rtxpro6k-sources" || return 1
        run_command git clone --filter=blob:none --no-checkout "$repository" "$source_dir" || return 1
        run_command git -C "$source_dir" checkout --detach "$source_commit" || return 1
    fi
    if [ "$(git -C "$source_dir" remote get-url origin)" != "$repository" ] ||
       [ "$(git -C "$source_dir" rev-parse HEAD)" != "$source_commit" ] ||
       [ -n "$(git -C "$source_dir" status --porcelain --untracked-files=no)" ]; then
        print_error "Google SGLang checkout must match the clean validated commit: $source_commit"
        return 1
    fi

    print_info "Installing upstream Google Gemma 4 SGLang at ${source_commit}..."
    CUDA_VISIBLE_DEVICES="" TORCH_CUDA_ARCH_LIST=12.0 UV_LINK_MODE=copy \
        run_uv_install --python "$VIRTUAL_ENV/bin/python" --prerelease=allow \
        --torch-backend=cu130 --editable "$source_dir/python" \
        "torch==2.13.0+cu130" "transformers==5.17.0" "tokenizers==0.23.2" \
        "sglang-kernel==0.4.8" "flashinfer-python==0.7.0.post1" \
        "torchcodec==0.15.0+cu130" "torchaudio==2.11.0+cu130" \
        "torchvision==0.28.0+cu130" || return 1
    run_command uv pip check --python "$VIRTUAL_ENV/bin/python" || return 1
}

install_rtxpro6k_google_vllm_73a5831127a9() {
    ensure_active_environment_matches "rtxpro6k-google-vllm-73a5831127a9" || return 1
    local source_commit="73a5831127a9d2b87102da8a6e7c96b6f7f64fcd"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.30.1rc1.dev452%2Bg73a583112-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the official Google Gemma vLLM SM120 wheel at ${source_commit}..."
    run_uv_install --prerelease=allow "vllm[audio] @ ${wheel_url}" \
        "torch==2.13.0+cu130" "transformers==5.18.0" "tokenizers==0.23.2" \
        "flashinfer-python==0.7.0.post1" \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.7.0.post1/flashinfer_cubin-0.7.0.post1-py3-none-any.whl" \
        "torchcodec==0.15.0+cu130" "torchaudio==2.11.0+cu130" \
        "torchvision==0.28.0+cu130" --torch-backend=cu130 || return 1
    run_command uv pip check --python "$VIRTUAL_ENV/bin/python" || return 1
}

install_rtxpro6k_ibm_granite_sglang_fa7784d140ee() {
    ensure_active_environment_matches "rtxpro6k-ibm-granite-sglang-fa7784d140ee" || return 1
    # Official main commit, including https://github.com/sgl-project/sglang/pull/42252.
    local source_commit="fa7784d140eef70223cabf942ab81d53a48fdb0a"
    local repository="https://github.com/sgl-project/sglang.git"
    local source_dir="$HOME/.local/share/rtxpro6k-sources/ibm-granite-sglang-fa7784d140ee"

    if [ -e "$source_dir" ] && [ ! -d "$source_dir/.git" ]; then
        print_error "SGLang target exists but is not a git checkout: $source_dir"
        return 1
    fi
    if [ ! -d "$source_dir/.git" ]; then
        run_command mkdir -p "$HOME/.local/share/rtxpro6k-sources" || return 1
        run_command git clone --filter=blob:none --no-checkout "$repository" "$source_dir" || return 1
        run_command git -C "$source_dir" checkout --detach "$source_commit" || return 1
    fi
    if [ "$(git -C "$source_dir" remote get-url origin)" != "$repository" ] ||
       [ "$(git -C "$source_dir" rev-parse HEAD)" != "$source_commit" ] ||
       [ -n "$(git -C "$source_dir" status --porcelain --untracked-files=no)" ]; then
        print_error "IBM Granite SGLang checkout must match the clean validated commit: $source_commit"
        return 1
    fi

    print_info "Installing upstream IBM Granite SGLang at ${source_commit}..."
    CUDA_VISIBLE_DEVICES="" TORCH_CUDA_ARCH_LIST=12.0 UV_LINK_MODE=copy \
        run_uv_install --python "$VIRTUAL_ENV/bin/python" --prerelease=allow \
        --torch-backend=cu130 --editable "$source_dir/python" \
        "torch==2.13.0+cu130" "transformers==5.17.0" "tokenizers==0.23.2" \
        "sglang-kernel==0.4.8" "flashinfer-python==0.7.0.post1" \
        "torchcodec==0.15.0+cu130" "torchaudio==2.11.0+cu130" \
        "torchvision==0.28.0+cu130" || return 1
    run_command uv pip check --python "$VIRTUAL_ENV/bin/python" || return 1
}

install_rtxpro6k_ibm_granite_vllm_73a5831127a9() {
    ensure_active_environment_matches "rtxpro6k-ibm-granite-vllm-73a5831127a9" || return 1
    local source_commit="73a5831127a9d2b87102da8a6e7c96b6f7f64fcd"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.30.1rc1.dev452%2Bg73a583112-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the official IBM Granite vLLM SM120 wheel at ${source_commit}..."
    run_uv_install --prerelease=allow "vllm @ ${wheel_url}" \
        "torch==2.13.0+cu130" "transformers==5.18.0" "tokenizers==0.23.2" \
        "flashinfer-python==0.7.0.post1" \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.7.0.post1/flashinfer_cubin-0.7.0.post1-py3-none-any.whl" \
        --torch-backend=cu130 || return 1
    run_command uv pip check --python "$VIRTUAL_ENV/bin/python" || return 1
}

install_rtxpro6k_incoai_sglang_964c45cf3() {
    ensure_active_environment_matches "rtxpro6k-incoai-sglang-964c45cf3" || return 1
    # Official SGLang main commit.
    local source_commit="964c45cf31e838d85c048fe8c03fa51a588881a1"
    # Validated with Python 3.12, CUDA 13.2, Rust 1.92 and protoc available on PATH.
    print_info "Installing upstream SGLang at ${source_commit}..."
    RUSTUP_TOOLCHAIN=1.92 run_uv_install --prerelease=allow \
        "sglang @ git+https://github.com/sgl-project/sglang.git@${source_commit}#subdirectory=python" \
        --torch-backend=auto || return 1
}

install_rtxpro6k_incoai_sglang_fa7784d140ee() {
    ensure_active_environment_matches "rtxpro6k-incoai-sglang-fa7784d140ee" || return 1
    # Qualified whole official main commit; native DFlash2 uses no engine patches.
    local source_commit="fa7784d140eef70223cabf942ab81d53a48fdb0a"
    local repository="https://github.com/sgl-project/sglang.git"
    local source_dir="$HOME/.local/share/rtxpro6k-sources/incoai-sglang-fa7784d140ee"

    if [ -e "$source_dir" ] && [ ! -d "$source_dir/.git" ]; then
        print_error "SGLang target exists but is not a git checkout: $source_dir"
        return 1
    fi
    if [ ! -d "$source_dir/.git" ]; then
        run_command mkdir -p "$HOME/.local/share/rtxpro6k-sources" || return 1
        run_command git clone --filter=blob:none --no-checkout "$repository" "$source_dir" || return 1
        run_command git -C "$source_dir" checkout --detach "$source_commit" || return 1
    fi
    if [ "$(git -C "$source_dir" remote get-url origin)" != "$repository" ] ||
       [ "$(git -C "$source_dir" rev-parse HEAD)" != "$source_commit" ] ||
       [ -n "$(git -C "$source_dir" status --porcelain --untracked-files=no)" ]; then
        print_error "incoai Qwen3.8 DFlash2 SGLang checkout must match the clean validated commit: $source_commit"
        return 1
    fi

    print_info "Installing upstream incoai Qwen3.8 DFlash2 SGLang at ${source_commit}..."
    CUDA_VISIBLE_DEVICES="" TORCH_CUDA_ARCH_LIST=12.0 UV_LINK_MODE=copy \
        run_uv_install --python "$VIRTUAL_ENV/bin/python" --prerelease=allow \
        --torch-backend=cu130 --editable "$source_dir/python" \
        "torch==2.13.0+cu130" "transformers==5.17.0" "tokenizers==0.23.2" \
        "sglang-kernel==0.4.8" "flashinfer-python==0.7.0.post1" \
        "torchcodec==0.15.0+cu130" "torchaudio==2.11.0+cu130" \
        "torchvision==0.28.0+cu130" || return 1
    run_command uv pip check --python "$VIRTUAL_ENV/bin/python" || return 1
}

install_rtxpro6k_mistralai_sglang_fa7784d140ee() {
    ensure_active_environment_matches "rtxpro6k-mistralai-sglang-fa7784d140ee" || return 1
    # Qualified whole official commit; the private environment used the IBM Granite checkout.
    local source_commit="fa7784d140eef70223cabf942ab81d53a48fdb0a"
    local repository="https://github.com/sgl-project/sglang.git"
    local source_dir="$HOME/.local/share/rtxpro6k-sources/ibm-granite-sglang-fa7784d140ee"

    if [ -e "$source_dir" ] && [ ! -d "$source_dir/.git" ]; then
        print_error "SGLang target exists but is not a git checkout: $source_dir"
        return 1
    fi
    if [ ! -d "$source_dir/.git" ]; then
        run_command mkdir -p "$HOME/.local/share/rtxpro6k-sources" || return 1
        run_command git clone --filter=blob:none --no-checkout "$repository" "$source_dir" || return 1
        run_command git -C "$source_dir" checkout --detach "$source_commit" || return 1
    fi
    if [ "$(git -C "$source_dir" remote get-url origin)" != "$repository" ] ||
       [ "$(git -C "$source_dir" rev-parse HEAD)" != "$source_commit" ] ||
       [ -n "$(git -C "$source_dir" status --porcelain --untracked-files=no)" ]; then
        print_error "MistralAI SGLang checkout must match the clean validated commit: $source_commit"
        return 1
    fi

    print_info "Installing upstream MistralAI SGLang at ${source_commit}..."
    CUDA_VISIBLE_DEVICES="" TORCH_CUDA_ARCH_LIST=12.0 UV_LINK_MODE=copy \
        run_uv_install --python "$VIRTUAL_ENV/bin/python" --prerelease=allow \
        --torch-backend=cu130 --editable "$source_dir/python" \
        "torch==2.13.0+cu130" "transformers==5.17.0" "tokenizers==0.23.2" \
        "sglang-kernel==0.4.8" "flashinfer-python==0.7.0.post1" \
        "mistral_common==1.12.0" "nvidia-cutlass-dsl==4.8.0" \
        "torchcodec==0.15.0+cu130" "torchaudio==2.11.0+cu130" \
        "torchvision==0.28.0+cu130" || return 1
    run_command uv pip check --python "$VIRTUAL_ENV/bin/python" || return 1
}

install_rtxpro6k_mistralai_vllm_73a5831127a9() {
    ensure_active_environment_matches "rtxpro6k-mistralai-vllm-73a5831127a9" || return 1
    local source_commit="73a5831127a9d2b87102da8a6e7c96b6f7f64fcd"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.30.1rc1.dev452%2Bg73a583112-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the validated MistralAI vLLM environment at ${source_commit}..."
    CUDA_VISIBLE_DEVICES="" run_uv_install --python "$VIRTUAL_ENV/bin/python" \
        --no-config --no-build --no-python-downloads --prerelease=allow \
        --torch-backend=cu130 \
        "vllm @ ${wheel_url}" "torch==2.13.0+cu130" "transformers==5.18.0" \
        "tokenizers==0.23.2" "flashinfer-python==0.7.0.post1" \
        "mistral_common[image]==1.12.0" || return 1
    run_command uv pip check --python "$VIRTUAL_ENV/bin/python" || return 1
}

install_rtxpro6k_mistralai_vllm_pr_678ef33584da() {
    ensure_active_environment_matches "rtxpro6k-mistralai-vllm-pr-678ef33584da" || return 1
    # Official parser-cache PR: https://github.com/vllm-project/vllm/pull/58172
    local source_commit="678ef33584da549950a06573f3afa4f1ab31f3b0"
    local binary_commit="8a26869bcad1ae4ab3069a7d2aece86c17c1c695"
    local wheel_url="https://wheels.vllm.ai/${binary_commit}/vllm-0.31.1rc1.dev19%2Bg8a26869bc-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the validated MistralAI vLLM PR 58172 at ${source_commit}..."
    CUDA_VISIBLE_DEVICES="" HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
        GIT_LFS_SKIP_SMUDGE=1 MAX_JOBS=2 VLLM_USE_PRECOMPILED=1 \
        VLLM_TARGET_DEVICE=cuda VLLM_PRECOMPILED_WHEEL_LOCATION="$wheel_url" \
        run_uv_install --no-config --python "$VIRTUAL_ENV/bin/python" \
        --no-python-downloads --link-mode=hardlink --prerelease=allow \
        --torch-backend=cu130 \
        "vllm @ git+https://github.com/vllm-project/vllm.git@${source_commit}" \
        "torch==2.13.0+cu130" "transformers==5.18.0" "tokenizers==0.23.2" \
        "flashinfer-python==0.7.0.post1" "mistral_common[image]==1.12.0" || return 1
    run_command uv pip check --python "$VIRTUAL_ENV/bin/python" || return 1
}

install_rtxpro6k_incoai_sglang_pr_028ac64f7() {
    ensure_active_environment_matches "rtxpro6k-incoai-sglang-pr-028ac64f7" || return 1
    # Native SM120 GLM NoPE adapter: https://github.com/sgl-project/sglang/pull/38430
    local source_commit="028ac64f797f7c41c019269ad2e6472a41ead458"
    local flashinfer_commit="eb5f05be1f8e3ef8aa017a66dcbd5d80119b1095"
    # Validated with Python 3.12, CUDA 13.2, Rust 1.92 and protoc on PATH.
    print_info "Installing upstream SGLang PR 38430 at ${source_commit}..."
    RUSTUP_TOOLCHAIN=1.92 run_uv_install --prerelease=allow \
        "sglang @ git+https://github.com/sgl-project/sglang.git@${source_commit}#subdirectory=python" \
        --torch-backend=auto || return 1
    # Official FlashInfer PR 5197 merge supplies compact NoPE rows and eight-head decode.
    BUILD_NVEP=0 FLASHINFER_BUILD_NO_PIP=1 FLASHINFER_LOCAL_VERSION=geb5f05be \
        run_uv_install --reinstall-package flashinfer-python --no-deps \
        "flashinfer-python @ git+https://github.com/flashinfer-ai/flashinfer.git@${flashinfer_commit}" || return 1
    # Native GLM vision requires this isolated override of SGLang's older HF pins.
    run_uv_install --no-deps "transformers==5.17.0" "tokenizers==0.23.2" || return 1
    run_uv_install "nccl-extensions==0.1.0" || return 1
}

install_rtxpro6k_incoai_vllm_73a583112() {
    ensure_active_environment_matches "rtxpro6k-incoai-vllm-73a583112" || return 1
    local source_commit="73a5831127a9d2b87102da8a6e7c96b6f7f64fcd"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.30.1rc1.dev452%2Bg73a583112-cp38-abi3-manylinux_2_28_x86_64.whl"
    local flashinfer_commit="eb5f05be1f8e3ef8aa017a66dcbd5d80119b1095"
    print_info "Installing the official vLLM GLM-5.3-Flash SM120 wheel at ${source_commit}..."
    run_uv_install --prerelease=allow "vllm @ ${wheel_url}" \
        "transformers==5.17.0" "tokenizers==0.23.2" "torchcodec==0.16.0+cu130" \
        --torch-backend=cu130 || return 1
    # Official FlashInfer PR 5197 merge fixes native NoPE eight-head decode.
    BUILD_NVEP=0 FLASHINFER_BUILD_NO_PIP=1 FLASHINFER_LOCAL_VERSION=geb5f05be \
        run_uv_install --reinstall-package flashinfer-python --no-deps \
        "flashinfer-python @ git+https://github.com/flashinfer-ai/flashinfer.git@${flashinfer_commit}" || return 1
    # Validated with vLLM's CuTe DSL 4.7.1 stack despite b12x's older 4.6.2 metadata pins.
    run_uv_install --no-deps "b12x==1.3.0" || return 1
}

install_rtxpro6k_incoai_vllm_pr_417b0b6aa() {
    ensure_active_environment_matches "rtxpro6k-incoai-vllm-pr-417b0b6aa" || return 1
    # Upstream PR https://github.com/vllm-project/vllm/pull/58773 isolates the DFlash2 draft KV dtype.
    local source_commit="417b0b6aa2894f95f9170a1f1f0c9255ab48a66c"
    # Python-only PR with unmodified binaries from its upstream parent; tested with CUDA 13.2.
    local wheel_commit="b21757555ac5f853a8eff02a687d2777437e055b"
    print_info "Installing upstream vLLM PR 58773 at ${source_commit}..."
    VLLM_USE_PRECOMPILED=1 VLLM_PRECOMPILED_WHEEL_COMMIT="${wheel_commit}" \
        run_uv_install --prerelease=allow \
        "vllm @ git+https://github.com/vllm-project/vllm.git@${source_commit}" \
        --torch-backend=auto || return 1
}

install_rtxpro6k_intel_sglang() {
    install_pinned_sglang_commit \
        "rtxpro6k-intel-sglang" \
        "Intel (SGLang) commit f7d4e44d82ac35b9b10ce80348e4a5421f89435a" \
        "https://github.com/sgl-project/sglang.git" \
        "f7d4e44d82ac35b9b10ce80348e4a5421f89435a" || return 1
    run_uv_install \
        "git+https://github.com/huggingface/transformers.git@1423d22f7a3b62e8c70ad67b58ec25cd9b675897" || return 1
}

install_rtxpro6k_intel_vllm_73a5831127a9() {
    ensure_active_environment_matches "rtxpro6k-intel-vllm-73a5831127a9" || return 1
    local source_commit="73a5831127a9d2b87102da8a6e7c96b6f7f64fcd"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.30.1rc1.dev452%2Bg73a583112-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing the official Intel AutoRound vLLM SM120 wheel at ${source_commit}..."
    run_uv_install --prerelease=allow "vllm[audio] @ ${wheel_url}" \
        "torch==2.13.0+cu130" "transformers==5.18.0" "tokenizers==0.23.2" \
        "flashinfer-python==0.7.0.post1" \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.7.0.post1/flashinfer_cubin-0.7.0.post1-py3-none-any.whl" \
        "torchcodec==0.15.0+cu130" "torchaudio==2.11.0+cu130" \
        "torchvision==0.28.0+cu130" --torch-backend=cu130 || return 1
    run_command uv pip check --python "$VIRTUAL_ENV/bin/python" || return 1
}

install_rtxpro6k_liquidai_sglang() {
    ensure_active_environment_matches "rtxpro6k-liquidai-sglang" || return 1
    print_info "Installing the pinned SGLang main commit for LiquidAI..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@05c584c44fb0450c894cf9d08a7827c10cd5b2c5#subdirectory=python" || return 1
}

install_rtxpro6k_liquidai_sglang_pr_31041() {
    install_pinned_sglang_commit \
        "rtxpro6k-liquidai-sglang-pr-31041" \
        "LiquidAI (SGLang) PR 31041 commit c26ae043924fffe413df8a90329f8734869d7fd1" \
        "https://github.com/tugot17/sglang.git" \
        "c26ae043924fffe413df8a90329f8734869d7fd1"
}

install_rtxpro6k_nanbeige_sglang() {
    ensure_active_environment_matches "rtxpro6k-nanbeige-sglang" || return 1
    local source_commit="3e59d89e53490d3b6957cb72754abf6a98c2b8a8"
    print_info "Installing the pinned Nanbeige SGLang fork commit $source_commit..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/Nanbeige/sglang.git@${source_commit}#subdirectory=python" || return 1
}

install_rtxpro6k_nvidia_glm53_sglang_26fd7fd() {
    ensure_active_environment_matches "rtxpro6k-nvidia-glm53-sglang-26fd7fd" || return 1
    print_info "Installing the validated SGLang commit for NVIDIA GLM-5.3 NVFP4 on RTX PRO 6000..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@26fd7fdaa2732abbad6d63b21cf0944aa88e977e#subdirectory=python" \
        "transformers==5.12.1" \
        "compressed-tensors==0.19.1a20260923" || return 1
}



install_rtxpro6k_nvidia_glm53flash_sglang_pr_38430() {
    ensure_active_environment_matches "rtxpro6k-nvidia-glm53flash-sglang-pr-38430" || return 1
    # The unmodified official source build requires the existing Rust toolchain.
    if ! command -v rustc >/dev/null 2>&1 || ! command -v cargo >/dev/null 2>&1; then
        print_error "Rust and Cargo are required; install them with installers/01_install_dependencies.sh --rust first."
        return 1
    fi
    # Native GLM5Next NoPE sparse MLA: https://github.com/sgl-project/sglang/pull/38430
    print_info "Installing NVIDIA GLM-5.3 Flash SGLang PR 38430..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang @ git+https://github.com/sgl-project/sglang.git@28379a7c55687b9694a886550e39120853c9d000#subdirectory=python" \
        --torch-backend=cu130 || return 1
    # Official FlashInfer includes compact NoPE rows and the complete SM120 sparse path.
    # https://github.com/flashinfer-ai/flashinfer/pull/5075
    run_uv_install --force-reinstall --no-deps \
        "flashinfer-python @ git+https://github.com/flashinfer-ai/flashinfer.git@dc04f50c9aa3eabcdaa5feb0934edb3d85e9529a" || return 1
    # Exact tested multimodal tokenizer stack and matching cuDNN sublibraries.
    run_uv_install --force-reinstall --no-deps \
        "transformers==5.17.0" "tokenizers==0.23.2" "nvidia-cudnn-cu13==9.26.0.51" || return 1
    run_uv_install "nccl-extensions==0.1.0" || return 1
}

install_rtxpro6k_nvidia_qwen38_vllm_9c2d21046() {
    ensure_active_environment_matches "rtxpro6k-nvidia-qwen38-vllm-9c2d21046" || return 1
    # Complete upstream PR54788 merge: native V2 draft MoE backend isolation.
    # https://github.com/vllm-project/vllm/pull/54788
    local source_commit="9c2d21046bb39f56ee93a5fab4f899714a5579ef"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.28.1rc1.dev562%2Bg9c2d21046-cp38-abi3-manylinux_2_28_x86_64.whl"
    print_info "Installing NVIDIA Qwen3.8 Flash Next NVFP4 vLLM 9c2d21046 for RTX PRO 6000..."
    run_uv_install -U --prerelease=allow \
        "vllm @ ${wheel_url}" "transformers==5.12.1" "tokenizers==0.22.2" \
        --index-url https://pypi.org/simple --torch-backend=cu130 || return 1
    # Released CUDA requirements keep FlashInfer cubin outside PyPI install_requires.
    run_uv_install \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18/flashinfer_cubin-0.6.18-py3-none-any.whl#sha256=2dd65c0fcfc6bc44c67f148530de5372979c2e3d260e47935730f94156d4d873" || return 1
}


install_rtxpro6k_nvidia_sglang_964c45cf3() {
    ensure_active_environment_matches "rtxpro6k-nvidia-sglang-964c45cf3" || return 1
    # Official SGLang main; validated with Python 3.12, CUDA 13.2, Rust 1.92 and protoc.
    local source_commit="964c45cf31e838d85c048fe8c03fa51a588881a1"
    print_info "Installing upstream SGLang for NVIDIA Kimi-K2.6 NVFP4 at ${source_commit}..."
    RUSTUP_TOOLCHAIN=1.92 run_uv_install --prerelease=allow \
        "sglang @ git+https://github.com/sgl-project/sglang.git@${source_commit}#subdirectory=python" \
        --torch-backend=auto || return 1
}

install_rtxpro6k_nvidia_vllm_pr_39e0ce172() {
    ensure_active_environment_matches "rtxpro6k-nvidia-vllm-pr-39e0ce172" || return 1
    # Official PR 54013 test merge fixes native SM120 FP8 MLA shared-memory scheduling.
    # https://github.com/vllm-project/vllm/pull/54013
    local source_commit="39e0ce172b20db347fd9a66351297b9cd9d55fc4"
    local binary_commit="840c7c2f4bc72c7c55edb2dea6d23f9a9c9734e0"
    local wheel_url="https://wheels.vllm.ai/${binary_commit}/vllm-0.30.1rc1.dev529%2Bg840c7c2f4-cp38-abi3-manylinux_2_28_x86_64.whl"

    print_info "Installing upstream NVIDIA Kimi vLLM PR 54013 at ${source_commit}..."
    # Resolve the full runtime closure for a fresh Python 3.12 environment, not just vLLM.
    # Native/Rust artifacts come from this test merge's own first parent, not an older stack.
    VLLM_USE_PRECOMPILED=1 \
        VLLM_PRECOMPILED_WHEEL_COMMIT="${binary_commit}" \
        VLLM_PRECOMPILED_WHEEL_VARIANT=cu130 \
        VLLM_PRECOMPILED_WHEEL_LOCATION="${wheel_url}" \
        run_uv_install --link-mode=copy --prerelease=allow --torch-backend=cu130 \
        "vllm @ git+https://github.com/vllm-project/vllm.git@${source_commit}" \
        "torch==2.13.0+cu130" "torchaudio==2.11.0+cu130" "torchvision==0.28.0+cu130" \
        "torchcodec==0.16.0+cu130" "transformers==5.17.0" "tokenizers==0.23.2" \
        "compressed-tensors==0.17.0" "flashinfer-python==0.7.0.post1" \
        "nvidia-cutlass-dsl[cu13]==4.7.1" "apache-tvm-ffi==0.1.11" \
        cuda-python "rich>=13" || return 1
    # Published cubin is outside vLLM's install_requires and is not supplied by PyPI.
    run_uv_install --link-mode=copy \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.7.0.post1/flashinfer_cubin-0.7.0.post1-py3-none-any.whl#sha256=f5b5fbf6e914b358219b845ed3ee586ffc1ae3c9768c8b135115ac14afbceed3" || return 1
    # Recorded metadata exception: b12x pins DSL and its libraries to 4.6.2;
    # retain vLLM's tested 4.7.1 stack. This is not a clean dependency-health claim.
    # Its remaining runtime dependencies are resolved above before this --no-deps install.
    run_uv_install --link-mode=copy --no-deps \
        "b12x @ https://files.pythonhosted.org/packages/d2/bc/f28f6b3ade2522785f57caaebb2b02e35e7f189e647f47b0da8e7f581e36/b12x-1.3.0-py3-none-any.whl#sha256=c97d88635521a7fdd4f67717c1835a017d0dcea49d49cc7aa5b4299f290d19e3" || return 1
}

install_rtxpro6k_primeintellect_sglang() {
    install_pinned_sglang_commit \
        "rtxpro6k-primeintellect-sglang" \
        "PrimeIntellect (SGLang) commit dd15fb57b5ef7d13419f92ddc9b241591b71c0b5" \
        "https://github.com/sgl-project/sglang.git" \
        "dd15fb57b5ef7d13419f92ddc9b241591b71c0b5"
}

install_rtxpro6k_qwen_flash_next_vllm() {
    local source_commit="e77daef89e18e08321ae7b8b24827eedd5fe8673"
    local wheel_url="https://wheels.vllm.ai/${source_commit}/vllm-0.1.1.dev5%2Bge77daef89-cp38-abi3-manylinux_2_28_x86_64.whl"

    ensure_active_environment_matches rtxpro6k-qwen-flash-next-vllm || return 1
    print_info "Installing the official vLLM e77daef89 wheel for Qwen Flash Next..."
    run_uv_install -U --reinstall --prerelease=allow \
        "vllm @ ${wheel_url}" --torch-backend=cu130 || return 1
    # Required by the pinned CUDA manifest; this cubin release is not published on PyPI.
    run_uv_install \
        "flashinfer-cubin @ https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18.post1/flashinfer_cubin-0.6.18.post1-py3-none-any.whl#sha256=bbacb5b8bbf429e43bf2740bb45551d981f41d0462842e36ee6fb3e3452763ab" || return 1
}

install_rtxpro6k_qwen_flash_next_vllm_pr_54129() {
    local source_commit="50a061f792f36364f5f95a93eee21f1e9d77f65e"
    local binary_commit="3b45d053b4bbc61ce437f00891b52ce5ddde7c5a"
    local source_dir=""

    ensure_active_environment_matches rtxpro6k-qwen-flash-next-vllm-pr-54129 || return 1
    source_dir="$VIRTUAL_ENV/vllm-pr-54129"
    if [ -e "$source_dir" ] && [ ! -d "$source_dir/.git" ]; then
        print_error "vLLM PR 54129 target exists but is not a git checkout: $source_dir"
        return 1
    fi
    if [ ! -d "$source_dir/.git" ]; then
        run_command git init "$source_dir" || return 1
        run_command git -C "$source_dir" remote add origin \
            https://github.com/vllm-project/vllm.git || return 1
    fi
    run_command git -C "$source_dir" fetch --depth 1 \
        origin refs/pull/54129/head || return 1
    run_command git -C "$source_dir" checkout --force "$source_commit" || return 1

    print_info "Installing upstream vLLM PR 54129 at ${source_commit}..."
    VLLM_USE_PRECOMPILED=1 \
        VLLM_PRECOMPILED_WHEEL_COMMIT="$binary_commit" \
        run_uv_install -U --reinstall --prerelease=allow \
        -e "$source_dir" --torch-backend=cu130 || return 1
    install_flashinfer_python311_compatible || return 1
}

install_rtxpro6k_qwen_sglang() {
    ensure_active_environment_matches "rtxpro6k-qwen-sglang" || return 1
    print_info "Installing the validated Qwen DFlash2 SGLang commit..."
    run_uv_install -U --reinstall --prerelease=allow \
        "sglang[all] @ git+https://github.com/sgl-project/sglang.git@1cf2b8c54d81802abc15dcf23a29b9cc687bc01e#subdirectory=python" || return 1
}

install_rtxpro6k_xiaomimimo_flash_vllm_pr_58177() {
    local source_commit="ed073f5eb93c1f407ffabc7411449f027910caf0"
    local binary_commit="0549e8d0ab88d3edf152147e14171f964c6e6f07"
    local wheel_url="https://wheels.vllm.ai/${binary_commit}/vllm-0.30.1rc1.dev22%2Bg0549e8d0a-cp38-abi3-manylinux_2_28_x86_64.whl"
    local cubin_url="https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.18.post1/flashinfer_cubin-0.6.18.post1-py3-none-any.whl#sha256=bbacb5b8bbf429e43bf2740bb45551d981f41d0462842e36ee6fb3e3452763ab"
    local source_dir=""

    ensure_active_environment_matches rtxpro6k-xiaomimimo-flash-vllm-pr-58177 || return 1
    "$VIRTUAL_ENV/bin/python" -c 'import sys; raise SystemExit(sys.version_info[:2] != (3, 12))' || {
        print_error "XiaomiMiMo vLLM PR 58177 requires the validated Python 3.12 environment."
        return 1
    }
    source_dir="$VIRTUAL_ENV/vllm-pr-58177"
    if [ -e "$source_dir" ] && [ ! -d "$source_dir/.git" ]; then
        print_error "vLLM PR 58177 target exists but is not a git checkout: $source_dir"
        return 1
    fi
    if [ ! -d "$source_dir/.git" ]; then
        run_command git init "$source_dir" || return 1
        run_command git -C "$source_dir" remote add origin \
            https://github.com/vllm-project/vllm.git || return 1
        run_command git -C "$source_dir" fetch --depth 1 --no-tags \
            origin "$source_commit" || return 1
        run_command git -C "$source_dir" checkout --detach "$source_commit" || return 1
    fi
    if [ "$(git -C "$source_dir" remote get-url origin)" != "https://github.com/vllm-project/vllm.git" ] ||
       [ "$(git -C "$source_dir" rev-parse HEAD)" != "$source_commit" ] ||
       [ "$(git -C "$source_dir" rev-list --count HEAD)" != "1" ] ||
       [ -n "$(git -C "$source_dir" tag --list)" ] ||
       [ -n "$(git -C "$source_dir" status --porcelain --untracked-files=no)" ]; then
        print_error "vLLM PR 58177 checkout must match the clean, shallow, tag-free validated source."
        return 1
    fi

    print_info "Installing upstream vLLM PR 58177 at ${source_commit} with its official base wheel..."
    VLLM_USE_PRECOMPILED=1 \
        VLLM_PRECOMPILED_WHEEL_LOCATION="$wheel_url" \
        run_uv_install -U --prerelease=allow \
        -e "${source_dir}[audio]" \
        "flashinfer-cubin @ ${cubin_url}" \
        "av==18.1.0" \
        "flashinfer-python==0.6.18.post1" \
        "humming-kernels==0.1.16" \
        "mistral-common==1.12.0" \
        "nvidia-cudnn-cu13==9.20.0.48" \
        "scipy==1.18.1" \
        "setuptools==80.10.2" \
        "soundfile==0.14.0" \
        "soxr==1.1.0" \
        "tokenizers==0.23.2" \
        "torch==2.13.0+cu130" \
        "torchaudio==2.11.0+cu130" \
        "torchvision==0.28.0+cu130" \
        "transformers==5.17.0" \
        --torch-backend=cu130 || return 1
}




perform_environment_action() {
    case "$1" in
        h200-allenai-vllm)
            install_h200_allenai_vllm || return 1
            ;;
        h200-arcee-nvfp4-vllm)
            install_h200_arcee_nvfp4_vllm || return 1
            ;;
        h200-arcee-vllm)
            install_h200_arcee_vllm || return 1
            ;;
        h200-arcee-vllm-pr-54479)
            install_vllm_pr_54479 "h200-arcee-vllm-pr-54479" || return 1
            ;;
        h200-arcee-vllm-pr-54479-fp8-block)
            install_vllm_pr_54479 "h200-arcee-vllm-pr-54479-fp8-block" || return 1
            ;;
        h200-arcee-vllm-pr-54479-thinking-fp8-block)
            install_vllm_pr_54479 "h200-arcee-vllm-pr-54479-thinking-fp8-block" || return 1
            ;;
        h200-cohere-vllm)
            install_h200_cohere_vllm || return 1
            ;;
        h200-cohere-vllm-pr-54479)
            install_h200_cohere_vllm_pr_54479 || return 1
            ;;
        h200-datalab-vllm)
            install_h200_datalab_vllm || return 1
            ;;
        h200-deepseek-sglang)
            install_h200_deepseek_sglang || return 1
            ;;
        h200-deepseek-v41-vllm-e77daef89)
            install_h200_deepseek_v41_vllm_e77daef89 || return 1
            ;;
        h200-deepseek-vision-sglang-pr-37253)
            install_h200_deepseek_vision_sglang_pr_37253 || return 1
            ;;
        h200-deepseek-vision-vllm-pr-54566)
            install_h200_deepseek_vision_vllm_pr_54566 || return 1
            ;;
        h200-deepseek-vllm)
            install_h200_deepseek_vllm || return 1
            ;;
        h200-diffusiongemma-sglang)
            install_h200_diffusiongemma_sglang || return 1
            ;;
        h200-gemma-sglang)
            install_h200_gemma_sglang || return 1
            ;;
        h200-gemma-vllm)
            install_h200_gemma_vllm || return 1
            ;;
        h200-gemma3n-vllm)
            install_h200_gemma3n_vllm || return 1
            ;;
        h200-glm53-vllm-v0290)
            install_h200_glm53_vllm_v0290 || return 1
            ;;
        h200-glm53flash-dflash2-sglang-pr-37818)
            install_h200_glm53flash_dflash2_sglang_pr_37818 || return 1
            ;;
        h200-glm53flash-dflash2-vllm-pr-55423)
            install_h200_glm53flash_dflash2_vllm_pr_55423 || return 1
            ;;
        h200-glm53flash-vllm-pr-53906)
            install_h200_glm53flash_vllm_pr_53906 || return 1
            ;;
        h200-gpt-oss-sglang)
            install_h200_gptoss_sglang || return 1
            ;;
        h200-gpt-oss-vllm)
            install_h200_gptoss_vllm || return 1
            ;;
        h200-ibm-sglang)
            install_h200_ibm_sglang || return 1
            ;;
        h200-ibm-vllm)
            install_h200_ibm_vllm || return 1
            ;;
        h200-inclusionai-ling3-vllm)
            install_h200_inclusionai_ling3_vllm || return 1
            ;;
        h200-inclusionai-sglang)
            install_h200_inclusionai_sglang || return 1
            ;;
        h200-inclusionai-vllm)
            install_h200_inclusionai_vllm || return 1
            ;;
        h200-incoai-sglang)
            install_h200_incoai_sglang || return 1
            ;;
        h200-incoai-vllm)
            install_h200_incoai_vllm || return 1
            ;;
        h200-intel-sglang)
            install_h200_intel_sglang || return 1
            ;;
        h200-intel-vllm)
            install_h200_intel_vllm || return 1
            ;;
        h200-liquidai-sglang)
            install_h200_liquidai_sglang || return 1
            ;;
        h200-liquidai-sglang-pr-31041)
            install_h200_liquidai_sglang_pr_31041 || return 1
            ;;
        h200-liquidai-vllm)
            install_h200_liquidai_vllm || return 1
            ;;
        h200-meta-sglang)
            install_h200_meta_sglang || return 1
            ;;
        h200-meta-vllm)
            install_h200_meta_vllm || return 1
            ;;
        h200-microsoft-vllm)
            install_h200_microsoft_vllm || return 1
            ;;
        h200-minimax-m2-sglang-v0510-post1)
            install_h200_minimax_m2_sglang_v0510_post1 || return 1
            ;;
        h200-minimax-m2-vllm-0f3ce4c74)
            install_h200_minimax_m2_vllm_0f3ce4c74 || return 1
            ;;
        h200-minimax-m25-vllm-v0280)
            install_h200_minimax_m25_vllm_v0280 || return 1
            ;;
        h200-mistralai-sglang)
            install_h200_mistralai_sglang || return 1
            ;;
        h200-mistralai-vllm)
            install_h200_mistralai_vllm || return 1
            ;;
        h200-nanbeige-sglang)
            install_h200_nanbeige_sglang || return 1
            ;;
        h200-nanbeige-vllm)
            install_h200_nanbeige_vllm || return 1
            ;;
        h200-nemotron-ultra-vllm-9c2d21046)
            install_h200_nemotron_ultra_vllm_9c2d21046 || return 1
            ;;
        h200-nex-n2-sglang-v0519)
            install_h200_nex_n2_sglang_v0519 || return 1
            ;;
        h200-nex-n2-vllm-v0290)
            install_h200_nex_n2_vllm_v0290 || return 1
            ;;
        h200-nvidia-deepseek-sglang)
            install_h200_nvidia_deepseek_sglang || return 1
            ;;
        h200-nvidia-glm53-sglang-26fd7fd)
            install_h200_nvidia_glm53_sglang_26fd7fd || return 1
            ;;
        h200-nvidia-muse-sglang-v0520)
            install_h200_nvidia_muse_sglang_v0520 || return 1
            ;;
        h200-nvidia-muse-vllm-v0290)
            install_h200_nvidia_muse_vllm_v0290 || return 1
            ;;
        h200-nvidia-nemotron)
            install_h200_nvidia_nemotron || return 1
            ;;
        h200-nvidia-sglang)
            install_h200_nvidia_sglang || return 1
            ;;
        h200-nvidia-sglang-pr-33554)
            install_h200_nvidia_sglang_pr_33554 || return 1
            ;;
        h200-nvidia-vllm)
            install_h200_nvidia_vllm || return 1
            ;;
        h200-nvidia-vllm-pr-55222)
            install_h200_nvidia_vllm_pr_55222 || return 1
            ;;
        h200-openai-sglang-pr-38626)
            install_h200_openai_sglang_pr_38626 || return 1
            ;;
        h200-openai-vllm-pr-53207)
            install_h200_openai_vllm_pr_53207 || return 1
            ;;
        h200-paradigma-inc-vllm-v0260)
            install_h200_paradigma_inc_vllm_v0260 || return 1
            ;;
        h200-poolside-laguna-xs-vllm)
            install_h200_poolside_laguna_xs_vllm || return 1
            ;;
        h200-poolside-sglang)
            install_h200_poolside_sglang || return 1
            ;;
        h200-poolside-vllm)
            install_h200_poolside_vllm || return 1
            ;;
        h200-primeintellect-sglang)
            install_h200_primeintellect_sglang || return 1
            ;;
        h200-primeintellect-vllm)
            install_h200_primeintellect_vllm || return 1
            ;;
        h200-qwen-flash-next-sglang)
            install_h200_qwen_flash_next_sglang || return 1
            ;;
        h200-qwen-flash-next-vllm)
            install_h200_qwen_flash_next_vllm || return 1
            ;;
        h200-qwen-flash-next-vllm-pr-54129)
            install_h200_qwen_flash_next_vllm_pr_54129 || return 1
            ;;
        h200-qwen-sglang)
            install_h200_qwen_sglang || return 1
            ;;
        h200-qwen-sglang-pr-22121)
            install_h200_qwen_sglang_pr_22121 || return 1
            ;;
        h200-qwen-vllm)
            install_h200_qwen_vllm || return 1
            ;;
        h200-radixark-qwen-sglang)
            install_h200_radixark_qwen_sglang || return 1
            ;;
        h200-radixark-sglang)
            install_h200_radixark_sglang || return 1
            ;;
        h200-redhat-sglang-pr-35809)
            install_h200_redhat_sglang_pr_35809 || return 1
            ;;
        h200-redhatai-sglang)
            install_h200_redhatai_sglang || return 1
            ;;
        h200-redhatai-vllm)
            install_h200_redhatai_vllm || return 1
            ;;
        h200-stepfun-sglang)
            install_h200_stepfun_sglang || return 1
            ;;
        h200-stepfun-vllm)
            install_h200_stepfun_vllm || return 1
            ;;
        h200-xiaomimimo-flash-vllm-1ea7c63)
            install_h200_xiaomimimo_flash_vllm_1ea7c63 || return 1
            ;;
        h200-xiaomimimo-sglang-v0520)
            install_h200_xiaomimimo_sglang_v0520 || return 1
            ;;
        h200-xiaomimimo-vllm-v0300)
            install_h200_xiaomimimo_vllm_v0300 || return 1
            ;;
        h200-z-lab-sglang)
            install_h200_zlab_sglang || return 1
            ;;
        h200-z-lab-sglang-pr-35209)
            install_h200_zlab_sglang_pr_35209 || return 1
            ;;
        h200-z-lab-vllm)
            install_h200_zlab_vllm || return 1
            ;;
        h200-zyphra-legacy-vllm)
            install_h200_zyphra_legacy_vllm || return 1
            ;;
        h200-zyphra-sglang)
            install_h200_zyphra_sglang || return 1
            ;;
        h200-zyphra-sglang-pr-32517)
            install_h200_zyphra_sglang_pr_32517 || return 1
            ;;
        h200-zyphra-vllm)
            install_h200_zyphra_vllm || return 1
            ;;
        rtxpro6k-allenai-vllm-73a5831127a9)
            install_rtxpro6k_allenai_vllm_73a5831127a9 || return 1
            ;;
        rtxpro6k-allenai-vllm-73a78e6f1f38)
            install_rtxpro6k_allenai_vllm_73a78e6f1f38 || return 1
            ;;
        rtxpro6k-arcee-ai-vllm-73a5831127a9)
            install_rtxpro6k_arcee_ai_vllm_73a5831127a9 || return 1
            ;;
        rtxpro6k-arcee-ai-vllm-c8414a82712b)
            install_rtxpro6k_arcee_ai_vllm_c8414a82712b || return 1
            ;;
        rtxpro6k-coherelabs-vllm-73a5831127a9)
            install_rtxpro6k_coherelabs_vllm_73a5831127a9 || return 1
            ;;
        rtxpro6k-datalab-to-vllm-73a5831127a9)
            install_rtxpro6k_datalab_to_vllm_73a5831127a9 || return 1
            ;;
        rtxpro6k-deepseek-v41-vllm-pr-56509)
            install_rtxpro6k_deepseek_v41_vllm_pr_56509 || return 1
            ;;
        rtxpro6k-glm53-vllm-2617fe938)
            install_rtxpro6k_glm53_vllm_2617fe938 || return 1
            ;;
        rtxpro6k-google-sglang-1093c501dfef)
            install_rtxpro6k_google_sglang_1093c501dfef || return 1
            ;;
        rtxpro6k-google-vllm-73a5831127a9)
            install_rtxpro6k_google_vllm_73a5831127a9 || return 1
            ;;
        rtxpro6k-ibm-granite-sglang-fa7784d140ee)
            install_rtxpro6k_ibm_granite_sglang_fa7784d140ee || return 1
            ;;
        rtxpro6k-ibm-granite-vllm-73a5831127a9)
            install_rtxpro6k_ibm_granite_vllm_73a5831127a9 || return 1
            ;;
        rtxpro6k-incoai-sglang-964c45cf3)
            install_rtxpro6k_incoai_sglang_964c45cf3 || return 1
            ;;
        rtxpro6k-incoai-sglang-fa7784d140ee)
            install_rtxpro6k_incoai_sglang_fa7784d140ee || return 1
            ;;
        rtxpro6k-incoai-sglang-pr-028ac64f7)
            install_rtxpro6k_incoai_sglang_pr_028ac64f7 || return 1
            ;;
        rtxpro6k-incoai-vllm-73a583112)
            install_rtxpro6k_incoai_vllm_73a583112 || return 1
            ;;
        rtxpro6k-incoai-vllm-pr-417b0b6aa)
            install_rtxpro6k_incoai_vllm_pr_417b0b6aa || return 1
            ;;
        rtxpro6k-intel-sglang)
            install_rtxpro6k_intel_sglang || return 1
            ;;
        rtxpro6k-intel-vllm-73a5831127a9)
            install_rtxpro6k_intel_vllm_73a5831127a9 || return 1
            ;;
        rtxpro6k-liquidai-sglang)
            install_rtxpro6k_liquidai_sglang || return 1
            ;;
        rtxpro6k-liquidai-sglang-pr-31041)
            install_rtxpro6k_liquidai_sglang_pr_31041 || return 1
            ;;
        rtxpro6k-mistralai-sglang-fa7784d140ee)
            install_rtxpro6k_mistralai_sglang_fa7784d140ee || return 1
            ;;
        rtxpro6k-mistralai-vllm-73a5831127a9)
            install_rtxpro6k_mistralai_vllm_73a5831127a9 || return 1
            ;;
        rtxpro6k-mistralai-vllm-pr-678ef33584da)
            install_rtxpro6k_mistralai_vllm_pr_678ef33584da || return 1
            ;;
        rtxpro6k-nanbeige-sglang)
            install_rtxpro6k_nanbeige_sglang || return 1
            ;;
        rtxpro6k-nvidia-glm53-sglang-26fd7fd)
            install_rtxpro6k_nvidia_glm53_sglang_26fd7fd || return 1
            ;;
        rtxpro6k-nvidia-glm53flash-sglang-pr-38430)
            install_rtxpro6k_nvidia_glm53flash_sglang_pr_38430 || return 1
            ;;
        rtxpro6k-nvidia-qwen38-vllm-9c2d21046)
            install_rtxpro6k_nvidia_qwen38_vllm_9c2d21046 || return 1
            ;;
        rtxpro6k-nvidia-sglang-964c45cf3)
            install_rtxpro6k_nvidia_sglang_964c45cf3 || return 1
            ;;
        rtxpro6k-nvidia-vllm-pr-39e0ce172)
            install_rtxpro6k_nvidia_vllm_pr_39e0ce172 || return 1
            ;;
        rtxpro6k-primeintellect-sglang)
            install_rtxpro6k_primeintellect_sglang || return 1
            ;;
        rtxpro6k-qwen-flash-next-vllm)
            install_rtxpro6k_qwen_flash_next_vllm || return 1
            ;;
        rtxpro6k-qwen-flash-next-vllm-pr-54129)
            install_rtxpro6k_qwen_flash_next_vllm_pr_54129 || return 1
            ;;
        rtxpro6k-qwen-sglang)
            install_rtxpro6k_qwen_sglang || return 1
            ;;
        rtxpro6k-xiaomimimo-flash-vllm-pr-58177)
            install_rtxpro6k_xiaomimimo_flash_vllm_pr_58177 || return 1
            ;;
        *)
            print_info "No automated package actions configured for this environment."
            ;;
    esac

    return 0
}

main() {
    local override=""
    local show_help=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help=true
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                return 1
                ;;
            *)
                if [ -n "$override" ]; then
                    print_error "Only one environment may be specified."
                    return 1
                fi
                override="$1"
                shift
                ;;
        esac
    done

    if [ "$show_help" = true ]; then
        echo "Usage: ./installers/06_install_packages.sh [ENV_NAME]"
        echo
        print_env_options
        return 0
    fi

    local env_type=""

    if [ -n "$override" ]; then
        if env_type=$(resolve_env_type "$override"); then
            print_info "Environment override provided: $env_type"
            if ! activate_environment_override "$env_type"; then
                return 1
            fi
        else
            print_warning "Environment override '$override' is not managed by this script."
            print_info "Nothing to configure in installers/06_install_packages.sh."
            return 0
        fi
    else
        if ! env_type=$(detect_environment); then
            if [ -n "${VIRTUAL_ENV:-}" ]; then
                print_warning "Active virtual environment '$VIRTUAL_ENV' is not managed by this script."
            else
                print_info "No active virtual environment detected."
            fi
            print_info "Nothing to configure in installers/06_install_packages.sh."
            return 0
        fi
    fi

    if [ -n "${VIRTUAL_ENV:-}" ]; then
        print_info "Virtual environment: $VIRTUAL_ENV"
    fi

    echo
    handle_environment "$env_type"
    echo

    if ! perform_environment_action "$env_type"; then
        print_error "Environment handling failed."
        return 1
    fi

}

main "$@"
exit $?
