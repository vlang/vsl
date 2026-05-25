# CUDA Examples

Simple examples demonstrating the `vsl.cuda` compute backend.

## Available Examples

| Example | Description |
|---------|-------------|
| [`relu_example.v`](./relu_example.v) | Element-wise ReLU activation |
| [`gemm_example.v`](./gemm_example.v) | General matrix-matrix multiply (GEMM) |

## Running

```sh
# With CUDA support (requires CUDA Toolkit + cuDNN on build machine)
v -d cuda run cuda/examples/relu_example.v
v -d cuda run cuda/examples/gemm_example.v

# Without CUDA: falls back to CPU automatically
v run cuda/examples/relu_example.v
v run cuda/examples/gemm_example.v
```

## Status

All examples currently exercise the CPU fallbacks. Once Phase C is complete
(cuBLAS/cuDNN bindings), these will run on the NVIDIA GPU.

See [issue #238](https://github.com/vlang/vsl/issues/238) for progress.