# The V Linear Algebra Package

This package implements Linear Algebra routines in V.

| Backend | Description | Status | Compilation flag |
| --- | --- | --- | --- |
| LAPACK | Pure V implementation; high performance and dependency-free. | Stable | None |
| LAPACKE | C interface to the standard LAPACK distribution. See [LAPACKE backend](#lapacke-backend). | Stable | `-d vsl_lapack_lapacke` |

## 🎉 Pure V Implementation

The pure V LAPACK implementation is **stable and production-ready**, offering:

- ✅ **Zero Dependencies**: No external C libraries required
- ✅ **High Performance**: Efficient algorithms with optimized BLAS calls
- ✅ **Numerically Stable**: Proper pivoting and scaling for accuracy
- ✅ **Comprehensive**: Essential linear algebra operations

### Performance

The pure V implementation delivers excellent performance while maintaining
numerical stability. Benchmark results demonstrate competitive performance with
C backends.

Run the benchmark from `~/.vmodules`, compile it first, then execute the binary
in a separate memory-limited scope. `-march=native` is machine-specific.

```sh
systemd-run --user --scope -p MemoryMax=4G -p MemorySwapMax=0 -- env VJOBS=2 \
	v -no-parallel -cc gcc -prod -cflags "-march=native" -o /tmp/vsl-lapack-bench \
	./vsl/benchmarks/lapack_bench.v
systemd-run --user --scope -p MemoryMax=1G -p MemorySwapMax=0 -- env VJOBS=2 \
	/tmp/vsl-lapack-bench
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

The `-d vsl_lapack_lapacke` build tag selects LAPACKE for supported routines.
This backend is probably the fastest one for all platforms, but it requires
the LAPACKE library to be installed.

On Linux, the default build uses the pure-V `lapack64` implementation for
`dlange`; it does not require LAPACKE.

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
