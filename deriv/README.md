# 🚀 Numerical Differentiation

This module provides functions for computing numerical derivatives of functions. 🧮

An adaptive algorithm is used to find the best choice of finite difference and to
estimate the error in the derivative. 🎯

The development of this module is inspired by the same present in
[GSL](https://github.com/ampl/gsl) 📚, looking to adapt it completely
to the practices and tools present in VSL. 🛠️

## Functions

### `central`

```v ignore
fn central (f func.Fn, x, h f64) (f64, f64)
```

This function computes the numerical derivative of the function `f` at the point `x`
using an adaptive central difference algorithm with a step-size of `h`. The derivative
is returned in `result` and an estimate of its absolute error is returned in `abserr`.

The initial value of `h` is used to estimate an optimal step-size, based on the scaling
of the truncation error and round-off error in the derivative calculation.
The derivative is computed using a 5-point rule for equally spaced abscissae
at `x - h`, `x - h/2`, `x`, `x + h/2`, `x+h`, with an error estimate taken
from the difference between the 5-point rule and the corresponding 3-point
rule `x-h`, `x`, `x+h`. Note that the value of the function at `x` does not
contribute to the derivative calculation, so only 4-points are actually used. 🧐

### `forward`

```v ignore
fn forward (f func.Fn, x, h f64) (f64, f64)
```

This function computes the numerical derivative of the function `f` at the point `x`
using an adaptive forward difference algorithm with a step-size of `h`. The function
is evaluated only at points greater than `x`, and never at `x` itself. The derivative
is returned in `result` and an estimate of its absolute error is returned in `abserr`.
This function should be used if `f(x)` has a discontinuity at `x`, or
is undefined for values less than `x`. 📈

The initial value of `h` is used to estimate an optimal step-size, based on the scaling
of the truncation error and round-off error in the derivative calculation. The derivative
at `x` is computed using an "open" 4-point rule for equally spaced abscissae at `x+h/4`,
`x + h/2`, `x + 3h/4`, `x+h`, with an error estimate taken from the difference between
the 4-point rule and the corresponding 2-point rule `x+h/2`, `x+h`. 🚀

### `backward`

```v ignore
fn backward (f func.Fn, x, h f64) (f64, f64)
```

This function computes the numerical derivative of the function `f` at the point `x`
using an adaptive backward difference algorithm with a step-size of `h`. The function
is evaluated only at points less than `x`, and never at `x` itself. The derivative is
returned in `result` and an estimate of its absolute error is returned in `abserr`.
This function should be used if `f(x)` has a discontinuity at `x`, or is undefined
for values greater than `x`. 📉

This function is equivalent to calling `deriv.forward` with a negative step-size.

### `partial`

```v ignore
pub fn partial(f fn ([]f64) f64, x []f64, variable int, h f64) (f64, f64)
```

This function computes the partial derivative of the function `f` with respect to
a specified variable at point `x` using step-size `h`. It returns the derivative
in `result` and an error estimate in `abserr`. The function `f` should take an array
of coordinates and return a single value. This method provides both the derivative
and its error estimate.

### `jacobian`

```v ignore
pub fn jacobian(f fn ([]f64) []f64, x []f64, h f64) !JacobianResult
```

This function estimates the Jacobian of a vector-valued function at `x`.
`JacobianResult.values` and `error_estimate` use shape
`[output_length, input_length]`: rows are output components and columns are
input coordinates. It evaluates each coordinate with central differences at a
scale-aware step and half-step, then applies Richardson extrapolation. The
difference between those estimates supplies the per-entry error estimate.
A non-positive or non-finite step, non-finite input or output, changing output
length, or unrepresentable perturbation returns an error. `evaluations`
includes the initial output-shape check and all successful perturbation calls.

```v
import math
import vsl.deriv

fn model(x []f64) []f64 {
	return [x[0] * x[0] + 3.0 * x[1], math.sin(x[0]) * math.exp(x[1])]
}

result := deriv.jacobian(model, [0.5, 0.25], 1e-3)!
println('Jacobian: ${result.values}')
println('Error estimates: ${result.error_estimate}')
```

See the [multivariable Jacobian example](../examples/deriv_jacobian/README.md)
for a complete program.

## References and Further Reading

This work is a spiritual descendent of the Differentiation module in [GSL](https://github.com/ampl/gsl). 📖

Feel free to explore and utilize these numerical differentiation functions in
your projects! 🤖📊🔬
