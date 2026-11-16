# Sparse Matrices

Learn how to work with sparse matrices efficiently in VSL.

## What You'll Learn

- Understanding sparse matrices
- When to use sparse storage
- Sparse matrix operations
- Storage formats

## Prerequisites

- [BLAS Basics](01-blas-basics.md)
- Understanding of matrix storage

## Theory

Sparse matrices have mostly zero entries. Storing only non-zero values saves memory and computation.

## Storage Formats

VSL's `vsl.la` module currently provides three sparse representations.

### Coordinate Format (COO): `Triplet[T]`

`Triplet.new[T](rows, columns, capacity)` allocates storage for coordinate
entries. Coordinates are zero-based, and `put(row, column, value)!` reports
out-of-range indices or exhausted capacity. Repeated coordinates are allowed.

### Compressed Sparse Row (CSR): `CSRMatrix[T]`

`Triplet.to_csr()!` converts COO entries to CSR, summing duplicate coordinates
and dropping entries whose accumulated value is zero. CSR provides
`to_dense()`, `to_cc()`, `size()`, `nnz()`, and `matvec(vector)!`. `matvec`
requires a vector whose length matches the matrix's column count.

### Compressed Sparse Column (CSC): `CCMatrix[T]`

`Triplet.to_cc()` converts COO entries to column-compressed storage, with the
same duplicate-summing and zero-dropping behavior. `CCMatrix.to_csr()` converts
to CSR. Both compressed formats can be converted to dense matrices.

The current sparse API is intentionally focused: CSR matrix-vector
multiplication, triangular and iterative solving, and format conversion are
available; broader sparse arithmetic and preconditioners beyond Jacobi are not
implied by these storage types.

### Reusable sparse LU for f64 CSR

`CSRMatrix[f64].factorize_lu()!` computes a pure-V LU factorization using
partial row pivoting. The returned `SparseLU` can solve multiple right-hand
sides with `solve(b)!`; factorization is performed once and each solve applies
the recorded row permutation followed by sparse forward and backward
substitution. Neither factorization nor solve converts the matrix to dense
storage. Elimination stores fill-in in sparse row maps, and in the worst case
fill-in can make the factors dense, requiring O(n²) factor storage and O(n³)
factorization work.

This first slice is limited to square CSR matrices with `f64` values and one
right-hand side per `solve` call. It does not provide CSC input, complex or
other numeric types, multiple right-hand sides in one call, ordering
heuristics, backend dispatch, condition estimates, or iterative refinement.
The factorization returns an error for nonsquare or malformed CSR storage,
non-finite matrix entries, an exactly zero pivot (singularity), or a
non-finite intermediate. It does not classify small nonzero pivots as
singular. `solve` returns an error if the right-hand side has the wrong length,
contains non-finite values, or substitution produces a non-finite value.
See the runnable [sparse LU example](../../examples/la_sparse_lu/main.v).
Run it from the repository root with `v run examples/la_sparse_lu/main.v`.

`CSRMatrix[f64].solve_lower_triangular(b)!` and
`solve_upper_triangular(b)!` perform forward or backward substitution directly
from CSR storage. They require a square matrix, a finite right-hand side of
matching length, a finite triangular matrix, and a finite nonzero diagonal in
every row. They return an error for an entry on the wrong side of the diagonal
or if an intermediate/result becomes non-finite.

See [`examples/la_csr_matvec`](../../examples/la_csr_matvec/main.v), or run it
with `v run examples/la_csr_matvec/main.v`.

The CSR conjugate-gradient solver assumes a symmetric positive-definite matrix,
uses a zero initial guess, and reports the true residual norm. A result can
indicate that the iteration limit was reached; encountered non-positive
curvature returns an error. See
[`examples/la_sparse_cg`](../../examples/la_sparse_cg/main.v) for a runnable
example. `preconditioned_conjugate_gradient` uses a Jacobi preconditioner and
requires every diagonal entry to be finite and positive.

`gmres(b, tolerance, max_iterations, restart)` solves square systems that need
not be symmetric. It uses a zero initial guess, an absolute stopping target of
`tolerance * ||b||₂`, and restarted, unpreconditioned GMRES. Its result reports
the true residual norm; `converged` is false when the iteration limit is
reached or Arnoldi breaks down before meeting the target. A happy breakdown
with an exact solution converges; an inconsistent singular system returns a
non-converged result with its true residual. Restart length and iteration
limit must both be positive.

`preconditioned_gmres` applies a right Jacobi preconditioner to nonsymmetric
systems. Every diagonal entry must be finite and nonzero; negative diagonal
entries are allowed. It uses the same restart, tolerance, and true-residual
reporting contract as `gmres`. The runnable
[`sparse solver example`](../../examples/la_sparse_cg/main.v) demonstrates
both GMRES variants.

`bicgstab` is another solver for nonsymmetric square systems. It uses O(n)
vector workspace, a zero initial guess, and the same relative residual target
as GMRES. `preconditioned_bicgstab` applies right Jacobi using the finite,
nonzero diagonal of the matrix. Both methods report the recomputed true
residual and whether the iteration encountered a breakdown; either method may
fail to converge for some matrices even when GMRES succeeds. The sparse solver
example demonstrates both BiCGSTAB variants.

## When to Use Sparse

- Matrix is >90% zeros
- Large matrices (>1000x1000)
- Memory is limited
- Many zero operations can be skipped

## Next Steps

- [Examples](../../examples/) - Find sparse matrix examples
- [Advanced Topics](../advanced/) - More advanced techniques

