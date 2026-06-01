# VSL Performance Benchmarks

This directory contains comprehensive performance benchmarks for VSL's pure V BLAS
and LAPACK implementations.

## Overview

The benchmark suite demonstrates the performance characteristics of VSL's pure V
implementations compared to C backends (OpenBLAS/LAPACKE). All benchmarks use V's
built-in `benchmark` module for accurate timing measurements.

## Running Benchmarks

Run benchmarks from the VSL repository root. Benchmark commands are intentionally
not part of the default test suite; they can be CPU/GPU and hardware sensitive.

### vs NumPy (ML ops)

```sh
v run benchmarks/vs_numpy/matmul_bench.v
v run benchmarks/vs_numpy/gemv_bench.v
v run benchmarks/vs_numpy/conv2d_bench.v
```

See [vs_numpy/README.md](vs_numpy/README.md). Tracked in [#282](https://github.com/vlang/vsl/issues/282).

### GPU smoke benchmarks

CUDA and Vulkan benchmark coverage is evolving. For release evidence, prefer
small scoped GPU smokes before running any heavy benchmark:

```sh
VSL_TEST_VULKAN=1 VJOBS=1 v -prod -d vulkan test vsl/vulkan/compute/adam_step_vulkan_test.v
v -d cuda test vsl/cuda/examples/cuda_ops_test.v
```

If you run from `~/.vmodules`, prefix benchmark paths with `vsl/`.

### Run All Benchmarks

```sh
# Run BLAS benchmarks
v run benchmarks/blas_bench.v

# Run LAPACK benchmarks
v run benchmarks/lapack_bench.v

# Compare backends
v run benchmarks/compare_backends.v
```

### Run Specific Benchmarks

```sh
# Run with specific problem sizes
v run benchmarks/blas_bench.v --sizes 100,500,1000

# Run with C backend enabled
v -d vsl_blas_cblas run benchmarks/blas_bench.v
```

## Benchmark Structure

- **`blas_bench.v`**: Comprehensive BLAS Level 1, 2, and 3 benchmarks
- **`lapack_bench.v`**: LAPACK operation benchmarks (linear systems, factorizations, etc.)
- **`compare_backends.v`**: Direct comparison between pure V and C backends
- **`benchmark_utils.v`**: Shared utilities for benchmark setup and reporting

## Understanding Results

Benchmark results show:
- **Operation**: The BLAS/LAPACK function being benchmarked
- **Size**: Problem size (vector length, matrix dimensions)
- **Time**: Average execution time over multiple runs
- **Throughput**: Operations per second (where applicable)
- **GFLOPS**: Floating-point operations per second (for compute-intensive operations)

Example report shape:

| Operation | Size | Backend | Time | GFLOPS / ratio |
|-----------|------|---------|------|----------------|
| GEMM | 512 | pure V / C BLAS / NumPy | ms | backend-specific |
| Conv2D | `1x1x32x32`, `3x3` | VSL / NumPy reference | ms | ratio |

Do not compare numbers across machines without recording CPU/GPU model,
compiler flags, and backend flags.

## Performance Notes

- Benchmarks are run multiple times and averaged for accuracy
- Warm-up runs are performed before timing to account for cache effects
- Results may vary based on hardware, compiler optimizations, and system load
- Pure V backend performance is competitive with C backends for most operations

## Contributing

When adding new benchmarks:

1. Follow the existing benchmark structure
2. Use the `benchmark` module from V's standard library
3. Include multiple problem sizes
4. Document any special considerations
5. Ensure benchmarks are reproducible

