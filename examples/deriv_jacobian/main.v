module main

import math
import vsl.deriv

fn model(x []f64) []f64 {
	return [x[0] * x[0] + 3.0 * x[1], math.sin(x[0]) * math.exp(x[1])]
}

fn main() {
	point := [0.5, 0.25]
	result := deriv.jacobian(model, point, 1e-3) or {
		eprintln('could not estimate Jacobian: ${err}')
		return
	}
	println('Input: ${point}')
	println('Jacobian [output, input]:')
	for row_index, row in result.values {
		println('  ${row}; estimated errors: ${result.error_estimate[row_index]}')
	}
	println('Function evaluations: ${result.evaluations}')
}
