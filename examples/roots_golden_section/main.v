module main

import vsl.func
import vsl.roots

fn objective(x f64, _ []f64) f64 {
	return (x - 1.25) * (x - 1.25)
}

fn main() {
	f := func.Fn.new(f: objective)
	mut minimizer := roots.GoldenSection.new_with_params(f, roots.GoldenSectionParams{
		xmin:      -5.0
		xmax:      5.0
		tol:       1e-8
		n_max:     100
		max_evals: 104
	})
	result := minimizer.solve() or {
		panic('Golden-section minimizer parameters are invalid: ${err}')
	}
	println('status: ${result.status}')
	println('minimum: x=${result.x}, f(x)=${result.fx}')
	println('interval: [${result.lower}, ${result.upper}]')
	println('error bound: ${result.error_bound}')
	println('iterations: ${result.n_iter}, evaluations: ${result.n_calls}')
	assert result.status == .converged
}
