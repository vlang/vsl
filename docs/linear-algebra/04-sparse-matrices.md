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
multiplication, conjugate-gradient solving, and format conversion are available;
broader sparse arithmetic and preconditioners beyond Jacobi are not implied by
these storage types.

See [`examples/la_csr_matvec`](../../examples/la_csr_matvec/main.v), or run it
with `v run examples/la_csr_matvec/main.v`.

The CSR conjugate-gradient solver assumes a symmetric positive-definite matrix,
uses a zero initial guess, and reports the true residual norm. A result can
indicate that the iteration limit was reached; encountered non-positive
curvature returns an error. See
[`examples/la_sparse_cg`](../../examples/la_sparse_cg/main.v) for a runnable
example. `preconditioned_conjugate_gradient` uses a Jacobi preconditioner and
requires every diagonal entry to be finite and positive.

## When to Use Sparse

- Matrix is >90% zeros
- Large matrices (>1000x1000)
- Memory is limited
- Many zero operations can be skipped

## Next Steps

- [Examples](../../examples/) - Find sparse matrix examples
- [Advanced Topics](../advanced/) - More advanced techniques

