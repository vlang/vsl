module main

import math
import vsl.ode

fn harmonic_oscillator(_ f64, state []f64, _ []f64) []f64 {
	return [state[1], -state[0]]
}

fn main() {
	result := ode.solve_rk23(harmonic_oscillator, ode.RK23Params{
		t_start:       0.0
		t_end:         2.0 * math.pi
		initial_state: [1.0, 0.0]
		abs_tol:       1e-9
		rel_tol:       1e-9
	})!
	println('status: ${result.status}')
	println('state after one period: ${result.state}')
	println('accepted/rejected steps: ${result.n_accepted}/${result.n_rejected}')
	assert result.status == .converged
}
