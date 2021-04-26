# Numerical Differentiation

The functions described in this chapter compute numerical derivatives by
finite differencing. An adaptive algorithm is used to find the best
choice of finite difference and to estimate the error in the derivative.

## Usage example

```v
module main

import vsl.diff
import vsl.func
import vsl.vmath

fn pow(x f64, _ []f64) f64 {
	return vmath.pow(x, 1.5)
}

fn main() {
	f := func.new_func(pow)
	println('f(x) = x^(3/2)')
	mut expected := 1.5 * vmath.sqrt(2.0)
	mut result, mut abserr := diff.central(f, 2.0)
	println('x = 2.0')
	println("f'(x) = $result +/- $abserr")
	println('exact = $expected')
	expected = 0.0
	result, abserr = diff.forward(f, 0.0)
	println('x = 0.0')
	println("f'(x) = $result +/- $abserr")
	println('exact = $expected')
}
```
