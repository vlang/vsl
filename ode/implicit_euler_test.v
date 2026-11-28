module ode

import math

fn stiff_manifold(t f64, y []f64, _ []f64) []f64 {
	return [-1000.0 * (y[0] - math.cos(t)) - math.sin(t)]
}

fn stiff_decay(_ f64, y []f64, _ []f64) []f64 {
	return [-1000.0 * y[0]]
}

fn growing_exponential(_ f64, y []f64, _ []f64) []f64 {
	return [y[0]]
}

fn bad_shape(_ f64, y []f64, _ []f64) []f64 {
	return [y[0], y[0]]
}

fn non_finite_derivative(_ f64, _ []f64, _ []f64) []f64 {
	return [math.nan()]
}

fn test_implicit_euler_handles_stiff_manifold() {
	result := solve_implicit_euler(stiff_manifold,
		t_start:       0.0
		t_end:         1.0
		initial_state: [f64(0.0)]
		initial_step:  0.1
		max_step:      1.0
		abs_tol:       1e-6
		rel_tol:       1e-4
	) or {
		assert false, 'stiff solve failed: ${err}'
		return
	}
	assert result.status == .converged
	assert math.abs(result.t - 1.0) < 1e-12
	assert math.abs(result.state[0] - math.cos(1.0)) < 1e-3
	assert result.n_accepted > 0
	assert result.n_calls > 0
}

fn test_implicit_euler_decay_is_stable() {
	result := solve_implicit_euler(stiff_decay,
		t_start:       0.0
		t_end:         0.001
		initial_state: [f64(1.0)]
		initial_step:  0.001
		max_step:      0.01
		abs_tol:       1e-6
		rel_tol:       1e-4
	) or {
		assert false, 'stiff decay solve failed: ${err}'
		return
	}
	assert result.status == .converged
	assert result.state[0] > 0.0
	assert math.abs(result.state[0] - math.exp(-1.0)) < 5e-3
}

fn test_implicit_euler_integrates_backwards() {
	result := solve_implicit_euler(growing_exponential,
		t_start:       0.0
		t_end:         -1.0
		initial_state: [f64(1.0)]
		initial_step:  0.1
		max_step:      0.5
		abs_tol:       1e-9
		rel_tol:       1e-6
	) or {
		assert false, 'backward solve failed: ${err}'
		return
	}
	assert result.status == .converged
	assert math.abs(result.t + 1.0) < 1e-12
	assert math.abs(result.state[0] - math.exp(-1.0)) < 5e-4
}

fn test_implicit_euler_zero_interval() {
	result := solve_implicit_euler(stiff_decay,
		t_start:       1.0
		t_end:         1.0
		initial_state: [f64(2.0)]
		initial_step:  0.1
		max_step:      0.1
	)!
	assert result.status == .converged
	assert result.state[0] == 2.0
	assert result.n_steps == 0
}

fn test_implicit_euler_reports_max_steps() {
	result := solve_implicit_euler(stiff_manifold,
		t_start:       0.0
		t_end:         1.0
		initial_state: [f64(0.0)]
		initial_step:  0.1
		max_step:      1.0
		abs_tol:       1e-6
		rel_tol:       1e-4
		max_steps:     1
	)!
	assert result.status == .max_steps
	assert result.t < 1.0
}

fn test_implicit_euler_rejects_invalid_parameters() {
	solve_implicit_euler(stiff_decay,
		t_start:       0.0
		t_end:         1.0
		initial_state: [f64(1.0)]
		initial_step:  0.0
		max_step:      1.0
	) or {
		return
	}
	assert false, 'expected a non-positive initial step to be rejected'
	solve_implicit_euler(stiff_decay,
		t_start:       0.0
		t_end:         1.0
		initial_state: [f64(1.0)]
		initial_step:  0.1
		max_step:      1.0
		abs_tol:       0.0
		rel_tol:       0.0
	) or {
		return
	}
	assert false, 'expected zero tolerances to be rejected'
	solve_implicit_euler(stiff_decay,
		t_start:       0.0
		t_end:         1.0
		initial_state: [f64(math.nan())]
		initial_step:  0.1
		max_step:      1.0
	) or {
		return
	}
	assert false, 'expected a non-finite initial state to be rejected'
}

fn test_implicit_euler_reports_bad_callbacks() {
	shaped := solve_implicit_euler(bad_shape,
		t_start:       0.0
		t_end:         1.0
		initial_state: [f64(1.0)]
		initial_step:  0.1
		max_step:      0.1
	)!
	assert shaped.status == .invalid_function_output

	non_finite := solve_implicit_euler(non_finite_derivative,
		t_start:       0.0
		t_end:         1.0
		initial_state: [f64(1.0)]
		initial_step:  0.1
		max_step:      0.1
	)!
	assert non_finite.status == .non_finite_function_value
}
