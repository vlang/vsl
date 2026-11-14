module main

import vsl.func
import vsl.roots

fn rosenbrock(x []f64, _ []f64) f64 {
	a := 1.0 - x[0]
	b := x[1] - x[0] * x[0]
	return a * a + 100.0 * b * b
}

fn main() {
	objective := func.FnND.new(rosenbrock)
	mut optimizer := roots.NelderMead.new_with_params(objective, roots.NelderMeadParams{
		x0:           [-1.2, 1.0]
		initial_step: 0.5
		x_tol:        1e-6
		f_tol:        1e-12
		n_max:        2000
		max_evals:    5000
	})
	result := optimizer.solve() or {
		panic('Nelder-Mead parameters are invalid: ${err}')
	}
	println('status: ${result.status}')
	println('minimum: x=${result.x}, f(x)=${result.fx}')
	println('simplex spreads: x=${result.x_spread}, f=${result.f_spread}')
	println('iterations: ${result.n_iter}, evaluations: ${result.n_calls}')
	assert result.status == .converged
}
