# DeepSeek V4.1 Flash standard K7 and CSF deployment comparison

The completed standard DeepSeek V4.1 Flash and Karmic Kraken CSF AgentX runs used four RTX PRO 6000 GPUs with matching primary workload settings. Their attention implementations, activation precision, cache formats, and scheduling defaults differed. This configuration snapshot from October 30, 2026 explains those differences and the separate recipe that makes the standard KV dtype flag explicit; it does not report results from that new recipe.

The [original standard K7 script](../vllm_deepseek-ai_DeepSeek-V4.1-Flash-1017_speculative_dspark_7_ngram_ram_rtxpro6kx4.sh) remains unchanged. The [new fp8kvdtype script](../vllm_deepseek-ai_DeepSeek-V4.1-Flash-1017_speculative_dspark_7_ngram_ram_fp8kvdtype_rtxpro6kx4.sh) adds only `--kv-cache-dtype fp8`. It uses the same Python environment, checkpoint, backends, and remaining settings. In this installed standard backend, both `auto` and `fp8` resolve to **`fp8_ds_mla`**. All six completed standard launches explicitly logged that resolved format. Adding the flag therefore does not convert a BF16 KV cache to FP8 or select the CSF implementation.

The completed results remain in the [standard summary directory](../agentx/vllm_deepseek-ai_DeepSeek-V4.1-Flash-1017_speculative_dspark_7_ngram_ram_rtxpro6kx4) and [CSF summary directory](../agentx/vllm_local-inference-lab_DeepSeek-V4.1-Flash-1017-lossless-CSF_speculative_dspark_ngram_ram_rtxpro6kx4). Each contains 12 native summaries: JSON and CSV for each concurrency level.

**Matched settings.** Both deployments used GPUs 0–3, target TP4, a 524,288-token context limit, GPU memory utilization 0.95, prefix caching, chunked prefill, DSpark with seven draft tokens, draft TP4, and standard rejection sampling. Both used BF16 model computation, V2 model runners, CUDA graphs, server seed 0, and pipeline/data/decode-context parallel sizes of 1. Both enabled automatic tool choice and used `deepseek_v41` tokenizer, reasoning, and tool parsers. These matches do not imply that the implementations or all cache components are identical.

**Execution and scheduling.** “Source-derived” below identifies a value established from the installed defaults and recorded launch conditions, rather than a directly printed resolved field.

| Setting | Standard K7, including new explicit-FP8 recipe | Completed CSF deployment |
|---|---|---|
| Runtime | Host Python environment; vLLM `48dcffbb7`, `0.33.0rc1.dev141` | Docker image `bc48d33e…`; vLLM `6d66eed35`, `0.1.dev21836` |
| Attention backend | `FLASHINFER_MLA_SPARSE_DSV41` | Native `B12X` |
| Linear backend | `flashinfer_cutlass` | `b12x` |
| MoE backend flag | `b12x`; actual activation path differs below | `b12x` |
| Maximum batched tokens | 8,192, logged | 4,096, explicit |
| Maximum sequences | 1,024, source-derived | 32, explicit |
| Main cache block | Omitted; resolves to 64 | Explicit launch value 256 |
| Sliding-window cache block | Model requests 32; group logs confirm 32 | Explicit 128 |
| Maximum CUDA graph capture size | 512 | 128 |
| Graph capture shapes | 51 configured shapes through 512 | 19 configured shapes through 128 |
| Graph mode | `FULL_AND_PIECEWISE` | `FULL_AND_PIECEWISE` |
| Initial compilation configuration | `NONE` | Initially `VLLM_COMPILE`, followed by an unsupported-model warning |
| Async scheduling | Enabled by default for the recorded V2/MP configuration; source-derived | Enabled explicitly |
| Reserve full input sequence length | `scheduler_reserve_full_isl=true`, default | Explicitly false |
| Prefill compute share | No corresponding option found in this standard pin | Explicit `0.4` |
| Draft sampling | `greedy`, captured resolved default | Explicit `probabilistic` |
| Draft attention | Inherits target FlashInfer backend; logged | Explicit B12X |
| Draft TP | Inherits target TP4 | Explicit TP4 |
| Adaptive verification | Disabled | Enabled; cost scale 1.0 |
| Engram configuration | Legacy `cpu_offload=true` | Native `table_memory=ram`, `cpu_offload=false` |
| Other Engram settings | No equivalent native placement/projection fields; `embedding_across_dp=false`, `use_thp=false` | `disk_resident_scales=false`, `projection_tp=false`, `embedding_across_dp=false` |
| TP communication | `PYNCCL` | `B12X_PCIE`, then `PYNCCL` |
| NCCL | 2.30.7 | 2.31.2 |

The standard maximum of 1,024 sequences follows the installed default for this GPU memory tier, with no launch override. It is an engine capacity and profiling setting; it does not mean AgentX tested concurrency 1,024. Larger sequence and batch limits can change buffer allocation, profiling, and graph preparation even when the client sends fewer concurrent requests. Their individual throughput effects were not isolated by these runs.

