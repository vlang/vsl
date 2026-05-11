# OpenCL GPU Acceleration

Learn GPU computing with OpenCL and VSL's VCL integration.

## What You'll Learn

- OpenCL basics
- GPU programming
- Kernel development
- VSL `vcl/compute` high-level operations

## OpenCL Usage

```v ignore
import vsl.vcl
import vsl.vcl.compute

mut dev := vcl.get_default_device()!

// High-level GEMM (column-major)
a := [1.0, 3.0, 2.0, 4.0] // 2x2 matrix in column-major
b := [5.0, 7.0, 6.0, 8.0] // 2x2 matrix in column-major
c := compute.gemm_vcl(mut dev, a, b, 2, 2, 2)!

println(c)
```

## Available `vcl/compute` operations

VSL includes OpenCL compute helpers in `vsl.vcl.compute`:

- BLAS-like: `gemm_vcl`, `gemm_vcl_f32`, `gemv_vcl`
- Elementwise activations: `relu_vcl`, `sigmoid_vcl`, `tanh_vcl`,
  `gelu_vcl`, `leaky_relu_vcl`, `elu_vcl`
- Broadcast ops: `add_scalar_vcl`, `mul_scalar_vcl`, `add_vec_vcl`,
  `mul_vec_vcl`, `broadcast_bias_vcl`
- Reductions: `sum_vcl`, `mean_vcl`, `max_vcl`
- NN-oriented ops: `softmax_vcl`, `layernorm_vcl`, `conv2d_vcl`

## Build and run notes

- Install OpenCL headers/runtime for your platform.
- If multiple OpenCL devices are available, test device selection
  with VCL utilities before long runs.
- For end-to-end usage from tensors and ML layers, see VTL examples using `-d vcl`.

## Next Steps

- [Examples](../../examples/vcl_opencl_basic/) - Working examples
- [Kernel parameters example](../../examples/vcl_opencl_kernel_params/)
  - OpenCL kernel argument usage
