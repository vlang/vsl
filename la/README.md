# Linear Algebra (la) Module

The `vsl.la` module provides comprehensive linear algebra operations for
scientific computing, including matrix operations, vector manipulations, and
numerical linear algebra algorithms.

## 🚀 Features

### Matrix Operations

- **Basic Operations**: Addition, subtraction, multiplication, transposition
- **Advanced Operations**: Decompositions (LU, QR, SVD), eigenvalue analysis
- **Sparse Matrices**: Efficient storage and operations for sparse data
- **BLAS Integration**: Optional high-performance BLAS backend

### Vector Operations

- **Basic Arithmetic**: Element-wise operations, dot products, norms
- **Advanced Functions**: Cross products, projections, rotations
- **Memory Efficient**: Optimized storage and computation patterns

### Dense Linear Systems

- **Direct Solvers**: LU decomposition, Gaussian elimination
- **Iterative Solvers**: Conjugate gradient, GMRES
- **Condition Analysis**: Matrix conditioning and stability assessment

## 📖 Usage Examples

### Basic Matrix Operations

```v
import vsl.la

// Create matrices
mut a := la.Matrix.new[f64](3, 3)
mut b := la.Matrix.new[f64](3, 3)

// Set values
a.set(0, 0, 1.0)
a.set(0, 1, 2.0)
// ... fill matrices

// Matrix multiplication - create result matrix
mut c := la.Matrix.new[f64](3, 3)
la.matrix_matrix_mul(mut c, 1.0, a, b)

// Print result
println(c)
```

### Vector Operations

```v
import vsl.la

// Create vectors
mut v1 := [1.0, 2.0, 3.0]
mut v2 := [4.0, 5.0, 6.0]

// Calculate dot product
dot := la.vector_dot(v1, v2)
println('Dot product: ${dot}')
```

### Solving Linear Systems

```v
import vsl.la

// Solve Ax = b
mut a := la.Matrix.new[f64](3, 3)
mut b := [1.0, 2.0, 3.0]

// Fill A with data
a.set(0, 0, 2.0)
a.set(0, 1, 1.0)
// ... set more values

// Solve system (simplified example)
// mut x := la.solve_linear_system(a, b)
```

## 🔧 Performance Options

### Pure V Implementation

```sh
v run your_program.v
```

### With OpenBLAS Backend

```sh
v -cflags -lopenblas run your_program.v
```

### With LAPACK Support

```sh
v -cflags "-lopenblas -llapack" run your_program.v
```

## 📚 API Reference

### Core Types

- `Matrix` - Dense matrix representation
- `Vector` - Dense vector representation
- `SparseMatrix` - Sparse matrix for large, sparse data

### Key Functions

- `matrix_new(rows, cols)` - Create new matrix
- `vector_new(size)` - Create new vector
- `matrix_mul(a, b)` - Matrix multiplication
- `solve_linear_system(a, b)` - Linear system solver

## 🎯 Examples

See the following examples for practical usage:

- `la_triplet01` - Basic linear algebra operations
- `data_analysis_example` - Statistical computations with matrices
- `ml_*` examples - Machine learning applications

## 🔬 Advanced Features

### Eigenvalue Analysis

```v
import vsl.la

mut a := la.Matrix.new[f64](4, 4)
// Fill matrix...

// Compute eigenvalues and eigenvectors
// eigenvals, eigenvecs := la.eigen(a)
```

### Matrix Decompositions

```v
import vsl.la

// Create matrix
mut a := la.Matrix.new[f64](4, 4)
// Fill matrix with data...

// LU decomposition
// l, u, p := la.lu_decompose(a)

// QR decomposition
// q, r := la.qr_decompose(a)

// SVD
// u_svd, s, vt := la.svd(a)
```

## 🐛 Troubleshooting

**Compilation errors with BLAS**: Ensure OpenBLAS development packages are installed
**Memory issues**: Use sparse matrices for large, sparse problems
**Numerical instability**: Check matrix conditioning before solving systems

---

For more information, see the [VSL documentation](https://vlang.github.io/vsl) and [examples directory](../examples/).
