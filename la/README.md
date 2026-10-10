# Linear Algebra (la) Module

The `vsl.la` module provides comprehensive linear algebra operations for
scientific computing, including matrix operations, vector manipulations, and
numerical linear algebra algorithms.

MPI is not required for the standard `vsl.la` API. Communicator support on
`SparseConfig` is opt-in at compile time with `-d vsl_mpi`; enabling it requires
an MPI implementation and exposes `SparseConfig.with_comm`. Without the flag,
`SparseConfig.new` and non-MPI solvers do not import MPI headers or libraries.

## 🚀 Features

### Matrix Operations

- **Basic Operations**: Element-wise addition, subtraction, division, integer
  remainder, matrix multiplication, and transposition
- **Advanced Operations**: Decompositions (LU, QR, SVD), eigenvalue analysis
- **Sparse Matrices**: Efficient storage and operations for sparse data
- **BLAS Integration**: Optional high-performance BLAS backend

### Vector Example

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

`Matrix` supports element-wise `+`, `-`, `/`, and integer-only `%` between
equal-shaped matrices. `*` performs conventional matrix multiplication and
requires matching inner dimensions. Scalar arithmetic is available through
`add_scalar`, `sub_scalar`, `scale`, and `div_scalar`; integer matrices also
provide `remainder_scalar`. These methods return a new matrix and leave the
input unchanged. Since constructors return heap references and V
uses `-` for pointer subtraction, dereference both operands when using matrix
subtraction.

```v
import vsl.la

a := la.Matrix.deep2([[f64(1), 2], [3, 4]])
b := la.Matrix.deep2([[f64(5), 6], [7, 8]])
sum := a + b
product := a * b
subtracted := (*b) - (*a)
println(sum) // [[6, 8], [10, 12]]
println(product) // [[19, 22], [43, 50]]
println(subtracted) // [[4, 4], [4, 4]]
println(a.scale(2.0)) // [[2, 4], [6, 8]]
println(a.add_scalar(1.0)) // [[2, 3], [4, 5]]
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

### Least Squares

`lstsq` returns the minimum-norm solution, squared residual sums, effective
rank, and descending singular values. Its default rank cutoff is
`max(m, n) * f64_epsilon * largest_singular_value`. Residuals are present only
for overdetermined, full-column-rank systems; underdetermined or rank-deficient
systems return an empty residual slice. Use `lstsq_with_rcond` to choose an
explicit non-negative relative cutoff, or a negative value for the default.

```v
import vsl.la

a := la.Matrix.deep2([[1.0, 0], [0, 1], [1, 1]])
b := la.Matrix.deep2([[1.0], [2], [4]])
x, residuals, rank, singular_values := la.lstsq(a, b)
// x ≈ [[1.3333], [2.3333]], residuals ≈ [0.3333], rank == 2
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
# Accurate vector accumulation

The usual `vector_accum` and `vector_dot` favor throughput. For f64 workflows
where cancellation can erase small terms, `vector_sum_accurate` and
`vector_dot_accurate` use Neumaier compensated accumulation. The dot product
also uses fused multiply-add to recover each finite product's rounding error.
It returns an error when vector lengths differ. These helpers are opt-in because
compensation adds work to each element.
