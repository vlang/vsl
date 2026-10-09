# The V Basic Linear Algebra System

This package implements Basic Linear Algebra System (BLAS) routines in V.

| Backend | Description | Status | Compilation flag |
| --- | --- | --- | --- |
| BLAS | Pure V implementation; portable and dependency-free. | Stable | None |
| OpenBLAS | Optimized BLAS library. See [OpenBLAS backend](#openblas-backend). | Stable | `-d vsl_blas_cblas` |
| System CBLAS | Host CBLAS for dense f32/f64 GEMM and GEMV; other BLAS calls use pure V. | Linux | `-d vsl_blas_generic_cblas` |

## Pure V implementation

The pure V backend provides a zero-dependency, cross-platform implementation
of BLAS Level 1, 2, and 3. It is the portable fallback; its dense matrix
multiplication is not expected to match tuned OpenBLAS or other optimized C
BLAS libraries. Use the CBLAS backend for performance-sensitive GEMM workloads.

For pure V GEMM, concurrency follows `runtime.nr_jobs()`; `VJOBS` caps the
worker count on constrained systems. f64 GEMM distributes output tiles among
workers. The row-major, no-transpose f32 SGEMM path uses V SIMD vectors and
distributes larger row blocks among workers; small products stay serial to
avoid worker startup overhead. Other f32 transpose layouts use the portable
scalar path.

Run the benchmark from `~/.vmodules`. Compile it first, then execute the
binary in a separate memory-limited scope. `-march=native` is for measurements
on this machine and creates a non-portable binary.

```sh
systemd-run --user --scope -p MemoryMax=4G -p MemorySwapMax=0 -- env VJOBS=2 \
	v -no-parallel -cc gcc -prod -cflags "-march=native" -o /tmp/vsl-blas-bench \
	./vsl/benchmarks/blas_bench.v
systemd-run --user --scope -p MemoryMax=1G -p MemorySwapMax=0 -- env VJOBS=2 \
	/tmp/vsl-blas-bench
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
- `sgemv` - Single-precision general matrix-vector multiply
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

The `sgemv` and `dgemv` routines accept row-major matrices and support
`.no_trans`, `.trans`, `.conj_trans`, and `.conj_no_trans`. The generic system
CBLAS build uses CBLAS GEMM and GEMV for positive vector increments; unsupported
cases use the pure V implementation.

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