Cache block sizes describe different layers of the allocator. CSF requested a main block of 256 and SWA blocks of 128; its group LCM was 256, while its exported global cache-config label later reported 128. The standard run used main blocks of 64 and SWA groups of 32. Neither engine has one universal physical page size. Record widths, compression ratios, group sharing, alignment, and retained sliding windows also affect allocation.

CUDA graphs and `torch.compile` are separate mechanisms. Both runs captured CUDA graphs. Although CSF initially printed `VLLM_COMPILE`, its workers then warned that this model did not support `torch.compile`. That initial field is not evidence of compiled CSF inference outperforming uncompiled standard inference.

DSpark K7 gives both deployments the same configured draft length. Greedy versus probabilistic drafting changes how draft candidates are chosen. Adaptive verification can change verification behavior according to its policy. Consequently, K7 alone does not establish identical speculative work or accepted-token counts. Both used normal speculation rather than a forced, calibrated acceptance target.

Both Engram paths keep the large tables in **host RAM**. The opposite `cpu_offload` values select different implementations; CSF's `cpu_offload=false` does not mean its tables reside in GPU memory. Its native path allocates mapped host RAM for GPU access. The standard path uses the older CPU-offload API. Neither configuration here requests disk-resident tables.

**Weights, activations, and caches.** These are separate precision choices. A BF16 model dtype does not establish BF16 expert weights or BF16 KV storage. Likewise, a single `fp8` cache flag does not describe every model-owned cache in the CSF implementation.

| Component or setting | Standard K7, including new explicit-FP8 recipe | Completed CSF deployment |
|---|---|---|
| Checkpoint | `deepseek-ai/DeepSeek-V4.1-Flash-1017` | `local-inference-lab/DeepSeek-V4.1-Flash-1017-lossless-CSF` |
| Quantization implementation | `deepseek_v4_fp8` | `mxfp4_csf` |
| Loading | `auto` | `mxfp4_csf`; lazy safetensors |
| Checkpoint quantization metadata | Dynamic FP8; 32×32 weight blocks; UE8M0 scales; FP4 experts | Same underlying quantization metadata, with CSF storage |
| Model computation dtype | BF16 | BF16 |
| Expert weight storage | MXFP4 with ordinary scale representation | Lossless CSF representation of MXFP4 and compressed scales |
| Other checkpoint tensors | FP8 attention/shared-expert weights; BF16 embeddings, output head and norms; some FP32 auxiliary tensors | Original tensor payloads retained |
| Actual MoE path | `B12X_MXFP4_BF16`, forced by `VLLM_B12X_MOE_FP4_FORCE_A16=1` | `B12X_MXFP4_MXFP8` |
| Dense linear path | FlashInfer CUTLASS MXFP8 kernel; an emulation MXFP8 kernel also appears during loading | Native B12X linear backend |
| KV CLI setting | Previously `auto`; new recipe explicitly `fp8` | Explicit `fp8` |
| Internal cache identifier | `fp8_ds_mla` | Native B12X `b12x_dsv41` |
| Compressed/indexed KV | Packed FP8 plus BF16 RoPE; 584 bytes per stored record | NVFP4; 288 bytes per stored record |
| Sliding-window KV | Packed FP8 plus BF16 RoPE; 584 bytes per stored record | MXFP8; 528 bytes per stored record |
| Indexer K cache | FP8; 132 bytes per stored record | MXFP4; 68 bytes per stored record |

“Lossless CSF” describes the checkpoint's storage representation. It does not establish identical activation quantization, attention kernels, cache precision, generated outputs, or floating-point execution between these deployments. The standard expert path is commonly described as W4A16: four-bit weights with BF16 activations. CSF uses W4A8 with MXFP8 activations. Those labels describe operands, **not accumulator precision**, and neither implies the entire model runs at that precision.

The standard SM12 KV record contains 448 FP8 NoPE dimensions, 64 BF16 RoPE dimensions, seven UE8M0 scale bytes, and padding. CSF's SWA record stores all 512 dimensions as FP8 with 16 UE8M0 scales. Its compressed record contains 256 bytes of packed E2M1 values and 32 E4M3 scale bytes: NVFP4. Its indexer uses packed E2M1 values with UE8M0 scales: MXFP4. These formats were traced through cache specifications and production writers, not inferred solely from byte counts. Compression ratios and page organization mean “bytes per record” is not automatically “bytes per input token across the engine.”

The installed standard pin cannot select CSF's complete cache combination on these GPUs through supported flags alone. Its MXFP4 indexer rejects SM120, and its NVFP4 compressed-cache support requires the SM10x mega-attention implementation. Its generic `B12X` attention option is not the CSF fork's native DeepSeek adapter. The explicit-FP8 recipe therefore preserves the existing standard layouts.

