# BLAS Basics

Learn the fundamentals of BLAS (Basic Linear Algebra Subroutines) and how to use them in VSL.

## What You'll Learn

- Understanding BLAS levels (1, 2, 3)
- Vector operations (Level 1)
- Matrix-vector operations (Level 2)
- Matrix-matrix operations (Level 3)
- Choosing the right backend

## Prerequisites

- [Basic Linear Algebra](../getting-started/03-basic-linear-algebra.md)
- Understanding of vectors and matrices
- VSL installed

## Theory

BLAS provides standardized routines for linear algebra operations:

- **Level 1**: Vector operations (dot product, norms, scaling)
- **Level 2**: Matrix-vector operations (GEMV, GER)
- **Level 3**: Matrix-matrix operations (GEMM, SYRK)

## BLAS Level 1: Vector Operations

### Dot Product

```v ignore
import vsl.blas.blas64

x := [1.0, 2.0, 3.0]
y := [4.0, 5.0, 6.0]

// Note: BLAS functions require specific parameters - check API documentation
// dot := blas64.ddot(n, x, incx, y, incy)
println('Dot product example')
```

### Vector Norm

```v ignore
import vsl.blas.blas64

x := [3.0, 4.0]
// Note: BLAS functions require specific parameters - check API documentation
// norm := blas64.dnrm2(n, x, incx)
println('Norm example')
```

### Vector Scaling

```v ignore
import vsl.blas.blas64

mut x := [1.0, 2.0, 3.0]
// Note: BLAS functions require specific parameters - check API documentation
// blas64.dscal(n, alpha, mut x, incx)
println('Scaling example')
```

## BLAS Level 2: Matrix-Vector Operations

### GEMV (General Matrix-Vector Multiply)

```v ignore
import vsl.blas.blas64

// Matrix A (3x3)
a := [
    [1.0, 2.0, 3.0],
    [4.0, 5.0, 6.0],
    [7.0, 8.0, 9.0],
]

// Vector x
x := [1.0, 2.0, 3.0]

// Result: y = αAx + βy
mut y := [0.0, 0.0, 0.0]
// Note: BLAS dgemv requires specific parameters - check API documentation
// blas64.dgemv(trans, m, n, alpha, a, lda, x, incx, beta, mut y, incy)
println('Matrix-vector multiplication example')
```

## BLAS Level 3: Matrix-Matrix Operations

### GEMM (General Matrix-Matrix Multiply)

```v ignore
import vsl.blas.blas64

// Matrix A (2x3)
a := [
    [1.0, 2.0, 3.0],
    [4.0, 5.0, 6.0],
]

// Matrix B (3x2)
b := [
    [1.0, 2.0],
    [3.0, 4.0],
    [5.0, 6.0],
]

// Result: C = αAB + βC
mut c := [
    [0.0, 0.0],
    [0.0, 0.0],
]

// Note: BLAS dgemm requires specific parameters - check API documentation
// blas64.dgemm(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, mut c, ldc)
println('Matrix-matrix multiplication example')
```

## Backend Options

### Pure V Backend (Default)

```sh
v run your_program.v
```

Zero dependencies, works everywhere.

### OpenBLAS Backend

```sh
v -d vsl_blas_cblas run your_program.v
```

Maximum performance when C libraries are available.

## Performance Tips

- Use Level 3 operations when possible (most efficient)
- Choose appropriate backend for your use case
- Consider matrix storage order (row vs column major)

## Next Steps

- [LAPACK Solvers](02-lapack-solvers.md) - Solve linear systems
- [Eigenvalue Problems](03-eigenvalue-problems.md) - Eigenvalue decomposition
- [Examples](../../examples/blas_basic_operations/) - Working examples

