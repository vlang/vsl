module main

import math
import vsl.ode

// A classic stiff test problem whose exact solution is cos(t). The large
// coefficient forces explicit solvers to take very small steps.
fn stiff_manifold(t f64, state []f64, _ []f64) []f64 {
	return [-1000.0 * (state[0] - math.cos(t)) - math.sin(t)]
}

fn main() {
	for tolerance in [f64(1e-4), 1e-6] {
		result := ode.solve_implicit_euler(stiff_manifold, ode.ImplicitEulerParams{
			t_start:       0.0
			t_end:         1.0
			initial_state: [f64(0.0)]
			initial_step:  0.1
			max_step:      1.0
			abs_tol:       tolerance * 1e-2
			rel_tol:       tolerance
		}) or {
			eprintln('stiff solve failed: ${err}')
			return
		}
		error := math.abs(result.state[0] - math.cos(1.0))
		println('rtol=${tolerance:.0e}: y=${result.state[0]:.10f}, error=${error:.3e}, ' +
			'steps=${result.n_steps} (accepted ${result.n_accepted}), ' +
			'evaluations=${result.n_calls}, status=${result.status}')
	}
}
