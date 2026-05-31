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

### Phase F — cuBLAS/cuDNN Full Integration — closed [#280](https://github.com/vlang/vsl/issues/280)
- [x] `mul_vec` via `cublasDdgmm`; GEMM/GEMV/activations/softmax/conv2d on GPU
- [x] LayerNorm GPU optional (`-d cudnn_layernorm`, PR #291)
- [ ] Bias addition kernels, gradient ops (future)

### Phase G — NumPy Performance Benchmarks — closed [#282](https://github.com/vlang/vsl/issues/282)
- [x] `benchmarks/vs_numpy/` matmul, gemv, conv2d + `numpy_baseline.py`
- [x] CI job `vs-numpy-benchmarks` (weekly + PR path)
- [x] PR comment with NumPy ratio (`benchmark-pr-comment.yml`, PR #292)
- [ ] CUDA variants of bench scripts (optional)

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

### Phase J — Numerical Validation Test Suite — closed [#281](https://github.com/vlang/vsl/issues/281)
- [x] `cuda/compute/numerical_validation_test.v` (GEMM, relu, mul_vec, layernorm, conv2d)
- [ ] Extended stress sizes; Vulkan vs CUDA cross-check

---

## 🔜 Next priorities

| Priority | Work item |
|----------|-----------|
| P1 | [#225](https://github.com/vlang/vsl/issues/225) Windows |
| P1 | Phase H multi-GPU |
| P1 | Phase I GPU memory pool / zero-copy |
| P2 | CUDA benchmark variants in CI |
| P2 | Vulkan stress + cross-backend validation |

**Project board:** [vlang org project #8](https://github.com/orgs/vlang/projects/8)

---

## 🧩 Open issues (VSL)

| # | Title | Priority | Notes |
|---|-------|----------|-------|
| [#225](https://github.com/vlang/vsl/issues/225) | vsl Error on Windows | 🔴 P1 | |
| [#226](https://github.com/vlang/vsl/issues/226) | vcl: examples not working | 🟡 P2 | |
| [#91](https://github.com/vlang/vsl/issues/91) | vsl.blas not working on MacOS | 🟡 P2 | |
| [#231](https://github.com/vlang/vsl/issues/231) | `cblas_idamax` implicit decl | 🟡 Medium | |

**Closed ML epics:** #236–#239, #240–#244, #280–#285 — see [ML_ROADMAP.md](docs/ML_ROADMAP.md).

---

## 🔗 VTL ↔ VSL Integration Points

| VTL Component | VSL Backend | Status |
|--------------|-------------|--------|
| `vtl.la.matmul` | `vsl.la` / CUDA GEMM | ✅ Done |
| `vtl.nn` Conv2D forward | `vsl.cuda` cuDNN | ✅ Done (#90) |
| `vtl.nn` Linear forward | CUDA + `DeviceSession` | ✅ Done (#89, #91 P1) |
| `vtl.autograd` | CPU backward (GPU fwd) | 🟡 Phase 2–4 in VTL |
| `vtl.nn.optimizers` | CPU | ✅ Done |
| Vulkan smoke | `vsl.vulkan` gemm/conv2d | 🟡 Example only |

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
Phase A (Vulkan)       ✅ Done  — gemm, gemv, elementwise, conv2d (#284)
Phase B–C (CUDA)       ✅ Done  — cuBLAS/cuDNN (#280)
Phase D (Multi-GPU)    🔴 TODO  — Phase H in this doc
Phase E (Memory)       🔴 TODO  — Phase I in this doc
Phase F (Validation)   ✅ Core   — numerical_validation_test (#281); extend sizes
Phase G (Benchmarks)   ✅ Done  — vs_numpy + CI + PR comments (#282)
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
│       ├── gemv.v        # Matrix-vector multiply
│       └── conv2d.v      # im2col + GEMM
├── vcl/
│   └── compute/          # OpenCL backend
└── benchmarks/
    ├── blas_bench.v      # Pure V BLAS benchmarks
    ├── lapack_bench.v    # LAPACK benchmarks
    ├── compare_backends.v
    └── vs_numpy/         # matmul, gemv, conv2d + numpy_baseline.py
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

*Last updated: 2026-05-31* · Board: [project #8](https://github.com/orgs/vlang/projects/8)

*See also: [VTL ROADMAP.md](https://github.com/vlang/vtl/blob/main/ROADMAP.md)*