# Basic Linear Algebra

Learn how to perform matrix and vector operations with VSL's linear algebra modules.

## What You'll Learn

- Creating matrices and vectors
- Basic matrix operations
- Vector operations
- Using BLAS for high-performance operations

## Prerequisites

- VSL installed
- Basic understanding of linear algebra concepts
- [Your First Plot](02-first-plot.md) tutorial completed

## Theory

VSL provides comprehensive linear algebra support through:
- **BLAS**: Basic Linear Algebra Subroutines (Level 1, 2, 3)
- **LAPACK**: Advanced linear algebra routines
- **Pure V implementations**: Zero-dependency operations

## Creating Matrices

### Using the `la` Module

```v
import vsl.la

fn main() {
	// Create a 3x3 matrix
	mut a := la.Matrix.new[f64](3, 3)

	// Set values
	a.set(0, 0, 1.0)
	a.set(0, 1, 2.0)
	a.set(0, 2, 3.0)
	a.set(1, 0, 4.0)
	a.set(1, 1, 5.0)
	a.set(1, 2, 6.0)
	a.set(2, 0, 7.0)
	a.set(2, 1, 8.0)
	a.set(2, 2, 9.0)

	println(a)
}
```

### Using BLAS Directly

```v ignore
import vsl.blas
import vsl.blas.blas64

fn main() {
    // Create vectors
    x := [1.0, 2.0, 3.0]
    y := [4.0, 5.0, 6.0]
    
    // Note: BLAS functions require specific parameters - check API documentation
    // Dot product: blas64.ddot(n, x, incx, y, incy)
    // Vector norm: blas64.dnrm2(n, x, incx)
    println('BLAS operations example')
}
```

## Vector Operations

### Dot Product

```v ignore
import vsl.blas.blas64

fn main() {
    x := [1.0, 2.0, 3.0]
    y := [4.0, 5.0, 6.0]
    
    // Note: BLAS ddot requires: blas64.ddot(n, x, incx, y, incy)
    // result := blas64.ddot(x.len, x, 1, y, 1)
    println('Dot product example')
}
```

### Vector Norm

```v ignore
import vsl.blas.blas64

fn main() {
    x := [3.0, 4.0]
    
    // Note: BLAS dnrm2 requires: blas64.dnrm2(n, x, incx)
    // norm := blas64.dnrm2(x.len, x, 1)
    println('Norm example')
}
```

### Vector Scaling

```v ignore
import vsl.blas.blas64

fn main() {
    mut x := [1.0, 2.0, 3.0]
    alpha := 2.0
    
    // Note: BLAS dscal requires: blas64.dscal(n, alpha, mut x, incx)
    // blas64.dscal(x.len, alpha, mut x, 1)
    println('Scaling example')
}
```

## Matrix Operations

### Matrix-Vector Multiplication (GEMV)

```v ignore
import vsl.blas.blas64

fn main() {
    // Matrix A (3x3)
    a := [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0],
        [7.0, 8.0, 9.0],
    ]
    
    // Vector x
    x := [1.0, 2.0, 3.0]
    
    // Result vector y = Ax
    mut y := [0.0, 0.0, 0.0]
    
    // Note: BLAS dgemv requires: blas64.dgemv(trans, m, n, alpha, a, lda, x, incx, beta, mut y, incy)
    // blas64.dgemv(.n, 3, 3, 1.0, a, 3, x, 1, 0.0, mut y, 1)
    println('Matrix-vector multiplication example')
}
```

### Matrix-Matrix Multiplication (GEMM)

```v ignore
import vsl.blas.blas64

fn main() {
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
    
    // Result matrix C = AB (2x2)
    mut c := [
        [0.0, 0.0],
        [0.0, 0.0],
    ]
    
    // Note: BLAS dgemm requires: blas64.dgemm(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, mut c, ldc)
    // blas64.dgemm(.n, .n, 2, 2, 3, 1.0, a, 3, b, 2, 0.0, mut c, 2)
    println('Matrix-matrix multiplication example')
}
```

## Visualizing Results

Combine linear algebra with plotting:

```v ignore
import vsl.blas.blas64
import vsl.plot
import vsl.util

fn main() {
    // Generate matrix data
    n := 50
    x := util.arange(n).map(f64(it))
    
    // Create a matrix-vector product visualization
    a := [for _ in 0..n { [for _ in 0..n { math.sin(f64(i) * f64(j) / 10.0) }] }]
    v := [for i in 0..n { math.cos(f64(i) / 5.0) }]
    
    mut result := []f64{len: n, init: 0.0}
    // ... perform matrix-vector multiplication ...
    
    // Plot result
    mut plt := plot.Plot.new()
    plt.scatter(x: x, y: result, mode: 'lines')
    plt.layout(title: 'Matrix-Vector Product')
    plt.show()!
}
```

## Exercises

1. **Vector operations**: Compute dot products and norms for different vectors
2. **Matrix multiplication**: Multiply matrices of different sizes
3. **Visualization**: Plot results of matrix operations
4. **Performance**: Compare pure V vs BLAS backends

## Performance Tips

- Use BLAS backends (`-d vsl_blas_cblas`) for large matrices
- Pure V backend is fine for small to medium problems
- Matrix operations are optimized for column-major storage

## Next Steps

- [BLAS Basics](../linear-algebra/01-blas-basics.md) - Deep dive into BLAS
- [LAPACK Solvers](../linear-algebra/02-lapack-solvers.md) - Solve linear systems
- [Examples Directory](../../examples/) - More linear algebra examples

## Related Examples

- `examples/blas_basic_operations` - BLAS operations
- `examples/blas_performance_comparison` - Performance benchmarks
- `examples/lapack_linear_systems` - Solving linear systems
- `examples/lapack_eigenvalue_problems` - Eigenvalue decomposition