**Memory accounting.** The audited allocations are approximately 3.44 GiB of KV memory per GPU for standard versus 14.10 GiB for CSF. Within a roughly 90.31 GiB per-GPU budget, the profiling snapshots report 77.26 versus 73.64 GiB already consumed. The standard 9.61 GiB peak figure **includes** a 5.13 GiB graph estimate, leaving approximately 4.48 GiB of transient activation increase. CSF reports approximately 0.81 GiB transient increase plus 1.76 GiB estimated graph memory. Thus the corresponding rounded calculations are `90.31 − 77.26 − 9.61 ≈ 3.44` and `90.31 − 73.64 − 0.81 − 1.76 ≈ 14.10`.

The archived C32 cache metrics report capacities of **1,342,842 tokens** for standard and **11,464,810 tokens** for CSF. These are engine-level, group-aware capacity estimates derived from maximum concurrency at the configured context length. They are not per-GPU token counts to multiply by four, and they are not measured output throughput. Larger available KV budgets and smaller CSF cache records both matter. The exact approximately 2.08-fold difference in capacity per GiB has not been fully reconstructed across allocator groups and padding; it must not be attributed to a supposed BF16 standard KV cache.

**Remaining launch and API settings.** Some differences affect presentation or default request handling rather than the measured text workload directly.

| Setting | Standard K7, including new explicit-FP8 recipe | Completed CSF deployment |
|---|---|---|
| Multimodal encoder TP | Explicit `data` | Not explicit; resolved default not captured |
| Generation configuration source | `auto`; no `generation_config.json` in the original snapshot | `vllm`, with explicit overrides |
| Temperature / top_p | Fallback 1.0 / 1.0; source-derived | Explicit 1.0 / 1.0 |
| Default chat-template kwargs | No explicit override; tokenizer defaults to thinking=true, effort=high | Explicit thinking=true, effort=high |
| AgentX thinking override | `thinking=false`, `enable_thinking=false` | Same |
| Tokenizer / reasoning / tool parsers | `deepseek_v41` | Same names; different installed implementations |
| Automatic tool choice | Enabled | Enabled |
| Prompt-token details | Disabled by default | Enabled |
| Forced usage inclusion | Disabled by default | Enabled |
| Request-ID response headers | Disabled by default | Enabled |
| API authentication | API key configured | No API key configured |
| Served model name | `deepseek` | `local-inference-lab/DeepSeek-V4.1-Flash-1017-lossless-CSF` |
| Host / port | `0.0.0.0:8000` | Same |

Generation-config selection differs, but the audited temperature and top_p defaults agree. AgentX explicitly disabled thinking on both servers, overriding their thinking defaults. Usage and prompt-detail options control response metadata; request-ID headers support request correlation. They should not be mistaken for model quantization settings. Identical parser names also do not prove identical formatting code; each deployment's formatter was audited against the corpus.

Both completed runs used AgentX harness 1.0.7 with `semianalysisai/cc-traces-weka-062126-256k`, revision `8fecd2fc56694469f758f0afbbb6335ad3043740`, containing 393 sessions. Each tested C1, C2, C4, C8, C16, and C32 for a 3,600-second measurement window, with warmup and drain outside that window. Concurrency means simultaneous replay lanes/sessions, not GPU count or an instruction to add per-user token rates. Both used seed 42, first-turn prefix cache busting, streaming, server token counts, and the same trace-delay and warmup settings. The 524,288 server cap accommodates the audited 256K corpus; it does not turn that corpus into a 512K workload.

The standard run used real, uncalibrated speculative acceptance. CSF used adaptive verification, which the pinned comparison methodology exempts from synthetic acceptance calibration. A native AgentX validity flag establishes replay validity; it does not independently establish every deployment's acceptance-calibration qualification. These results compare the observed deployments, including their differing speculative policies.

**Provenance.** Repository links above are portable. The following absolute paths are host-only evidence and will not resolve in a GitHub checkout elsewhere:

- [Standard final-point server log](/root/benchmarks/agentx/noncsf-k7/server-20261030-075650-cae37307.log) and [captured server evidence](/root/benchmarks/agentx/noncsf-k7/server-evidence-20261030-075650-cae37307.json): actual command, installed versions, resolved speculative defaults, kernels, and initialization.
- [CSF startup log](/root/benchmarks/agentx/server-startup-524288.log) and [completed CSF run plan](/root/benchmarks/agentx/runs/published256k-20261029-142253/run-plan.json): explicit settings and the exact stopped container `8083fd1dbf30…`, image `bc48d33e…`, associated with all six points.
- [CSF source manifest](/root/benchmarks/agentx/research/csf-kv-source-3687o_91/source-manifest.json): preserved, hashed attention/cache/indexer sources copied from that exact stopped container. The cache specifications and production quantizers establish the component formats above.
- [Standard run plan](/root/benchmarks/agentx/runs/noncsf-normal-256k-20261030-001638/run-plan.json): six-point workload and links to native per-point outputs, including the archived C32 `server_metrics_export.json` files used for capacity figures.
- [Installed standard source](/root/env_rtxpro6k-deepseek-v41-1017-vllm-pr-60762/lib/python3.12/site-packages/vllm): `engine/arg_utils.py` establishes sequence defaults; `models/deepseek_v41/attention.py` establishes KV resolution/layout; tokenizer and configuration sources establish the explicitly qualified defaults.
