module main

import math
import vsl.func
import vsl.integrate

fn oscillatory(x f64, _ []f64) f64 {
	return math.sin(20.0 * x)
}

fn main() {
	f := func.Fn.new(f: oscillatory)
	result := integrate.adaptive_gauss_kronrod(f, integrate.GaussKronrodParams{
		a:       0.0
		b:       1.0
		abs_tol: 1e-10
		rel_tol: 1e-10
	}) or { panic('integration parameters are invalid: ${err}') }
	println('status: ${result.status}')
	println('integral: ${result.value}')
	println('estimated error: ${result.error_estimate}')
	println('intervals: ${result.n_intervals}, evaluations: ${result.n_calls}')
	assert result.status == .converged
}
