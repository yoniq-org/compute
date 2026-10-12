#!/usr/bin/env bash

PYTHON_ENV="env_rtxpro6k-inclusionai-vllm-73a5831127a9"
INFERENCE_PROVIDER="vLLM"
INFERENCE_ENV="env MAX_JOBS=2"
MODEL_REPO="inclusionAI/Ling-3.0-tiny-fp8"
MODEL_NAME="ling3"
SERVED_MODEL_NAME="ling"
TRUST_REMOTE_CODE="--trust-remote-code"
REASONING_PARSER="--reasoning-parser ling3"
ENABLE_AUTO_TOOL_CHOICE="--enable-auto-tool-choice"
TOOL_CALL_PARSER="--tool-call-parser ling3"
METRICS_FLAG=""
HOST="0.0.0.0"
DEFAULT_PORT=8000
API_KEY="--api-key YOUR_API_KEY"

ENABLE_CACHE_FLAG=0
ENABLE_SPECULATIVE=0
ENABLE_REASONING_PARSER=0
SPECULATIVE=""
QUANTIZATION=""
NO_PREFIX_CACHE="--no-enable-prefix-caching"
REASONING_PARSER_PLUGIN=""
EXTRA_ARGS="--mamba-cache-mode align --hf-overrides {\"quantization_config\":{\"activation_scheme\":\"dynamic\",\"fmt\":\"e4m3\",\"modules_to_not_convert\":[\"q_a_proj\",\"q_b_proj\",\"fused_qkv_a_proj_with_mqa\",\"kv_a_proj_with_mqa\",\"kv_b_proj\",\"lm_head\",\"word_embeddings\",\"b_proj\",\"mlp.gate\",\"3.attention.g_proj\",\"7.attention.g_proj\",\"11.attention.g_proj\",\"15.attention.g_proj\",\"19.attention.g_proj\",\"23.attention.g_proj\",\"fused_qkv_a_proj\"],\"quant_method\":\"fp8\",\"scale_fmt\":\"ue8m0\",\"weight_block_size\":[128,128]}}"

RECIPE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source "$RECIPE_DIR/../../../tools/recipes/inference_recipe.sh"

BACKEND_ATTENTION_SM90=""
BACKEND_FP8_GEMM_SM90=""
BACKEND_FP4_GEMM_SM90=""
BACKEND_MOE_RUNNER_SM90=""
CONTEXT_LEN_VALUE_SM90=
GPU_MEM_UTIL_VALUE_SM90=
TENSOR_PARALLEL_SIZE_SM90=

BACKEND_ATTENTION_SM100=""
BACKEND_FP8_GEMM_SM100=""
BACKEND_FP4_GEMM_SM100=""
BACKEND_MOE_RUNNER_SM100=""
CONTEXT_LEN_VALUE_SM100=""
GPU_MEM_UTIL_VALUE_SM100=""
TENSOR_PARALLEL_SIZE_SM100=""

BACKEND_ATTENTION_SM103=""
BACKEND_FP8_GEMM_SM103=""
BACKEND_FP4_GEMM_SM103=""
BACKEND_MOE_RUNNER_SM103=""
CONTEXT_LEN_VALUE_SM103=""
GPU_MEM_UTIL_VALUE_SM103=""
TENSOR_PARALLEL_SIZE_SM103=""

BACKEND_ATTENTION_SM120="--attention-backend TRITON_MLA"
BACKEND_FP8_GEMM_SM120="--linear-backend triton"
BACKEND_FP4_GEMM_SM120=""
BACKEND_MOE_RUNNER_SM120="--moe-backend triton"
CONTEXT_LEN_VALUE_SM120=131072
GPU_MEM_UTIL_VALUE_SM120="0.75"
TENSOR_PARALLEL_SIZE_SM120=1

BACKEND_ATTENTION_SM121=""
BACKEND_FP8_GEMM_SM121=""
BACKEND_FP4_GEMM_SM121=""
BACKEND_MOE_RUNNER_SM121=""
CONTEXT_LEN_VALUE_SM121=""
GPU_MEM_UTIL_VALUE_SM121=""
TENSOR_PARALLEL_SIZE_SM121=""

run_inference_recipe "$@"
