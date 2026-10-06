# The V Basic Linear Algebra System

This package implements Basic Linear Algebra System (BLAS) routines in V.

| Backend  | Description                                                                                                                                                        | Status | Compilation Flags   |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------ | ------------------- |
| BLAS     | Pure V implementation - **portable, zero-dependency fallback**                                                                                                     | Stable | `NONE`              |
| OpenBLAS | OpenBLAS is an optimized BLAS library based on <https://github.com/xianyi/OpenBLAS>. Check the section [OpenBLAS Backend](#openblas-backend) for more information. | Stable | `-d vsl_blas_cblas` |
| System CBLAS GEMM | Uses the host's CBLAS implementation for dense f32/f64 matrix multiplication; other BLAS calls use pure V | Linux | `-d vsl_blas_generic_cblas` |

## Pure V implementation

The pure V backend provides a zero-dependency, cross-platform implementation
of BLAS Level 1, 2, and 3. It is the portable fallback; its dense matrix
multiplication is not expected to match tuned OpenBLAS or other optimized C
BLAS libraries. Use the CBLAS backend for performance-sensitive GEMM workloads.

For pure V GEMM, the number of concurrent workers follows `runtime.nr_jobs()`;
the `VJOBS` environment variable can cap it for constrained systems. Each
worker reuses its goroutine for multiple output tiles.

Run the scoped benchmarks to measure the backend on your machine:

```sh
v run ./vsl/benchmarks/blas_bench.v
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
- `sgemm` - Single-precision general matrix-matrix multiply
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
