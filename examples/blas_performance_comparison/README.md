# Example - blas_performance_comparison 📊

This example demonstrates performance benchmarking of BLAS operations using
V's built-in `benchmark` module.

## Instructions

1. Ensure you have the V compiler installed. You can download it from [here](https://vlang.io).
2. Ensure you have the VSL installed. You can do it following the [installation guide](https://github.com/vlang/vsl?tab=readme-ov-file#-installation)!
3. Navigate to this directory.
4. Run the example using the following command:

```sh
# Pure V backend (default)
v run main.v

# Compare with C backend
v -d vsl_blas_cblas run main.v
```

## What This Example Shows

This example benchmarks BLAS operations at different levels:

- **Level 1**: `ddot` - Dot product
- **Level 2**: `dgemv` - Matrix-vector multiplication (with GFLOPS)
- **Level 3**: `dgemm` - Matrix-matrix multiplication (with GFLOPS)

Results show execution time and throughput (GFLOPS) for different problem sizes.

## Performance Comparison

To compare pure V backend with C backend:

1. Run with pure V backend:
   ```sh
   v run main.v
   ```

2. Run with C backend:
   ```sh
   v -d vsl_blas_cblas run main.v
   ```

Compare the results to see performance differences.

## Understanding Results

- **Time**: Average execution time over multiple runs
- **GFLOPS**: Giga Floating-Point Operations Per Second
  - Higher GFLOPS = better performance
  - Level 3 operations (GEMM) typically achieve highest GFLOPS

## Performance Notes

- Pure V backend provides competitive performance
- C backend may offer 10-20% better performance for very large problems
- Pure V backend eliminates dependency management overhead
- Results vary based on:
  - Hardware (CPU architecture, cache size)
  - Compiler optimizations
  - System load

## See Also

- [BLAS Module Documentation](../../blas/README.md)
- [Comprehensive Benchmarks](../../benchmarks/README.md)
- [Pure V BLAS/LAPACK Release Notes](../../RELEASE_NOTES_PURE_V.md)

Enjoy benchmarking! 📈

