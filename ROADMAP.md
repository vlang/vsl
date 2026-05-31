# VSL Neural Network & Compute Backend Roadmap

> **Goal**: Production-grade compute backend for VTL neural networks — CUDA/GPU acceleration,
> multi-backend dispatch, NumPy-comparable performance benchmarks.

**Repositories**: [vlang/vsl](https://github.com/vlang/vsl) (compute) · [vlang/vtl](https://github.com/vlang/vtl) (neural networks)

---

## ✅ Completed

### Phase A — Vulkan Compute Foundation
- [x] Issue [#237](https://github.com/vlang/vsl/issues/237) — Vulkan Compute Backend for VSL Matrix/Vector
- [x] `vsl/vulkan/compute/backend.v` — `VulkanBackend` implementing `ComputeBackend` interface
- [x] `vsl/vulkan/compute/elementwise.v` — ReLU, Sigmoid, Tanh, ELU
- [x] `vsl/vulkan/compute/gemm.v` — Matrix-matrix multiply
- [x] `vsl/vulkan/compute/gemv.v` — Matrix-vector multiply

### Phase B — CUDA Backend (Infrastructure)
- [x] Issue [#238](https://github.com/vlang/vsl/issues/238) — Phase B: CUDA Backend for VSL Matrix/Vector
- [x] `vsl/cuda/backend.v` — `CUDABackend` implementing `ComputeBackend` interface
- [x] `vsl/cuda/compute/elementwise.v` — Activation stubs (ReLU, Sigmoid, Tanh, Softmax)
- [x] `vsl/cuda/compute/gemm.v` — GEMM with row↔column-major conversion
- [x] GPU device enumeration, context caching, memory management

### Phase C — cuBLAS/cuDNN Kernel Implementation
- [x] Issue [#239](https://github.com/vlang/vsl/issues/239) — Phase C: OpenCL Backend (VCL unified into Compute)
- [x] `vsl/cuda/compute/gemm_impl.v` — cuBLAS `dgemm` integration
- [x] `vsl/cuda/compute/elementwise.v` — cuDNN activation kernels
- [x] `vsl/cuda/compute/conv2d.v` — cuDNN convolution forward
- [x] `vsl/cuda/compute/softmax.v` — cuDNN softmax
- [x] `vsl/cuda/compute/layernorm.v` — cuDNN layer normalization

### Phase D — VCL OpenCL Backend
- [x] `vsl/vcl/compute/` — VCL/OpenCL backend implementing `ComputeBackend`
- [x] Device discovery, memory management, kernel compilation

### Phase E — Compute Interface Standardization
- [x] Issue [#236](https://github.com/vlang/vsl/issues/236) — GPU Architecture: Multi-Backend GPU Acceleration for VSL
- [x] `vsl/compute/context.v` — Unified `ComputeContext` with backend dispatch
- [x] `vsl/compute/interface.v` — `ComputeBackend` trait for all backends

### Benchmark Infrastructure
- [x] `benchmarks/blas_bench.v` — Pure V BLAS Level 1/2/3 benchmarks
- [x] `benchmarks/lapack_bench.v` — LAPACK operation benchmarks
- [x] `benchmarks/compare_backends.v` — Pure V vs C backends (OpenBLAS/LAPACKE)

---

## 🎯 Active Development

### Phase F — cuBLAS/cuDNN Full Integration — [issue #280](https://github.com/vlang/vsl/issues/280)
- [ ] Replace remaining CPU-fallback stubs (`layernorm`, `mul_vec`) with GPU kernels
- [ ] GEMV: `cublasDgemv` for matrix-vector operations
- [ ] Softmax: `cuDNNSoftmaxForward` for batch softmax
- [ ] LayerNorm: `cuDNNLayerNorm` for layer normalization
- [ ] Conv2D: `cuDNNConvolutionForward` for 2D convolution
- [ ] Bias addition, gradient operations

### Phase G — NumPy Performance Benchmarks — [issue #282](https://github.com/vlang/vsl/issues/282)
- [ ] `benchmarks/vs_numpy/` directory with VTL vs NumPy comparison:
  - `benchmarks/vs_numpy/matmul.v` — Matrix multiplication (CPU + CUDA)
  - `benchmarks/vs_numpy/conv2d.v` — 2D Convolution (CPU + CUDA)
  - `benchmarks/vs_numpy/autograd.v` — MLP backprop (VTL vs PyTorch)
  - `benchmarks/vs_numpy/training.v` — End-to-end training step
- [ ] CI integration: GH Actions workflow runs on every PR
- [ ] Post results as PR comment with: VTL time, NumPy time, speedup ratio
- [ ] Threshold: fail PR if VTL is >3x slower than NumPy (with justification for known gaps)

### Phase H — Multi-GPU Support
- [ ] Device discovery: enumerate all CUDA devices
- [ ] `ComputeContext.device_id()` — select target device
- [ ] Data parallelism: batch split across GPUs
- [ ] `DeviceArray[T]` abstraction for multi-device tensors

### Phase I — GPU Memory Management
- [ ] Zero-copy tensor representation (no CPU↔GPU sync unless needed)
- [ ] Memory pool allocator for frequently allocated buffers
- [ ] `to_internal()` / `from_internal()` elimination for pinned memory
- [ ] Unified memory space with explicit `to_device()` / `to_host()` calls

### Phase J — Numerical Validation Test Suite — [issue #281](https://github.com/vlang/vsl/issues/281)
- [ ] `cuda/tests/numerical_validation.v` — compare GPU output to CPU reference
- [ ] Tolerance: `|gpu_result - cpu_result| < 1e-10` for BLAS operations
- [ ] Random test vectors, stress tests with extreme sizes
- [ ] cuDNN persistent RNN fusion validation
- [ ] Cross-backend validation: Vulkan vs CUDA results must match

---

## 🧩 Existing Open Issues (VSL)

| # | Title | Priority | Notes |
|---|-------|----------|-------|
| [#244](https://github.com/vlang/vsl/issues/244) | Vulkan: comprehensive unit tests | 🔴 High | GPU compute validation |
| [#243](https://github.com/vlang/vsl/issues/243) | Vulkan: replace panics with error propagation | 🔴 High | Robustness |
| [#242](https://github.com/vlang/vsl/issues/242) | Vulkan: enable validation layers in debug | 🟡 Medium | DX/validation |
| [#241](https://github.com/vlang/vsl/issues/241) | Vulkan: prefer discrete GPUs | 🟡 Medium | Laptop hybrid GPU |
| [#240](https://github.com/vlang/vsl/issues/240) | Vulkan: constant audit against spec | 🟡 Medium | Correctness |
| [#239](https://github.com/vlang/vsl/issues/239) | Phase C: OpenCL Backend | 🟢 Done | VCL integrated |
| [#238](https://github.com/vlang/vsl/issues/238) | Phase B: CUDA Backend | 🟢 Done | Infrastructure |
| [#237](https://github.com/vlang/vsl/issues/237) | Phase A: Vulkan Compute | 🟢 Done | |
| [#280](https://github.com/vlang/vsl/issues/280) | CUDA stubs + docs (LayerNorm, mul_vec) | 🔴 P0 | |
| [#281](https://github.com/vlang/vsl/issues/281) | GPU numerical validation | 🔴 P0 | |
| [#282](https://github.com/vlang/vsl/issues/282) | vs NumPy benchmarks | 🔴 High | |
| [#283](https://github.com/vlang/vsl/issues/283) | Fix vulkan_test.v crash | 🔴 P0 | Gate B |
| [#284](https://github.com/vlang/vsl/issues/284) | Vulkan conv2d | 🟡 Medium | |
| [#285](https://github.com/vlang/vsl/issues/285) | ComputeContext unit tests | 🟡 Medium | |
| [#231](https://github.com/vlang/vsl/issues/231) | implicit declaration `cblas_idamax` | 🟡 Medium | |
| [#226](https://github.com/vlang/vsl/issues/226) | vcl: examples not working | 🟡 Medium | |
| [#225](https://github.com/vlang/vsl/issues/225) | vsl Error on Windows | 🟡 Medium | |
| [#206](https://github.com/vlang/vsl/issues/206) | noise: add simplex noise | 🟡 Medium | |
| [#204](https://github.com/vlang/vsl/issues/204) | vcl macOS broken | 🟡 Medium | |

---

## 🔗 VTL ↔ VSL Integration Points

| VTL Component | VSL Backend | Status |
|--------------|-------------|--------|
| `vtl.la.matmul` | `vsl.la.matmul` | ✅ Done |
| `vtl.la.conv2d` | `vsl.cuda/ Vulkan` | 🟡 Stub, needs cuDNN |
| `vtl.autograd` gates | `vsl.compute` dispatch | ✅ Done |
| `vtl.nn.layers.LSTM` | `vsl.cuda/gemv` | ✅ Done |
| `vtl.nn.optimizers` | CPU-backed | ✅ Done |
| `vtl.datasets` I/O | Host-side | ✅ Done |

---

## NumPy Benchmark Reference

### Matmul (GEMM) — NumPy baseline

```python
import numpy as np
import time

def benchmark_matmul(n, iterations=100):
    a = np.random.rand(n, n).astype(np.float64)
    b = np.random.rand(n, n).astype(np.float64)

    # Warmup
    for _ in range(3):
        np.dot(a, b)

    start = time.perf_counter()
    for _ in range(iterations):
        np.dot(a, b)
    elapsed = (time.perf_counter() - start) / iterations

    gflops = (2 * n**3) / elapsed / 1e9
    return elapsed, gflops

for n in [256, 512, 1024, 2048]:
    t, g = benchmark_matmul(n)
    print(f"n={n:4d}: {t*1e3:.3f}ms, {g:.1f} GFLOPS")
```

### Conv2D — NumPy baseline (scipy)

```python
import numpy as np
from scipy import signal

def benchmark_conv2d(batch, cin, h, w, cout, kh, kw, iterations=50):
    x = np.random.rand(batch, cin, h, w).astype(np.float64)
    w = np.random.rand(cout, cin, kh, kw).astype(np.float64)

    start = time.perf_counter()
    for _ in range(iterations):
        signal.correlate2d(x[0, 0], w[0, 0], mode='valid')
    elapsed = (time.perf_counter() - start) / iterations

    return elapsed
```

### Autograd Backprop — PyTorch baseline

```python
import torch
import time

def benchmark_backprop(batch, in_dim, hidden, out_dim, iterations=50):
    model = torch.nn.Sequential(
        torch.nn.Linear(in_dim, hidden),
        torch.nn.ReLU(),
        torch.nn.Linear(hidden, out_dim)
    ).double()

    x = torch.randn(batch, in_dim, requires_grad=True)
    y = torch.randn(batch, out_dim)

    # Warmup
    out = model(x)
    loss = (out - y).pow(2).sum()
    loss.backward()

    torch.cuda.synchronize() if torch.cuda.is_available() else None
    start = time.perf_counter()
    for _ in range(iterations):
        for p in model.parameters():
            p.grad = None
        out = model(x)
        loss = (out - y).pow(2).sum()
        loss.backward()
    torch.cuda.synchronize() if torch.cuda.is_available() else None
    elapsed = (time.perf_counter() - start) / iterations

    return elapsed
```

---

## 🗺️ Compute Backend Roadmap (Detailed)

```
Phase A (Vulkan)     ✅ Done  — backend.v, gemm, gemv, elementwise
Phase B (CUDA stub)  ✅ Done  — CUDABackend, compute/, stubs with CPU fallback
Phase C (cuBLAS/cuDNN) ✅ Done — dgemm, relu, sigmoid, tanh, add_scalar, mul_scalar,
                              softmax, conv2d, layernorm all using real kernels
Phase D (Multi-GPU)  🔴 TODO  — device enumeration, data parallelism
Phase E (Memory)     🔴 TODO  — zero-copy, memory pool, pinned memory
Phase F (Validation) 🔴 TODO  — numerical tests, cross-backend verification
Phase G (Benchmarks)  🔴 TODO  — vs NumPy CI integration
```

---

## 📁 Key Files

### VSL Compute
```
vsl/
├── compute/
│   ├── interface.v      # ComputeBackend interface
│   └── context.v        # ComputeContext dispatch
├── cuda/
│   ├── backend.v        # CUDABackend
│   ├── compute/
│   │   ├── elementwise.v # cuDNN activations
│   │   ├── gemm.v        # cuBLAS GEMM wrapper
│   │   ├── gemm_impl.v   # Stub + CPU fallback
│   │   ├── conv2d.v      # cuDNN conv2d
│   │   ├── softmax.v     # cuDNN softmax
│   │   └── layernorm.v   # cuDNN layernorm
│   └── examples/         # relu, gemm, cuda_ops_test
├── vulkan/
│   └── compute/
│       ├── backend.v    # VulkanBackend
│       ├── elementwise.v # ReLU, Sigmoid, Tanh
│       ├── gemm.v        # Matrix multiply
│       └── gemv.v        # Matrix-vector multiply
├── vcl/
│   └── compute/          # OpenCL backend
└── benchmarks/
    ├── blas_bench.v      # Pure V BLAS benchmarks
    ├── lapack_bench.v    # LAPACK benchmarks
    ├── compare_backends.v # Pure V vs C backends
    └── vs_numpy/         # (TODO) VTL vs NumPy comparison
```

### VTL Neural Networks
```
vtl/
├── nn/
│   ├── layers/          # Conv2D, LSTM, Linear, LayerNorm, Attention
│   ├── models/          # Sequential, Serialization
│   ├── optimizers/      # Adam, AdamW, SGD, AdaGrad, RMSProp
│   └── losses/          # CrossEntropy, MSE, BCE, Huber
├── datasets/
│   └── cifar10.v        # CIFAR-10 with subset config
├── autograd/
│   └── gates/           # Backprop implementations
└── examples/
    ├── nn_cifar10/       # Full CNN (local machine)
    ├── nn_cifar10_safe/  # Safe defaults
    ├── nn_cifar10_tiny/  # Real data subset
    └── nn_cifar10_tiny_synth/ # Synthetic data
```

---

*Last updated: 2026-05-26*
*See also: [VTL ROADMAP.md](https://github.com/vlang/vtl/blob/main/ROADMAP.md)*