# The V Basic Linear Algebra System

This package implements Basic Linear Algebra System (BLAS) routines in V.

| Backend  | Description                                                                                                                                                        | Status | Compilation Flags   |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------ | ------------------- |
| BLAS     | Pure V implementation - **High performance, zero dependencies**                                                                                                     | Stable | `NONE`              |
| OpenBLAS | OpenBLAS is an optimized BLAS library based on <https://github.com/xianyi/OpenBLAS>. Check the section [OpenBLAS Backend](#openblas-backend) for more information. | Stable | `-d vsl_blas_cblas` |

## 🎉 Pure V Implementation

The pure V BLAS implementation is **stable and production-ready**, offering:

- ✅ **Zero Dependencies**: No external C libraries required
- ✅ **High Performance**: Competitive performance with C backends
- ✅ **Cross-Platform**: Works on all platforms supported by V
- ✅ **Complete Coverage**: All essential BLAS Level 1, 2, and 3 operations

### Performance

The pure V implementation delivers excellent performance across a wide range of
problem sizes. Benchmark results demonstrate competitive performance with
optimized C backends while maintaining zero-dependency operation.

Run benchmarks to see performance characteristics:

```sh
v run benchmarks/blas_bench.v
```

### Available Functions

**Level 1 BLAS**:
- `ddot` - Dot product
- `dnrm2` - Euclidean norm
- `dasum` - Sum of absolute values
- `daxpy` - Vector addition (y = alpha*x + y)
- `dscal` - Vector scaling (x = alpha*x)
- `dcopy` - Vector copy
- `dswap` - Vector swap
- `idamax` - Index of maximum absolute value

**Level 2 BLAS**:
- `dgemv` - General matrix-vector multiply
- `dger` - Rank-1 update
- `dsymv` - Symmetric matrix-vector multiply
- `dsyr` - Symmetric rank-1 update
- `dtrmv` - Triangular matrix-vector multiply
- `dtrsv` - Triangular solve

**Level 3 BLAS**:
- `dgemm` - General matrix-matrix multiply
- `dsymm` - Symmetric matrix-matrix multiply
- `dsyrk` - Symmetric rank-k update
- `dsyr2k` - Symmetric rank-2k update
- `dtrmm` - Triangular matrix-matrix multiply
- `dtrsm` - Triangular solve with multiple RHS

Therefore, its routines are a little more _lower level_ than the ones in the package `vsl.la`.

## OpenBLAS Backend

We provide a backend for the OpenBLAS library. This backend is probably
the fastest one for all platforms
but it requires the installation of the OpenBLAS library.

Use the compilation flag `-d vsl_blas_cblas` to use the OpenBLAS backend
instead of the pure V implementation
and make sure that the OpenBLAS library is installed in your system.

Check the section below for more information about installing the OpenBLAS library.

<details>
<summary>Install dependencies</summary>

### Homebrew (macOS)

```sh
brew install openblas
```

### Debian/Ubuntu GNU Linux

`libopenblas-dev` is not needed when using the pure V backend.

```sh
sudo apt-get install -y --no-install-recommends \
    gcc \
    gfortran \
    libopenblas-dev
```

### Arch Linux/Manjaro GNU Linux

The best way of installing OpenBLAS is using
[blas-openblas](https://archlinux.org/packages/extra/x86_64/blas-openblas/).

```sh
sudo pacman -S blas-openblas
```

</details>
