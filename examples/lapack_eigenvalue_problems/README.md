# Example - lapack_eigenvalue_problems 🔬

This example demonstrates eigenvalue decomposition using LAPACK:

- **dsyev**: Symmetric eigenvalue decomposition (computes eigenvalues and eigenvectors)

## Instructions

1. Ensure you have the V compiler installed. You can download it from [here](https://vlang.io).
2. Ensure you have the VSL installed. You can do it following the [installation guide](https://github.com/vlang/vsl?tab=readme-ov-file#-installation)!
3. Navigate to this directory.
4. Run the example using the following command:

```sh
v run main.v
```

## What This Example Shows

### Symmetric Eigenvalue Decomposition (dsyev)

Computes eigenvalues and eigenvectors of a symmetric matrix A:

- **Eigenvalues**: Scalar values λ such that A*v = λ*v
- **Eigenvectors**: Vectors v corresponding to each eigenvalue

The example:
1. Computes eigenvalues and eigenvectors
2. Verifies the decomposition by checking A*v ≈ λ*v
3. Shows the relationship between eigenvalues, eigenvectors, and the original matrix

## Applications

Eigenvalue decomposition is fundamental in many areas:

- **Principal Component Analysis (PCA)**: Find principal directions in data
- **Vibration Analysis**: Natural frequencies and modes
- **Quantum Mechanics**: Energy levels and states
- **Graph Theory**: Spectral properties of graphs
- **Data Compression**: Dimensionality reduction

## Memory Layout

**Important**: Pure V LAPACK uses **column-major** storage.

This example includes helper functions for conversion:
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
- Eigenvalue decomposition is computationally intensive (O(n³))
- For very large matrices, C backend may offer better performance

## See Also

- [LAPACK Module Documentation](../../lapack/README.md)
- [LAPACK Performance Benchmarks](../../benchmarks/README.md)
- [Pure V BLAS/LAPACK Release Notes](../../RELEASE_NOTES_PURE_V.md)

Enjoy exploring eigenvalue problems! 🔬

