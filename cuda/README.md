# CUDA Compute Backend for VSL 🖥️

`vsl.cuda` is a high-performance GPU compute backend for VSL backed by
[NVIDIA CUDA](https://developer.nvidia.com/cuda-toolkit) (cuBLAS + cuDNN).

## 🚀 Status

> **Phase B/C — cuBLAS/cuDNN bindings active** when CUDA Toolkit + cuDNN are
> available at build time (`-d cuda`). Operations use GPU kernels where
> implemented; CPU fallback when CUDA/cuDNN is unavailable.
>
> **VTL integration** (opt-in CUDA Linear/Conv2D): merged in
> [vlang/vtl#93](https://github.com/vlang/vtl/pull/93) (issues #89–#91 closed).

| Operation | GPU (CUDA+cuDNN) | Fallback | Tracker |
|-----------|------------------|----------|---------|
| `gemm` | ✅ `cublasDgemm` | CPU col-major | — |
| `gemv` | ✅ `cublasDgemv` | CPU | — |
| `relu` / `sigmoid` / `tanh` | ✅ cuDNN activation | CPU | — |
| `add_vec` | ✅ `cublasDaxpy` | CPU | — |
| `mul_vec` | ✅ `cublasDdgmm` | CPU | — |
| `add_scalar` / `mul_scalar` | ✅ cuBLAS/cuDNN path | CPU | — |
| `softmax` | ✅ `cudnnSoftmaxForward` | CPU | — |
| `layernorm` | optional `-d cudnn_layernorm` | CPU | — |
| `conv2d` | ✅ `cudnnConvolutionForward` | CPU | — |

`mul_vec` uses legacy `cublasDdgmm` (`SIDE_RIGHT`, 1×n row layout;
`cublasDdgmm_v2` absent on some distros). Layer norm GPU: build with
`-d cudnn_layernorm` when libcudnn exports `cudnnLayerNormForward` (9.1+).
Numerical parity tests: `cuda/compute/numerical_validation_test.v` ([#281](https://github.com/vlang/vsl/issues/281)).

## 📁 Architecture

```
vsl.cuda
├── backend.v           # CUDABackend (ComputeBackend interface impl)
├── compute/
│   ├── elementwise.v   # Activation functions (relu, sigmoid, tanh, ...)
│   ├── gemm.v          # Public GEMM wrapper (row↔col conversion)
│   └── gemm_impl.v     # Internal GEMM/GEMV stubs + CPU fallbacks
└── v.mod
```

**Memory layout:** cuBLAS is column-major (same as VCL/Vulkan). The
`CUDABackend.to_internal()` / `from_internal()` methods handle row↔column-major
conversion at the dispatch boundary.

## 🎯 Quick Start

```v ignore
import vsl.compute

// Use CUDA backend automatically when available
ctx := compute.new_context(.cuda)

// All compute operations dispatch to CUDA when the backend is set
a := []f64{len: 6}
b := []f64{len: 6}
// ... fill a, b ...

result := compute.add_vec(ctx, a, b)!
```

Or directly via the backend:

```v ignore
import vsl.cuda

mut dev := cuda.get_default_device()!
mut backend := cuda.new_cuda_backend()

result := backend.relu(my_data)!
```

## 🔧 Requirements

### Runtime (at runtime)

- **NVIDIA GPU** with compute capability ≥ 5.0 (Maxwell or newer)
- **NVIDIA Driver** ≥ 525.60 (for CUDA 12.x)
- **CUDA Toolkit** ≥ 11.8
- **cuDNN** ≥ 8.0

### Build time (for CUDA GPU builds)

- `nvcc` (NVIDIA C compiler) in `$PATH`
- CUDA Toolkit headers (`cuda.h`, `cublas.h`, `cudnn.h`)
- cuDNN headers

## 📦 Installation

### Arch Linux

```sh
# NVIDIA driver (verify with nvidia-smi)
sudo pacman -S nvidia nvidia-utils

# CUDA Toolkit (includes cuBLAS)
sudo pacman -S cuda

# cuDNN (must match CUDA version)
sudo pacman -S cudnn

# Verify
nvcc --version        # should show 12.x or 13.x
nvidia-smi            # should show your GPU
```

### Ubuntu / Debian

```sh
# NVIDIA driver
sudo apt-get install nvidia-driver-535

# CUDA Toolkit
wget https://developer.downloads.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get install cuda-toolkit-12-2

# cuDNN
sudo apt-get install libcudnn8 libcudnn8-dev
```

### macOS

CUDA Toolkit is no longer supported on macOS arm64 (Apple Silicon).
For GPU acceleration on Apple Silicon, use the VCL/OpenCL backend instead.

## 🏗️ Compiling with CUDA

VSL uses conditional compilation (`$if cuda ?`) to include CUDA code:

```sh
# Compile with CUDA backend
v -d cuda run your_app.v

# Run tests with CUDA
v -d cuda test .

# Lint with CUDA
v -d cuda vet .
```

Set `CUDNN_PATH` if cuDNN is not in a standard location:

```sh
CUDNN_PATH=/opt/cuda v -d cuda run your_app.v
```

## ⚡ Performance Notes

- **GEMM (matrix-matrix)** — the highest-impact primitive. cuBLAS `dgemm` is
  heavily optimized for NVIDIA Tensor Cores on Ampere+ GPUs.
- **cuDNN activations** — fused kernels for ReLU, Sigmoid, Tanh provide ~2-5x
  speedup over CPU for large tensors.
- **Memory layout** — cuBLAS uses column-major; VSL uses row-major. The
  `to_internal()` / `from_internal()` conversion adds overhead for small
  tensors but is negligible for large matrices (≥ 256×256).

## 🧪 Examples

See the [`cuda/examples/`](./examples/) directory:

```sh
# Run CUDA backend smoke test
v -d cuda run cuda/examples/relu_example.v
```

## 🗺️ Roadmap

| Phase | Description |
|-------|-------------|
| ✅ **Phase B** | Infrastructure ready; stub implementations with CPU fallbacks |
| 🎯 **Phase C** | Replace stubs with actual cuBLAS/cuDNN kernels (issue #238) |
| 🏗️ **Phase D** | Device discovery, multi-GPU support |
| 🧠 **Phase E** | GPU memory management (avoid CPU↔GPU copies) |
| 🧪 **Phase F** | Test suite, numerical validation vs reference |

## 🔗 Resources

- [VSL Documentation](https://vlang.github.io/vsl)
- [cuBLAS Documentation](https://docs.nvidia.com/cublas/)
- [cuDNN Documentation](https://docs.nvidia.com/cudnn/)
- [CUDA Toolkit Download](https://developer.nvidia.com/cuda-downloads)
- [VSL ADR-001: Multi-backend GPU compute](./docs/adr/ADR-001-multi-backend-gpu-compute-vsl.md)

---

Accelerate your scientific computing with NVIDIA GPUs! 🚀