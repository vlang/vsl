# `vsl.compute`

`vsl.compute` is a backend-selection and dispatch API over flat `[]f64`
buffers. A `ComputeContext` chooses `.auto`, `.cpu`, `.cuda`, `.vulkan`, or
`.vcl`; `available_backends()` reports backends enabled in the current build.
Accelerator backends require their matching V compile-time define and native
runtime dependencies. The portable CPU implementation uses V loops.

```v
import vsl.compute

fn main() {
	ctx := compute.new_context(.cpu)
	c := compute.gemm(ctx, [1.0, 2, 3, 4], [5.0, 6, 7, 8], 2, 2, 2)!
	assert c == [19.0, 22, 43, 50]
}
```

Public dispatch functions are:

| Operations | API |
| --- | --- |
| Matrix multiplication | `gemm`, `gemv` |
| Elementwise | `relu`, `sigmoid`, `tanh`, `add_vec`, `mul_vec`, `add_scalar`, `mul_scalar` |
| Normalization and convolution | `softmax`, `layernorm`, `conv2d` |
| Capability query | `available_backends()`, `op_supported(backend, operation)` |

`gemm` expects row-major `A[m,k]` and `B[k,n]`; `conv2d` documents its NHWC
input and filter shapes in [`backend.v`](backend.v). Implemented operations are
backend-specific: check `available_backends()` for build availability and
`op_supported` for the operation list, then handle returned errors. The CPU
backend reports GEMM/GEMV, activations, vector/scalar arithmetic, softmax, and
layer normalization; accelerator operation lists are in `backend.v`.

The `auto` preference selects a backend compiled into the build, in the order
Vulkan, VCL, CUDA, then CPU. It does not benchmark devices. `ComputeContext`
contains a `strict` option, but current dispatch does not enforce it; callers
should rely on explicit backend selection, `available_backends`, and errors
until strict fallback behavior is implemented.

Backend guides: [Vulkan](../vulkan/README.md), [VCL/OpenCL](../vcl/README.md),
and [CUDA](../cuda/README.md). For the older low-level helpers, see
[`gemm.v`](gemm.v) and [`elementwise.v`](elementwise.v).
