module main

import math
import vsl.deriv

fn potential(x []f64) f64 {
	return x[0] * x[0] + 2.0 * x[0] * x[1] + math.cos(x[1])
}

fn main() {
	point := [0.5, 0.25]
	result := deriv.hessian(potential, point, 1e-3) or {
		eprintln('could not estimate Hessian: ${err}')
		return
	}
	println('Input: ${point}')
	println('Hessian [input, input]:')
	for row_index, row in result.values {
		println('  ${row}; estimated errors: ${result.error_estimate[row_index]}')
	}
	println('Function evaluations: ${result.evaluations}')
}
