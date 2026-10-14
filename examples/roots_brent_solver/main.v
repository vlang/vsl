module main

import math
import vsl.func
import vsl.roots

fn objective(x f64, _ []f64) f64 {
	return math.cos(x)
}

fn main() {
	f := func.Fn.new(f: objective)
	mut solver := roots.Brent.new_with_params(f, roots.BrentParams{
		x1:        0.0
		x2:        3.0
		tol:       1e-10
		n_max:     100
		max_evals: 102
	})
	result := solver.solve() or { panic('Brent solver parameters are invalid: ${err}') }
	println('status: ${result.status}')
	println('root: ${result.x}, residual: ${result.fx}')
	println('bracket: [${result.lower}, ${result.upper}]')
	println('iterations: ${result.n_iter}, evaluations: ${result.n_calls}')
	assert result.status == .converged
}
