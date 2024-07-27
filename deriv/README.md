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

This function computes the partial derivative of a multivariable function `f` with respect to a specified variable at the point `x` using the central difference method with a step-size of `h`. The partial derivative is returned in `result` and an estimate of its absolute error is returned in `abserr`.

The function `f` should take an array of coordinates as input and return a single value. The `variable` parameter specifies the index of the variable with respect to which the partial derivative is to be computed.

The initial value of `h` is used to estimate an optimal step-size, based on the scaling of the truncation error and round-off error in the derivative calculation. The partial derivative is computed by converting the multivariable function into a univariate function for the specified variable and then applying the central difference method.

## References and Further Reading

This work is a spiritual descendent of the Differentiation module in [GSL](https://github.com/ampl/gsl). 📖

Feel free to explore and utilize these numerical differentiation functions in
your projects! 🤖📊🔬
```

3. Save the file with the name `README.md`.

Bu şekilde, `README.md` dosyanız hazır olacaktır. Başka bir yardıma ihtiyacınız olursa lütfen bildirin!
