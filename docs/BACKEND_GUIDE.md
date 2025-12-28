# Backend Selection Guide

This guide helps you choose the right backend for your VSL BLAS/LAPACK needs.

## Overview

VSL provides two backend options for BLAS and LAPACK:

1. **Pure V Backend** (default) - Zero dependencies, high performance
2. **C Backends** - Maximum performance when system libraries are available

## Pure V Backend

### When to Use

- ✅ **Zero-dependency deployment** - No need to install system libraries
- ✅ **Cross-platform consistency** - Same behavior everywhere
- ✅ **Easy deployment** - Single binary, no external dependencies
- ✅ **Good performance** - Competitive with C backends for most use cases
- ✅ **Development simplicity** - No library management overhead

### Compilation

```sh
# Default - no flags needed
v run your_program.v
```

### Performance Characteristics

- Excellent performance for small to medium problems
- Competitive performance for large problems
- Typically within 10-20% of C backend performance
- Zero dependency overhead

## C Backends

### When to Use

- ✅ **Maximum performance** - When every bit of speed matters
- ✅ **Very large problems** - Problems requiring maximum optimization
- ✅ **Production systems** - Where C libraries are already available
- ✅ **Research/HPC** - When using optimized vendor BLAS (Intel MKL, etc.)

### BLAS C Backend (OpenBLAS)

**Compilation**:
```sh
v -d vsl_blas_cblas run your_program.v
```

**Requirements**:
- OpenBLAS development libraries installed
- See [BLAS README](../blas/README.md) for installation instructions

### LAPACK C Backend (LAPACKE)

**Compilation**:
```sh
v -d vsl_lapack_lapacke run your_program.v
```

**Requirements**:
- LAPACKE development libraries installed
- See [LAPACK README](../lapack/README.md) for installation instructions

### Combined Backends

**Compilation**:
```sh
v -d vsl_blas_cblas -d vsl_lapack_lapacke run your_program.v
```

## Performance Comparison

### Typical Performance Differences

| Operation Type | Pure V vs C Backend | Notes |
|----------------|-------------------|-------|
| Level 1 BLAS | 95-100% | Vector operations are very efficient |
| Level 2 BLAS | 90-95% | Matrix-vector operations |
| Level 3 BLAS | 85-95% | Matrix-matrix operations (GEMM) |
| Linear Systems | 90-95% | LU/Cholesky factorization |
| Eigenvalue | 85-90% | More complex algorithms |

*Performance percentages are relative to C backend. Results vary by hardware and problem size.*

### Benchmarking

Run benchmarks to compare performance on your system:

```sh
# Pure V backend
v run benchmarks/blas_bench.v
v run benchmarks/lapack_bench.v

# C backend
v -d vsl_blas_cblas run benchmarks/compare_backends.v
```

## Decision Tree

```
Do you need zero dependencies?
├─ Yes → Use Pure V Backend (default)
└─ No → Continue...

Do you need maximum performance?
├─ Yes → Use C Backends (if libraries available)
└─ No → Use Pure V Backend (simpler)

Are C libraries already installed?
├─ Yes → Consider C Backends for performance
└─ No → Use Pure V Backend (no installation needed)
```

## Migration Guide

### From C Backend to Pure V

1. **Remove compilation flags**:
   ```sh
   # Before
   v -d vsl_blas_cblas run program.v
   
   # After (default)
   v run program.v
   ```

2. **No code changes needed** - Same API

3. **Test thoroughly** - Verify numerical results

### From Pure V to C Backend

1. **Install system libraries**:
   ```sh
   # Ubuntu/Debian
   sudo apt-get install libopenblas-dev liblapacke-dev
   
   # macOS
   brew install openblas lapack
   ```

2. **Add compilation flags**:
   ```sh
   v -d vsl_blas_cblas -d vsl_lapack_lapacke run program.v
   ```

3. **Benchmark** - Compare performance

## Best Practices

1. **Start with Pure V** - It's the default and works everywhere
2. **Benchmark if needed** - Measure performance for your specific use case
3. **Use C backends selectively** - Only when performance is critical
4. **Document your choice** - Note which backend you're using and why

## Troubleshooting

### Pure V Backend Issues

- **Performance concerns**: Run benchmarks to verify performance is acceptable
- **Numerical differences**: Both backends should produce identical results (within numerical precision)

### C Backend Issues

- **Compilation errors**: Ensure development libraries are installed
- **Runtime errors**: Check that runtime libraries are available
- **Performance not better**: Verify you're using optimized BLAS (not reference implementation)

## Summary

| Feature | Pure V Backend | C Backends |
|---------|---------------|------------|
| Dependencies | None | System libraries required |
| Performance | Excellent (85-100% of C) | Maximum |
| Deployment | Single binary | Requires libraries |
| Cross-platform | Yes | Platform-specific |
| Ease of use | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

**Recommendation**: Start with Pure V backend. Use C backends only when maximum performance is critical and libraries are available.

