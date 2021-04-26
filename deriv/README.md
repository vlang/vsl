# Numerical Differentiation

The functions described in this chapter compute numerical derivatives by
finite differencing. An adaptive algorithm is used to find the best
choice of finite difference and to estimate the error in the derivative.

Again, the development of this module is inspired by the same present in GSL
looking to adapt it completely to the practices and tools present in VSL.

The functions described in this chapter are declared in the module `vsl.deriv`

## Usage example

```v
module main

import vsl.vmath
import vsl.deriv
import vsl

fn func(x f64, _ []f64) f64 {
	return vmath.pow(x, 1.5)
}

fn main() {
	f := vsl.Fn{
		f: func
	}
	println('f(x) = x^(3/2)')
	mut expected := 1.5 * vmath.sqrt(2.0)
	mut result, mut abserr := deriv.central(f, 2.0, 1e-8)
	println('x = 2.0')
	println("f'(x) = $result +/- $abserr")
	println('exact = $expected')
	expected = 0.0
	result, abserr = deriv.forward(f, 0.0, 1e-8)
	println('x = 0.0')
	println("f'(x) = $result +/- $abserr")
	println('exact = $expected')
}
```

Will print

```
f(x) = x^(3/2)
x = 2.0
f'(x) = 2.1213203120 +/- 0.0000005006
exact = 2.1213203436

x = 0.0
f'(x) = 0.0000000160 +/- 0.0000000339
exact = 0.0000000000
```

# Fns

```v ignore
fn central (f vsl.Fn, x, h f64) (f64, f64)
```

This function computes the numerical derivative of the function `f`
at the point `x` using an adaptive central difference algorithm with
a step-size of `h`. The derivative is returned in `result` and an
estimate of its absolute error is returned in `abserr`.

The initial value of `h` is used to estimate an optimal step-size,
based on the scaling of the truncation error and round-off error in the
derivative calculation. The derivative is computed using a 5-point rule
for equally spaced abscissae at `x - h`, `x - h/2`, `x`,
`x + h/2`, `x+h`, with an error estimate taken from the difference
between the 5-point rule and the corresponding 3-point rule `x-h`,
`x`, `x+h`. Note that the value of the function at `x`
does not contribute to the derivative calculation, so only 4-points are
actually used.

```v ignore
fn forward (f vsl.Fn, x, h f64) (f64, f64)
```

This function computes the numerical derivative of the function `f`
at the point `x` using an adaptive forward difference algorithm with
a step-size of `h`. The function is evaluated only at points greater
than `x`, and never at `x` itself. The derivative is returned in
`result` and an estimate of its absolute error is returned in
`abserr`. This function should be used if `f(x)` has a
discontinuity at `x`, or is undefined for values less than `x`.

The initial value of `h` is used to estimate an optimal step-size,
based on the scaling of the truncation error and round-off error in the
derivative calculation. The derivative at `x` is computed using an
"open" 4-point rule for equally spaced abscissae at `x+h/4`,
`x + h/2`, `x + 3h/4`, `x+h`, with an error estimate taken
from the difference between the 4-point rule and the corresponding
2-point rule `x+h/2`, `x+h`.

```v ignore
fn backward (f vsl.Fn, x, h f64) (f64, f64)
```

This function computes the numerical derivative of the function `f`
at the point `x` using an adaptive backward difference algorithm
with a step-size of `h`. The function is evaluated only at points
less than `x`, and never at `x` itself. The derivative is
returned in `result` and an estimate of its absolute error is
returned in `abserr`. This function should be used if `f(x)`
has a discontinuity at `x`, or is undefined for values greater than
`x`.

This function is equivalent to calling `deriv.forward` with a
negative step-size.

# References and Further Reading

This work is a spiritual descendent of the Differentiation module in GSL.
