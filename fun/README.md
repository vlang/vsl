# Special Functions (fun) Module

The `vsl.fun` module provides a comprehensive collection of special mathematical
functions commonly used in scientific computing, engineering, and mathematical
analysis.

## 🚀 Features

### Bessel Functions
- Cylindrical J, Y, I, and K functions support integer orders, including
  common order-zero and order-one variants.
- Fractional-order and spherical families are tracked in [issue #541](https://github.com/vlang/vsl/issues/541).

### Gamma Functions
- **Gamma Function**: Γ(x) and related functions
- **Log Gamma**: Numerically stable logarithmic form
- **Complex Gamma**: Support for complex arguments
- **Digamma Function**: Ψ(x) - logarithmic derivative of gamma

### Error Functions
- **Error Function**: erf(x) and complementary erfc(x)
- Inverse error functions are tracked in [issue #540](https://github.com/vlang/vsl/issues/540).
- The scaled complementary error function `erfcx` is tracked in
  [issue #547](https://github.com/vlang/vsl/issues/547).

### Interpolation
- **Cubic Interpolation**: Smooth curve fitting
- **Quadratic Interpolation**: Efficient polynomial fitting
- **Data Interpolation**: General-purpose data fitting

### Trigonometric and Sinusoid Functions
- Sine and cosine functions with error estimates.
- Parameterized sinusoid helpers for fitting and Fourier approximations.

## 📖 Usage Examples

### Bessel Function Example

```v
import vsl.fun

// Standard Bessel function of the first kind
x := 2.5
order := 1
result := fun.bessel_jn(order, x)
println('J_1(2.5) = ${result}')

// Modified Bessel function
result_i := fun.bessel_in(order, x)
println('I_1(2.5) = ${result_i}')
```

### Gamma Function Example

```v
import vsl.fun

// Standard gamma function
x := 3.5
gamma_val := fun.gamma(x)
println('Γ(3.5) = ${gamma_val}')

// Log gamma for large arguments (numerically stable)
log_gamma_val := fun.log_gamma(x)
println('ln(Γ(3.5)) = ${log_gamma_val}')
```

### Error Function Example

```v
import vsl.fun

// Error function - common in statistics
x := 1.0
erf_val := fun.erf(x)
println('erf(1.0) = ${erf_val}')

// Complementary error function
erfc_val := fun.erfc(x)
println('erfc(1.0) = ${erfc_val}')
```

### Interpolation Example

```v
import vsl.fun

// Data points for interpolation
x_data := [0.0, 1.0, 2.0, 3.0]
y_data := [1.0, 4.0, 9.0, 16.0]

// Create cubic interpolator
mut interp := fun.InterpCubic.new()
interp.fit_4points(x_data[0], y_data[0], x_data[1], y_data[1], x_data[2], y_data[2], x_data[3],
	y_data[3])!

// Evaluate at intermediate point
x_new := 1.5
y_new := interp.f(x_new)
println('Interpolated value at x=1.5: ${y_new}')
```

## 🔬 Mathematical Background

### Bessel Function Background
Bessel functions arise in solving Laplace's equation in cylindrical coordinates. They appear in:
- Wave propagation problems
- Heat conduction in cylinders
- Quantum mechanics (radial wave functions)
- Electromagnetic field problems

### Gamma Function Background
The gamma function extends the factorial to real and complex numbers:
- Γ(n) = (n-1)! for positive integers
- Used in probability distributions
- Appears in many integrals and series

### Error Function Background
Related to the Gaussian distribution:
- erf(x) = (2/√π) ∫₀ˣ e^(-t²) dt
- Fundamental in statistics and probability
- Used in diffusion processes

## 🎯 Examples

See these examples for practical applications:
- `prime_factorization` - Uses gamma function properties
- `data_analysis_example` - Statistical functions
- `noise_*` examples - Error functions in random processes

## 🔧 Performance Notes

- **Table-based functions**: Some functions use precomputed tables for speed
- **Asymptotic expansions**: Used for large arguments
- **Continued fractions**: Employed for intermediate ranges
- **Error handling**: Graceful handling of domain errors

## 🐛 Current Limitations

- Cylindrical Bessel functions currently support integer orders. Fractional-order
  and spherical families are tracked in [issue #541](https://github.com/vlang/vsl/issues/541).
- Bessel functions do not expose error estimates; see
  [issue #543](https://github.com/vlang/vsl/issues/543).
- Extended-precision variants are not available.
- Inverse error functions are not implemented yet; see
  [issue #540](https://github.com/vlang/vsl/issues/540).

## 📚 API Reference

### Core Functions

**Bessel Functions:**
- `bessel_jn(n, x)` - Bessel function of the first kind
- `bessel_yn(n, x)` - Bessel function of the second kind
- `bessel_in(n, x)` - Modified Bessel function of the first kind
- `bessel_kn(n, x)` - Modified Bessel function of the second kind

**Gamma Functions:**
- `gamma(x)` - Gamma function
- `log_gamma(x)` - Logarithm of gamma function
- `digamma(x)` - Digamma function (ψ function)

**Error Functions:**
- `erf(x)` - Error function
- `erfc(x)` - Complementary error function

## 🔗 References

- Abramowitz & Stegun: "Handbook of Mathematical Functions"
- NIST Digital Library of Mathematical Functions
- Numerical Recipes in Scientific Computing

---

For more special functions, see the [VSL documentation](https://vlang.github.io/vsl) and [examples directory](../examples/).
