module main

import math
import vsl.ode

fn harmonic_oscillator(_ f64, state []f64, _ []f64) []f64 {
	return [state[1], -state[0]]
}

fn first_zero_of_position(_ f64, state []f64, _ []f64) f64 {
	return state[0]
}

fn main() {
	result := ode.solve_rk23(harmonic_oscillator, ode.RK23Params{
		t_start:        0.0
		t_end:          2.0 * math.pi
		initial_state:  [1.0, 0.0]
		abs_tol:        1e-9
		rel_tol:        1e-9
		event_function: first_zero_of_position
	})!
	println('status: ${result.status}')
	println('first position zero: t=${result.t}, state=${result.state}')
	println('accepted/rejected steps: ${result.n_accepted}/${result.n_rejected}')
	assert result.status == .event_detected
	assert math.abs(result.t - math.pi / 2.0) < 1e-6
	assert math.abs(result.state[0]) < 1e-6
}
