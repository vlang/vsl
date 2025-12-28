# Example - lapack_linear_systems 🔢

This example demonstrates solving linear systems using LAPACK routines:

- **dgesv**: Solve general linear system Ax = b
- **dgetrf**: LU factorization
- **dpotrf**: Cholesky factorization (for positive definite matrices)

## Instructions

1. Ensure you have the V compiler installed. You can download it from [here](https://vlang.io).
2. Ensure you have the VSL installed. You can do it following the [installation guide](https://github.com/vlang/vsl?tab=readme-ov-file#-installation)!
3. Navigate to this directory.
4. Run the example using the following command:

```sh
v run main.v
```

## What This Example Shows

### Example 1: General Linear System (dgesv)
Solves a 3x3 linear system using LU factorization with partial pivoting. The routine:
- Factors the matrix A into P*L*U
- Solves the system using forward/backward substitution
- Returns the solution vector x

### Example 2: LU Factorization (dgetrf)
Performs LU factorization of a matrix:
- Factors A = P*L*U where P is a permutation matrix
- Stores L and U in place
- Returns pivot indices

### Example 3: Cholesky Factorization (dpotrf)
Performs Cholesky factorization for positive definite matrices:
- Factors A = L*L^T where L is lower triangular
- More efficient than LU for symmetric positive definite matrices

## Memory Layout

**Important**: Pure V LAPACK uses **column-major** storage (like FORTRAN/BLAS standard).

This example includes helper functions:
- `row_to_col_major()`: Convert V's row-major arrays to column-major
- `col_to_row_major()`: Convert column-major back to row-major for display

## Backend Options

This example uses the **pure V LAPACK backend** by default (zero dependencies).

To use the LAPACKE C backend:

```sh
v -d vsl_lapack_lapacke run main.v
```

## Performance Notes

- Pure V backend provides excellent performance with zero dependencies
- C backend (`-d vsl_lapack_lapacke`) may offer slightly better performance for very large problems
- For most use cases, pure V backend is recommended for simplicity

## See Also

- [LAPACK Module Documentation](../../lapack/README.md)
- [LAPACK Performance Benchmarks](../../benchmarks/README.md)
- [Pure V BLAS/LAPACK Release Notes](../../RELEASE_NOTES_PURE_V.md)

Enjoy exploring LAPACK linear system solvers! 🔢

