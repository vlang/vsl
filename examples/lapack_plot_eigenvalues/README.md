# LAPACK Eigenvalue Visualization

This example demonstrates solving eigenvalue problems using LAPACK and
visualizing the results with plotting.

## What You'll Learn

- Using LAPACK for eigenvalue decomposition
- Visualizing eigenvalues
- Understanding eigenvalue problems
- Combining LAPACK with plotting

## Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- Optional: LAPACK backend for actual computation (`-d vsl_lapack_lapacke`)

## Running the Example

```sh
# Navigate to this directory
cd examples/lapack_plot_eigenvalues

# Run with pure V (demonstration)
v run main.v

# Run with LAPACK backend (if available)
v -d vsl_lapack_lapacke run main.v
```

## Expected Output

The example generates:

- **Console output**: Matrix, eigenvalues, and computation status
- **Bar Chart**: Visual representation of eigenvalue magnitudes
- **Scatter Plot**: Eigenvalue distribution on number line

## Code Walkthrough

### 1. Matrix Setup

```v
n := 3
// Create symmetric matrix
a := []f64{len: n * n, init: 0.0}
// Fill matrix in column-major order for LAPACK
```

We create a symmetric matrix suitable for eigenvalue decomposition.

### 2. Eigenvalue Computation

```v
// Compute eigenvalues and eigenvectors
// lapack64.dsyev('V', 'U', n, mut eigenvectors, mut eigenvalues)
```

For symmetric matrices, we use `dsyev` to compute eigenvalues and eigenvectors.

### 3. Visualization

We create two plots:
- Bar chart showing eigenvalue magnitudes
- Scatter plot showing eigenvalue positions

## Mathematical Background

### Eigenvalue Problem

For matrix **A**, find **λ** and **v** such that:

**Av = λv**

Where:
- **λ** is an eigenvalue (scalar)
- **v** is an eigenvector (vector)

### Symmetric Matrices

For symmetric matrices:
- All eigenvalues are real
- Eigenvectors are orthogonal
- Matrix can be decomposed as **A = QΛQᵀ**

## Use Cases

- **Principal Component Analysis**: Find principal directions
- **Vibration Analysis**: Natural frequencies
- **Quantum Mechanics**: Energy levels
- **Data Analysis**: Dimensionality reduction

## Experiment Ideas

Try modifying the example to:

- **Different matrices**: Try larger matrices or different structures
- **Visualize eigenvectors**: Plot eigenvectors as vectors
- **Eigenvalue spectrum**: Analyze eigenvalue distribution
- **Compare methods**: Compare different eigenvalue algorithms

## Related Examples

- `lapack_eigenvalue_problems` - More eigenvalue examples
- `lapack_linear_systems` - Solving linear systems
- `plot_bar` - Bar chart basics

## Related Tutorials

- [LAPACK Solvers](../../docs/linear-algebra/02-lapack-solvers.md)
- [Eigenvalue Problems](../../docs/linear-algebra/03-eigenvalue-problems.md)
- [2D Plotting](../../docs/visualization/01-2d-plotting.md)

## Troubleshooting

**LAPACK not found**: Install LAPACK or use pure V backend

**Plot doesn't open**: Ensure web browser is installed

**Wrong eigenvalues**: Verify matrix is symmetric and correctly formatted

---

Explore more LAPACK and plotting examples in the [examples directory](../).

