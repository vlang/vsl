# Quick Reference

A quick reference guide for common VSL operations.

## Plotting

### Basic Plot

```v
import vsl.plot
import vsl.util

mut plt := plot.Plot.new()
x := util.arange(10).map(f64(it))
y := x.map(it * it)
plt.scatter(x: x, y: y)
plt.show()!
```

### Common Plot Types

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
x := []f64{}  // Assume populated
y := []f64{}  // Assume populated
categories := []string{}  // Assume populated
values := []f64{}  // Assume populated
data := []f64{}  // Assume populated
z_matrix := [][]f64{}  // Assume populated

// Scatter
plt.scatter(x: x, y: y, mode: 'lines+markers')

// Line
plt.line(x: x, y: y)

// Bar
plt.bar(x: categories, y: values)

// Histogram
plt.histogram(x: data)

// 3D Scatter
plt.scatter3d(x: x, y: y, z: z)

// Surface
plt.surface(z: z_matrix)
```

## Linear Algebra

### Vector Operations

```v ignore
import vsl.blas.blas64

x := []f64{}  // Assume populated
y := []f64{}  // Assume populated
alpha := 2.0

// Note: BLAS functions require specific parameters - check API documentation
// Dot product: blas64.ddot(n, x, incx, y, incy)
// Norm: blas64.dnrm2(n, x, incx)
// Scale: blas64.dscal(n, alpha, mut x, incx)
```

### Matrix Operations

```v ignore
import vsl.blas.blas64

a := [][]f64{}  // Assume populated
b := [][]f64{}  // Assume populated
x := []f64{}  // Assume populated
mut y := []f64{}  // Assume populated
mut c := [][]f64{}  // Assume populated
m, n, k := 3, 3, 3

// Note: BLAS functions require specific parameters - check API documentation
// Matrix-vector: blas64.dgemv(trans, m, n, alpha, a, lda, x, incx, beta, mut y, incy)
// Matrix-matrix: blas64.dgemm(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, mut c, ldc)
```

## Quaternions

### Creating Quaternions

```v ignore
import vsl.quaternion
import math

// Identity
q := quaternion.id()

// From axis-angle
angle := math.pi / 4.0
x, y, z := 1.0, 0.0, 0.0
q := quaternion.from_axis_anglef3(angle, x, y, z)

// From Euler angles
alpha, beta, gamma := math.pi / 6.0, math.pi / 4.0, math.pi / 3.0
q := quaternion.from_euler_angles(alpha, beta, gamma)
```

### Quaternion Operations

```v ignore
import vsl.quaternion

q1 := quaternion.quaternion(1.0, 2.0, 3.0, 4.0)
q2 := quaternion.quaternion(5.0, 6.0, 7.0, 8.0)
q := quaternion.quaternion(1.0, 2.0, 3.0, 4.0)
t := 0.5

// Addition
q3_add := q1 + q2

// Multiplication
q3_mult := q1 * q2

// Conjugate
qc := q.conjugate()

// Normalize
qn := q.normalized()

// Interpolation
q_interp := q1.slerp(q2, t)
```

## Machine Learning

### Data Preparation

```v ignore
import vsl.ml

x_matrix := [][]f64{}  // Assume populated
y_vector := []f64{}    // Assume populated

// Create data
mut data := ml.Data.new(100, 3, true, true)!
data.set_x(x_matrix)!
data.set_y(y_vector)!

// Split data
mut train_data, test_data := data.split(0.8)!
```

### K-Means Clustering

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_x([][]f64{})!  // Assume populated
mut km := ml.Kmeans.new(mut data, nb_classes: 3, name: 'clustering')
km.train(epochs: 10)
// Access classes via km.classes
```

### Linear Regression

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_xy_sep([][]f64{}, []f64{})!  // Assume populated
mut lr := ml.LinReg.new(mut data, 'linreg')
lr.fit()
// Use lr to make predictions (check ML module API for prediction methods)
```

## FFT

### Fast Fourier Transform

```v ignore
import vsl.fft

signal := []f64{}  // Assume populated

// Create FFT plan
mut plan := fft.create_plan(signal)!

// Forward FFT
fft.forward_fft(plan, mut signal)

// Inverse FFT
fft.inverse_fft(plan, mut signal)
```

## Geometry

### 3D Points

```v
import vsl.gm

p1 := gm.Point.new(1.0, 2.0, 3.0)
p2 := gm.Point.new(4.0, 5.0, 6.0)

// Distance
dist := gm.dist_point_point(p1, p2)
```
```

## Numerical Methods

### Root Finding

```v
import vsl.roots

// Bisection method
root := roots.bisection(f, a, b, tol: 1e-6)
```

### Differentiation

```v ignore
import vsl.deriv

fn f(x f64) f64 {
    return x * x
}

// Numerical derivative
mut result, mut abserr := deriv.central(f, 2.0, 1e-8)
```

## Common Patterns

### Data Generation

```v ignore
import vsl.util

// Range
x1 := util.arange(10).map(f64(it))

// Linspace
x2 := util.linspace(0.0, 10.0, 100)
```
```

### Plotting Multiple Traces

```v
mut plt := plot.Plot.new()
plt.scatter(x: x1, y: y1, name: 'Series 1')
plt.scatter(x: x2, y: y2, name: 'Series 2')
plt.layout(title: 'Multiple Series')
plt.show()!
```

## Compilation Flags

```sh
# Pure V (default)
v run program.v

# With OpenBLAS
v -d vsl_blas_cblas run program.v

# With LAPACKE
v -d vsl_lapack_lapacke run program.v

# Both
v -d vsl_blas_cblas -d vsl_lapack_lapacke run program.v
```

## Module Imports

```v
import vsl.plot // Plotting
import vsl.blas // BLAS operations
import vsl.lapack // LAPACK operations
import vsl.quaternion // Quaternions
import vsl.ml // Machine learning
import vsl.fft // Fast Fourier Transform
import vsl.gm // Geometry
import vsl.util // Utilities
import vsl.deriv // Differentiation
import vsl.roots // Root finding
```

## Next Steps

- Explore [Examples Directory](../../examples/)
- Read [Full Tutorials](../README.md)
- Check [API Documentation](https://vlang.github.io/vsl)
