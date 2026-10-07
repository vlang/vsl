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
	image := [f64(1), 2, 3, 4, 5, 6, 7, 8, 9]
	filter := [f64(1), 0, 0, 1]
	features := compute.conv2d(ctx, image, filter, 1, 3, 3, 1, 1, 2, 2, 1, 1)!
	assert features == [6.0, 8, 12, 14]
}
```

Public dispatch functions are:

| Operations | API |
| --- | --- |
| Matrix multiplication | `gemm`, `gemv` |
| Elementwise | `relu`, `sigmoid`, `tanh`, `add_vec`, `mul_vec`, `add_scalar`, `mul_scalar` |
| Normalization and convolution | `softmax`, `layernorm`, `conv2d` |
| Capability query | `available_backends()`, `op_supported(backend, operation)` |

`gemm` expects row-major `A[m,k]` and `B[k,n]`. `conv2d` performs unpadded
NCHW convolution: input `[batch,in_ch,in_h,in_w]`, kernel
`[out_ch,in_ch,k_h,k_w]`, and output `[batch,out_ch,out_h,out_w]`. It requires
positive channels, spatial sizes, kernel sizes, and strides; batch may be zero.
Implemented operations are backend-specific: check `available_backends()` for
build availability and `op_supported` for the operation list, then handle
returned errors. The portable CPU backend implements convolution alongside
GEMM/GEMV, activations, vector/scalar arithmetic, softmax, and layer
normalization.

The `auto` preference selects a backend compiled into the build, in the order
Vulkan, VCL, CUDA, then CPU. It does not benchmark devices. For an explicitly
selected backend that is not compiled in, a non-strict context falls back to
CPU while a strict context returns an error. Device initialization failures
still propagate to the caller.

Backend guides: [Vulkan](../vulkan/README.md), [VCL/OpenCL](../vcl/README.md),
and [CUDA](../cuda/README.md). For the older low-level helpers, see
[`gemm.v`](gemm.v) and [`elementwise.v`](elementwise.v).
