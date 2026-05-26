# CUDA GPU Acceleration

Learn GPU computing with NVIDIA CUDA and VSL's CUDA backend (cuBLAS + cuDNN).

## What You'll Learn

- CUDA basics with VSL
- cuBLAS GEMM operations
- cuDNN activation functions
- Neural network training on GPU

## CUDA Usage

### 1. Verify GPU Access

```bash
nvidia-smi  # Should display your NVIDIA GPU and driver version
nvcc --version  # Should show CUDA toolkit version
```

### 2. Set Up Environment

```bash
# Arch Linux
export LD_LIBRARY_PATH=/opt/cuda/lib64:/usr/lib:$LD_LIBRARY_PATH

# Ubuntu
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
```

### 3. Basic GEMM on GPU

```v
import vsl.compute

fn main() {
	mut ctx := compute.new_context(.cuda)
	println('Backend: ${ctx.backend}') // cuda

	// Matrix multiplication: 2x3 @ 3x2 = 2x2
	a := [f64(1), 2, 3, 4, 5, 6]
	b := [f64(7), 8, 9, 10, 11, 12]
	c := compute.gemm(ctx, a, b, 2, 2, 3)!
	println('Result: ${c}') // [58.0, 64.0, 139.0, 154.0]
}
```

### 4. Activation Functions

```v
import vsl.compute

fn main() {
	mut ctx := compute.new_context(.cuda)

	x := [f64(-1.0), 2.0, -3.0, 4.0]

	relu_out := compute.relu(ctx, x)!
	sigmoid_out := compute.sigmoid(ctx, x)!
	tanh_out := compute.tanh(ctx, x)!

	println('relu: ${relu_out}') // [0.0, 2.0, 0.0, 4.0]
	println('sigmoid: ${sigmoid_out}')
	println('tanh: ${tanh_out}')
}
```

## Compile and Run

```bash
# Compile with CUDA support (-d cuda flag)
v -d cuda run your_app.v

# Run tests with CUDA
v -d cuda test .
```

## Requirements

| Component | Minimum | Tested |
|-----------|---------|--------|
| NVIDIA GPU | Compute capability ≥ 5.0 | RTX 4060 (8.9) |
| NVIDIA Driver | ≥ 525.60 | 595.71 |
| CUDA Toolkit | ≥ 11.8 | 13.2 |
| cuDNN | ≥ 8.0 | 9.2 |

## Available `compute` Operations

All operations in `vsl.compute` dispatch to CUDA when the context is set to `.cuda`:

| Operation | cuBLAS/cuDNN | Description |
|-----------|--------------|-------------|
| `gemm` | `cublasDgemm` | Matrix-matrix multiplication |
| `gemv` | `cublasDgvm` | Matrix-vector multiplication |
| `relu` | `cuDNNReLU` | Rectified Linear Unit |
| `sigmoid` | `cuDNNSigmoid` | Sigmoid activation |
| `tanh` | `cuDNNTanh` | Hyperbolic tangent |
| `softmax` | `cuDNNSoftmaxForward` | Softmax activation |
| `layernorm` | `cuDNNLayerNorm` | Layer normalization |
| `conv2d` | `cuDNNConvolutionForward` | 2D convolution |

## Device Caching

The `ComputeContext` caches the `CudaDevice` after the first operation to avoid
repeated cuBLAS/cuDNN handle creation. This is required because creating multiple
handles can fail with `CUBLAS_STATUS_ALLOC_FAILED`.

**Important:** compute functions accept `ctx` (no `mut` at call site):

```v
import vsl.compute

fn main() {
	ctx := compute.new_context(.cuda)
	x := [f64(-1.0), 2.0, -3.0, 4.0]

	// ✅ Correct
	result_ok := compute.relu(ctx, x)!
	println(result_ok)
}
```

## Neural Network Example

See [XOR Training Example](../../examples/ml_nn_xor/) for a complete MLP training
on GPU with Dense layers, ReLU activations, Sigmoid output, and manual backpropagation.

## Next Steps

- [CUDA Backend Docs](../../cuda/README.md) — Full CUDA reference
- [XOR Training Example](../../examples/ml_nn_xor/) — MLP on GPU
- [OpenCL GPU Docs](./02-opencl-gpu.md) — Alternative GPU backend
