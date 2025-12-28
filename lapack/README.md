# The V Linear Algebra Package

This package implements Linear Algebra routines in V.

| Backend                                                                     | Description                                                                           | Status                  | Compilation Flags |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- | ----------------------- | ----------------- |
| LAPACK                                                                      | Pure V implementation - **High performance, zero dependencies**                       | Stable                  | `NONE`            |
| LAPACKE                                                                     | LAPACKE is a C interface to LAPACK. It is a standard part of the LAPACK distribution. |
| Check the section [LAPACKE Backend](#lapacke-backend) for more information. | Stable                                                                                | `-d vsl_lapack_lapacke` |

## 🎉 Pure V Implementation

The pure V LAPACK implementation is **stable and production-ready**, offering:

- ✅ **Zero Dependencies**: No external C libraries required
- ✅ **High Performance**: Efficient algorithms with optimized BLAS calls
- ✅ **Numerically Stable**: Proper pivoting and scaling for accuracy
- ✅ **Comprehensive**: Essential linear algebra operations

### Performance

The pure V implementation delivers excellent performance while maintaining numerical stability. Benchmark results demonstrate competitive performance with C backends.

Run benchmarks to see performance characteristics:

```sh
v run benchmarks/lapack_bench.v
```

### Available Functions

**Linear System Solvers**:
- `dgesv` - Solve general linear system
- `dgetrf` - LU factorization
- `dgetrs` - Solve using LU factorization
- `dgetri` - Matrix inversion using LU
- `dpotrf` - Cholesky factorization
- `dpotrs` - Solve using Cholesky
- `dpotri` - Inversion using Cholesky

**Matrix Factorizations**:
- `dgeqrf` - QR factorization
- `dorgqr` - Generate Q matrix from QR
- `dgeqr2` - Unblocked QR factorization

**Eigenvalue Problems**:
- `dsyev` - Symmetric eigenvalue decomposition
- `dgeev` - General eigenvalue decomposition
- `dsytrd` - Tridiagonal reduction for symmetric matrices

**Singular Value Decomposition**:
- `dgesvd` - General SVD

**Matrix Utilities**:
- `dgebal` - Matrix balancing
- `dgehrd` - Hessenberg reduction
- `dlange` - Matrix norms
- `dlacpy` - Matrix copy

Therefore, its routines are a little more _lower level_ than the ones in the package `vsl.la`.

## LAPACKE Backend

We provide a backend for the LAPACKE library. This backend is probably
the fastest one for all platforms
but it requires the installation of the LAPACKE library.

Use the compilation flag `-d vsl_lapack_lapacke` to use the LAPACKE backend
instead of the pure V implementation
and make sure that the LAPACKE library is installed in your system.

Check the section below for more information about installing the LAPACKE library.

<details>
<summary>Install dependencies</summary>

### Homebrew (macOS)

```sh
brew install lapack
```

### Debian/Ubuntu GNU Linux

```sh
sudo apt-get install -y --no-install-recommends \
    gcc \
    gfortran \
    liblapacke-dev
```

### Arch Linux/Manjaro GNU Linux

The best way of installing OpenBLAS is using
[blas-openblas](https://archlinux.org/packages/extra/x86_64/blas-openblas/).

```sh
sudo pacman -S blas-openblas
```

</details>
