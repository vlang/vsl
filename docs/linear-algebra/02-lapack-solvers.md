# LAPACK Solvers

Learn how to solve linear systems using LAPACK routines in VSL.

## What You'll Learn

- Solving linear systems Ax = b
- LU decomposition
- Cholesky decomposition
- When to use each method

## Prerequisites

- [BLAS Basics](01-blas-basics.md)
- Understanding of linear systems
- Matrix operations knowledge

## Theory

LAPACK provides routines for solving **Ax = b** where:
- **A** is a matrix
- **x** is the unknown vector
- **b** is the right-hand side vector

Different methods are used based on matrix properties.

## Solving Linear Systems

### Using dgesv (General Matrix)

```v
import vsl.lapack.lapack64

// System: Ax = b
// A = [[2, 1], [1, 2]]
// b = [3, 3]
// Expected: x = [1, 1]

a := [
	[2.0, 1.0],
	[1.0, 2.0],
]

b := [3.0, 3.0]

// Solve (simplified - actual usage may vary)
// lapack64.dgesv(2, 1, mut a, mut ipiv, mut b)
```

### LU Decomposition

LU decomposition factors A = LU where:
- **L** is lower triangular
- **U** is upper triangular

Then solve Ly = b, then Ux = y.

### Cholesky Decomposition

For symmetric positive definite matrices:

A = LLᵀ

More efficient than LU for these matrices.

## Example: Solving a System

```v
import vsl.lapack.lapack64

// 3x3 system
a := [
	[4.0, 1.0, 2.0],
	[1.0, 3.0, 1.0],
	[2.0, 1.0, 5.0],
]

b := [7.0, 5.0, 8.0]

// Solve Ax = b
// (Implementation details depend on LAPACK backend)
```

## Choosing the Right Method

| Method | Matrix Type | Use When |
|--------|-------------|----------|
| dgesv | General | Most common case |
| dposv | Positive definite | Symmetric positive definite |
| dsysv | Symmetric | Symmetric matrices |

## Next Steps

- [Eigenvalue Problems](03-eigenvalue-problems.md) - Eigenvalue decomposition
- [Examples](../../examples/lapack_linear_systems/) - Working examples
