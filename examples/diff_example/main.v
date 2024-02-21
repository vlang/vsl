module main

import vsl.diff
import vsl.float.float64
import vsl.func
import math

fn pow(x f64, _ []f64) f64 {
	return math.pow(x, 1.5)
}

fn main() {
	f := func.Fn.new(f: pow)
	println('f(x) = x^(3/2)')

	mut expected := 1.5 * math.sqrt(2.0)
	mut result, mut abserr := diff.central(f, 2.0)
	println('x = 2.0')
	println("f'(x) = ${result} +/- ${abserr}")
	println('exact = ${expected}')

	assert float64.soclose(result, expected, abserr)

	expected = 0.0
	result, abserr = diff.forward(f, 0.0)
	println('x = 0.0')
	println("f'(x) = ${result} +/- ${abserr}")
	println('exact = ${expected}')

	assert float64.soclose(result, expected, abserr)
}
