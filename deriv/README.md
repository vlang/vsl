# Numerical Derivates

The functions described in this chapter compute numerical derivatives by
finite differencing. An adaptive algorithm is used to find the best
choice of finite difference and to estimate the error in the derivative.

More information is available in **[the documentation of this package](https://vsl.readthedocs.io/en/latest/diff.html).**

## Usage example

```v
module diff

import vsl.vmath
import vsl.deriv
import vsl

fn func(x f64, _ []f64) f64 {
	return vmath.pow(x, 1.5)
}

fn main() {
	f := vsl.Function{function: func}
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
