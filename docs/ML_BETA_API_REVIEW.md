# VSL ML Beta Public API Review

This review captures the public API state for VSL as the scientific and GPU
compute foundation used by VTL during the ML beta milestone.

## Documentation Coverage

The repository now includes `tools/audit_public_docs.py`, which checks that each
public declaration has an immediate `//` comment on the previous line.

Current targeted result:

```sh
python3 tools/audit_public_docs.py --summary
# missing_public_docs=0
```

The audit covers public `fn`, `struct`, `interface`, `enum`, `type`, and `const`
declarations in tracked V files. Test files, generated shader blobs, C shims,
examples, and benchmarks are treated as non-release API by default.

## Beta-Relevant Surface

For the V language ML beta, the important VSL public surface is:

- `vsl.compute`: backend selection, backend capability checks, and
  backend-agnostic operations such as `gemm`, `gemv`, elementwise ops,
  `softmax`, `layernorm`, and `conv2d`.
- `vsl.cuda.compute`: CUDA/cuBLAS/cuDNN primitives used by VTL for training.
- `vsl.vulkan.compute` and `vsl.vulkan`: low-level synchronous GPU primitives
  used by VTL's f32 Vulkan path.
- `vsl.la` and `vsl.lapack`: linear algebra routines used directly and by VTL.
- `vsl.metrics`, `vsl.preprocessing`, and selected `vsl.ml` utilities that
  support examples and ML workflows.

## Stable vs Experimental

### Stable For Beta

- `vsl.compute` should be the recommended integration point for downstream
  libraries.
- `vsl.la`, `vsl.metrics`, and `vsl.preprocessing` can remain stable user-facing
  scientific APIs.
- CPU fallback behavior in `compute` should be documented as the portable path.

### Experimental For Beta

- `vsl.cuda.compute` and `vsl.vulkan.compute` are backend-specific and should be
  documented as low-level acceleration APIs.
- `vsl.vulkan` functions that operate on `Device`, `GpuBuffer`, and pipelines are
  synchronous GPU primitives. They are valuable, but not the primary high-level
  ML API.
- Shader-backed operations such as fused Adam, im2col, Conv2D, and elementwise
  Vulkan kernels should remain marked as beta/experimental until broader
  hardware coverage is available.
- Generated or binding-heavy surfaces in Vulkan/CUDA/VCL should not be promoted
  as stable user APIs.

## API Coherence Findings

### Should Keep

- `vsl.compute` provides a clear backend-agnostic shape for VTL and other users.
- Operation names mostly align with ML usage: `gemm`, `gemv`, `relu`, `sigmoid`,
  `tanh`, `add_vec`, `mul_vec`, `softmax`, `layernorm`, and `conv2d`.
- Explicit `Device` and `GpuBuffer` parameters in Vulkan avoid global state and
  make ownership visible.

### Should Clarify Before Beta

- `op_supported`, `ComputeBackend.supports`, and README/backend status tables
  should be kept in sync. Some backend support lists differ in detail.
- `CPUBackend.conv2d` is declared through the interface but currently returns a
  not-implemented error. User docs should not imply that CPU `compute.conv2d` is
  available through this path.
- Vulkan operations should consistently state expected element type (`f32`),
  buffer sizes, row-major layout, and synchronous dispatch behavior.
- CUDA operations should distinguish cuBLAS/cuDNN-backed paths from plain CUDA
  elementwise helpers.
- Public constants and wrappers in `consts`, `blas`, `lapack`, and generated
  binding-style modules now satisfy comment coverage, but many are inherited
  low-level APIs rather than ML-beta promises.

### Breaking-Change Candidates

Do not change these without explicit approval:

- Hide or move backend binding-style declarations out of user-facing docs.
- Normalize backend support reporting into a single table/source of truth.
- Split low-level Vulkan pipeline APIs from higher-level compute APIs.
- Rename `layernorm` to `layer_norm` for naming consistency with some ML
  literature and VTL modules.
- Add CPU `conv2d` to the `compute` interface implementation or remove it from
  backend-agnostic claims until implemented.

## Beta Recommendation

VSL is ready to serve as the ML beta foundation if the public contract is framed
as:

1. Stable: `vsl.compute` for backend-agnostic dispatch, plus established
   scientific modules such as `la`, `metrics`, and `preprocessing`.
2. Beta/experimental: CUDA and Vulkan compute primitives, especially training
   kernels and fused optimizer paths.
3. Internal or low-level: generated bindings, backend pipeline plumbing, and
   public symbols that exist for interop or conditional compilation.

