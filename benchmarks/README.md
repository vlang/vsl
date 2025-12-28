# VSL Performance Benchmarks

This directory contains comprehensive performance benchmarks for VSL's pure V BLAS and LAPACK implementations.

## Overview

The benchmark suite demonstrates the performance characteristics of VSL's pure V implementations compared to C backends (OpenBLAS/LAPACKE). All benchmarks use V's built-in `benchmark` module for accurate timing measurements.

## Running Benchmarks

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

