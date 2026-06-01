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

With `-d cuda` and CUDA/cuDNN available, these examples exercise GPU kernels.
Without CUDA, they fall back to CPU where the wrapper supports a fallback.

See [cuda/README.md](../README.md) for backend status and requirements.