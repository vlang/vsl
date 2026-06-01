# VSL vs NumPy baselines

Run from `~/.vmodules`:

```bash
v run vsl/benchmarks/vs_numpy/matmul_bench.v
v run vsl/benchmarks/vs_numpy/gemv_bench.v
v run vsl/benchmarks/vs_numpy/conv2d_bench.v
```

With OpenBLAS (recommended):

```bash
v -d vsl_blas_cblas run vsl/benchmarks/vs_numpy/matmul_bench.v
```

## NumPy reference (`numpy_baseline.py`)

```bash
python3 vsl/benchmarks/vs_numpy/numpy_baseline.py matmul
python3 vsl/benchmarks/vs_numpy/numpy_baseline.py gemv
python3 vsl/benchmarks/vs_numpy/numpy_baseline.py conv2d
```

Compare GFLOPS / ms from the V scripts with the Python output for the same sizes.

## Output and reporting

Use the same host, flags, and matrix sizes for both VSL and NumPy. A useful
release note includes:

| Field | Example |
|-------|---------|
| CPU/GPU | `Ryzen 9`, `RTX 4060 Laptop` |
| V flags | `-d vsl_blas_cblas`, `-d cuda`, `-d vulkan` |
| Operation | `matmul`, `gemv`, `conv2d` |
| Size | `512`, `1024`, or Conv2D shape |
| Result | `ms`, `GFLOPS`, ratio vs baseline |

CUDA/Vulkan benchmark variants should be treated as opt-in until dedicated CI
coverage is added. Prefer scoped smoke tests for PR validation.

## Priority sizes

| Op | Shape |
|----|-------|
| GEMM | 128, 256, 512, 1024 |
| GEMV | square `m=n` same sizes |
| Conv2D | `1×1×32×32`, kernel `3×3`, stride 1 |

Tracked in [issue #282](https://github.com/vlang/vsl/issues/282).
