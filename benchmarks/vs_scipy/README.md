# VSL vs SciPy LAPACK

This paired benchmark compares VSL's double-precision LAPACK routines with
SciPy's wrappers for the same LAPACK operations: `dgesv`, `dgetrf`, `dpotrf`,
`dgeqrf`, and eigenvalue-only `dsyev`. Both programs use identical deterministic
matrices and right-hand sides, perform two warmups and five timed calls, include
the input copy in each timed call, and report the median and an output checksum.

The 256×256 Cholesky case also exercises VSL's blocked factorization path.
`dgeqrf` checksums can differ slightly because the implementations use
different floating-point operation order; performance numbers alone do not
establish numerical accuracy.

The `dsyev` comparison requests eigenvalues only (`jobz='N'`) on both sides.
VSL's pure-V eigenvector path (`jobz='V'`) currently returns inaccurate vectors
for the dense 64×64 input and is excluded until that defect is fixed; this
benchmark does not imply eigenvector parity.

Run every command from `~/.vmodules`. Build V once with production optimization,
then run the resulting executable separately so compilation is outside the
timed workload:

```bash
cd ~/.vmodules
systemd-run --user --scope -p MemoryMax=2G -p MemorySwapMax=0 -- env VJOBS=2 \
	v -no-parallel -cc gcc -prod -cflags "-march=native" \
	-o /tmp/vsl-scipy-lapack ./vsl/benchmarks/vs_scipy/lapack_bench.v
systemd-run --user --scope -p MemoryMax=1G -p MemorySwapMax=0 -- env VJOBS=2 \
	/tmp/vsl-scipy-lapack
systemd-run --user --scope -p MemoryMax=2G -p MemorySwapMax=0 -- env VJOBS=2 \
	OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 uv run --no-project --with scipy python \
	./vsl/benchmarks/vs_scipy/scipy_lapack_baseline.py
```

The V program selects the configured VSL backend at build time. The default is
pure V. To compare an installed LAPACKE backend, build a second executable
with `-d vsl_lapack_lapacke` and report its active linked library. The Python
baseline uses SciPy's low-level LAPACK wrappers, with `overwrite_a` and
Fortran-order arrays where required to avoid extra copies. Record
`python -c "import scipy; scipy.show_config()"` output alongside results to
identify the BLAS/LAPACK provider; use the same thread count for SciPy and any
threaded VSL backend. See
the [SciPy low-level LAPACK reference](https://docs.scipy.org/doc/scipy/reference/linalg.lapack.html).

These results compare only the listed f64 LAPACK operations and matrix sizes.
They do not compare VSL's full scientific or machine-learning feature set.

## BLAS Level 1 AXPY

The paired `daxpy` benchmark compares VSL's production-optimized pure-V or
OpenBLAS path with SciPy's low-level BLAS wrapper. Both use the same deterministic
f64 vectors, one BLAS thread, preallocated output buffers, three warmups, 31 timed
calls, and a checksum plus maximum-error check. The timed region includes only
the AXPY call; resetting the output buffer happens outside it. VSL reports its
selected backend, and SciPy reports its BLAS provider; record both with results.
The OpenBLAS build requires the OpenBLAS development library and headers to be
installed on the system. Skip that build when they are unavailable; do not
present the pure-V measurement as VSL's best available backend in that case.

Build the V benchmark with production optimization, then execute it separately.
Run all V commands from `~/.vmodules`:

```bash
cd ~/.vmodules
systemd-run --user --scope -p MemoryMax=2G -p MemorySwapMax=0 -- env VJOBS=2 \
	v -no-parallel -cc gcc -prod -cflags "-march=native" \
	-o /tmp/vsl-scipy-axpy ./vsl/benchmarks/vs_scipy/axpy_bench.v
systemd-run --user --scope -p MemoryMax=1G -p MemorySwapMax=0 -- env VJOBS=2 \
	/tmp/vsl-scipy-axpy
systemd-run --user --scope -p MemoryMax=2G -p MemorySwapMax=0 -- env VJOBS=2 \
	v -no-parallel -cc gcc -d vsl_blas_cblas -prod -cflags "-march=native" \
	-o /tmp/vsl-scipy-axpy-openblas ./vsl/benchmarks/vs_scipy/axpy_bench.v
systemd-run --user --scope -p MemoryMax=1G -p MemorySwapMax=0 -- env VJOBS=2 \
	OPENBLAS_NUM_THREADS=1 /tmp/vsl-scipy-axpy-openblas
systemd-run --user --scope -p MemoryMax=2G -p MemorySwapMax=0 -- env VJOBS=2 \
	OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 uv run --no-project --with scipy python \
	./vsl/benchmarks/vs_scipy/scipy_axpy_baseline.py
```

These timings cover one contiguous vector length and backend configuration;
they are evidence for that BLAS operation only, not a library-wide ranking.
