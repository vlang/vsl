# ADR-002: CUDA Backward Kernels for the VTL Training Path

**Status:** Proposed

**Tracks:** [vlang/vtl#161](https://github.com/vlang/vtl/issues/161) (backward for LSTM, Attention,
BatchNorm, LayerNorm, Embedding, Pooling). Builds on [ADR-001](./ADR-001-multi-backend-gpu-compute-vsl.md).

## Context

ADR-001 chose a backend abstraction and cuBLAS/cuDNN for CUDA. Since then the forward path
has become GPU-backed (GEMM/GEMV, activations, softmax, Conv2D, optional LayerNorm), and
Conv2D backward has landed through `cudnnConvolutionBackward*`.

The backward path is still mostly CPU. The current state, from [`cuda/README.md`](../../cuda/README.md)
and the VTL CUDA code:

| Backward op | GPU today | Notes |
|-------------|-----------|-------|
| Linear | cuBLAS (`gemm`, `mul_vec`) | Wrapper code in VTL, gradient-checked |
| Conv2D | `cudnnConvolutionBackward*` | Landed |
| Dropout | cuBLAS `mul_vec` + scale | Thin wrapper |
| LSTM | none | CPU |
| Attention | none | CPU |
| BatchNorm | none | CPU |
| LayerNorm | none (forward only, behind `-d cudnn_layernorm`) | CPU |
| Embedding | none | CPU |
| Pooling (max) | none | CPU |

Two facts shape the decision:

- **The build must stay simple.** VSL's CUDA build is `v -d cuda`, linking cuBLAS and cuDNN
  (see [CONTRIBUTING.md](../../CONTRIBUTING.md#cuda-backend-development)). A custom kernel
  path adds a compiler step (`nvcc`) or a runtime compiler (NVRTC) that every CUDA user and
  CI runner would need.
- **cuDNN 9.x already ships these backward operations.** The installed cuDNN is 9.27.0
  (`cudnn_ops.h` exports `cudnnBatchNormalizationBackward` and `cudnnPoolingBackward`,
  `cudnnNormalizationBackward` covers LayerNorm, and `cudnn_adv.h` exports the RNN and
  multi-head attention backward APIs).

## Options Considered

### Option A: Custom kernels (nvcc or NVRTC)

Write each kernel in CUDA C and compile it at build or run time.

- Pros: full control; can fuse operations; covers Embedding and attention directly.
- Cons: new build dependency and toolchain; kernels must be verified without a GPU in CI;
  maintenance of hand-written numerics on top of cuDNN.

### Option B: cuDNN backward APIs where cuDNN has them

Use `cudnnBatchNormalizationBackwardEx`, `cudnnNormalizationBackward` (LayerNorm),
`cudnnPoolingBackward` and the RNN backward API (`cudnnRNNBackwardData_v8` /
`cudnnRNNBackwardWeights_v8`).

- Pros: no new build step; tuned kernels; same error model as the existing cuDNN code;
  uses the library already linked for Conv2D.
- Cons: descriptor-heavy APIs; RNN and MHA layouts are strict; some ops (Embedding)
  have no cuDNN primitive.

### Option C: Compose from cuBLAS GEMM and cuDNN softmax

Express Embedding backward as a GEMM with a one-hot matrix; express attention backward as
GEMMs plus `cudnnSoftmaxBackward`.

- Pros: reuses existing, tested cuBLAS wrappers; easy to gradient-check against the CPU code.
- Cons: Embedding one-hot needs `vocab × batch` extra memory; attention composition is slower
  than a fused kernel.

### Option D: Keep CPU for the backward ops

- Pros: no work; no risk.
- Cons: training on GPU stays forward-only for these layers; #161 stays open.

## Decision

**Adopt Option B for BatchNorm, LayerNorm, Pooling and LSTM; Option C for Embedding and
attention; reject Option A for now.**

Concretely:

| Op | Implementation | Why |
|----|----------------|-----|
| BatchNorm | `cudnnBatchNormalizationBackwardEx` | Native primitive, same descriptor pattern as the existing Conv2D code |
| LayerNorm | `cudnnNormalizationBackward` | Native primitive; reuses the optional `cudnn_layernorm` gate |
| MaxPool | `cudnnPoolingBackward` | Native primitive |
| LSTM | `cudnnRNNBackwardData_v8` + `cudnnRNNBackwardWeights_v8` | Native primitive for the most common recurrent layer |
| Embedding | cuBLAS GEMM with a one-hot index matrix | No cuDNN primitive; one-hot cost is documented and acceptable for the vocabulary sizes VTL targets; a scatter kernel is the follow-up if profiling shows it matters |
| Attention | Composed: cuBLAS GEMM for `QKᵀ` and `PV` and their transposes, `cudnnSoftmaxBackward` | Keeps the code gradient-checkable against the CPU reference; `cudnnMultiHeadAttn*` is deferred |

Rules for every new GPU backward path:

1. **CPU fallback stays.** The CPU implementation remains the default when CUDA is not
   built or not available, and it is the reference for numerical tests.
2. **Gradient check against the CPU reference** with a tolerance (no exact float
   equality), following the test conventions in VTL's `CONTRIBUTING.md`.
3. **Gate by build flag.** New code sits under `$if cuda ?` so the default build is unchanged.
4. **Report what ran.** The GPU/CPU choice is visible in the status table of
   [`cuda/README.md`](../../cuda/README.md); no silent fallback is documented as GPU.
5. **Verification on hardware.** GitHub-hosted CI has no GPU, so each PR records the
   local command and the GPU used (CUDA 13.x, cuDNN 9.27, NVIDIA GeForce RTX 3060 in the
   first run) in its description.

## Consequences

- Phase 1: BatchNorm, LayerNorm and MaxPool backward (all cuDNN primitives). Each is
  gradient-checked against the CPU path.
- Phase 2: LSTM backward through the RNN API, with weights gradients checked against the CPU LSTM.
- Phase 3: Embedding and attention backward composed from cuBLAS. A scatter kernel and a
  fused attention path are follow-ups, to be decided by profiling, not assumed now.
- No change to the build: `v -d cuda` still links cuBLAS and cuDNN only.
- #161 closes when Phases 1–3 land with tests; each phase can merge on its own.

## Verification Plan

- `v -d cuda test` on each new `*_cuda_test.v` file, run one file at a time with
  `systemd-run --user --scope -p MemoryMax=4G` and `VJOBS=2`.
- CPU reference tests keep running in the default CI matrix.
- Benchmarks are reported separately (see the existing CUDA benchmark issue, vsl#528).
