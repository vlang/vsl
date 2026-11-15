module main

import vsl.func
import vsl.roots

fn rosenbrock(x []f64, _ []f64) f64 {
	a := 1.0 - x[0]
	b := x[1] - x[0] * x[0]
	return a * a + 100.0 * b * b
}

fn rosenbrock_gradient(x []f64, _ []f64) []f64 {
	b := x[1] - x[0] * x[0]
	return [2.0 * (x[0] - 1.0) - 400.0 * x[0] * b, 200.0 * b]
}

fn main() {
	objective := func.FnND.new(rosenbrock)
	mut optimizer := roots.BFGS.new_with_params(objective, rosenbrock_gradient,
		roots.BFGSParams{
			x0:           [-1.2, 1.0]
			gradient_tol: 1e-6
			n_max:        1000
			max_evals:    5000
		})
	result := optimizer.solve() or {
		panic('BFGS parameters are invalid: ${err}')
	}
	println('status: ${result.status}')
	println('minimum: x=${result.x}, f(x)=${result.fx}')
	println('gradient norm: ${result.gradient_norm}')
	println('iterations: ${result.n_iter}, evaluations: ${result.n_calls}')
	assert result.status == .converged
}
