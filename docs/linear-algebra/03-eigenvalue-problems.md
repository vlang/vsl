# Eigenvalue Problems

Learn how to solve eigenvalue problems using LAPACK.

## What You'll Learn

- Understanding eigenvalues and eigenvectors
- Computing eigenvalues
- Computing eigenvectors
- Applications of eigenvalue problems

## Prerequisites

- [LAPACK Solvers](02-lapack-solvers.md)
- Understanding of matrices and linear transformations

## Theory

For matrix **A**, find **λ** and **v** such that:

**Av = λv**

Where:
- **λ** is an eigenvalue (scalar)
- **v** is an eigenvector (vector)

## Computing Eigenvalues

### Symmetric Matrices (dsyev)

```v
import vsl.lapack.lapack64

// Symmetric matrix
a := [
	[2.0, 1.0, 0.0],
	[1.0, 2.0, 1.0],
	[0.0, 1.0, 2.0],
]

// Compute eigenvalues and eigenvectors
// lapack64.dsyev('V', 'U', 3, mut a, mut eigenvalues)
```

### General Matrices

For non-symmetric matrices, use different routines that handle complex eigenvalues.

## Applications

- **Principal Component Analysis**: Find principal directions
- **Vibration Analysis**: Natural frequencies
- **Quantum Mechanics**: Energy levels
- **Data Analysis**: Dimensionality reduction

## Example

```v
// Compute eigenvalues of a matrix
// Visualize results
// Use eigenvectors for transformations
```

## Next Steps

- [Sparse Matrices](04-sparse-matrices.md) - Efficient storage
- [Examples](../../examples/lapack_eigenvalue_problems/) - Working examples
