module ode

import math

fn exponential_system(_ f64, state []f64, _ []f64) []f64 {
	return [state[0]]
}

fn oscillator_system(_ f64, state []f64, _ []f64) []f64 {
	return [state[1], -state[0]]
}

fn non_finite_system(_ f64, _ []f64, _ []f64) []f64 {
	return [math.nan()]
}

fn zero_system(_ f64, state []f64, _ []f64) []f64 {
	return [state[0] * 0.0]
}

fn wrong_shape_system(_ f64, _ []f64, _ []f64) []f64 {
	return [1.0, 2.0]
}

fn test_rk23_adapts_and_integrates_scalar_system() {
	result := solve_rk23(exponential_system, RK23Params{
		t_start:       0.0
		t_end:         1.0
		initial_state: [1.0]
		initial_step:  1.0
		abs_tol:       1e-10
		rel_tol:       1e-10
	})!
	assert result.status == .converged
	assert math.abs(result.state[0] - math.e) < 1e-8
	assert result.t == 1.0
	assert result.n_rejected > 0
	assert result.n_accepted > 0
	assert result.n_calls == 4 * result.n_steps
}

fn test_rk23_integrates_vector_system_and_backward_time() {
	period := 2.0 * math.pi
	oscillator := solve_rk23(oscillator_system, RK23Params{
		t_start:       0.0
		t_end:         period
		initial_state: [1.0, 0.0]
		initial_step:  0.5
		abs_tol:       1e-9
		rel_tol:       1e-9
	})!
	assert oscillator.status == .converged
	assert math.abs(oscillator.state[0] - 1.0) < 1e-6
	assert math.abs(oscillator.state[1]) < 1e-6

	backward := solve_rk23(exponential_system, RK23Params{
		t_start:       1.0
		t_end:         0.0
		initial_state: [math.e]
		abs_tol:       1e-9
		rel_tol:       1e-9
	})!
	assert backward.status == .converged
	assert math.abs(backward.state[0] - 1.0) < 1e-7
	assert backward.t == 0.0
}

fn test_rk23_reports_limits_and_callback_errors() {
	evaluation_limited := solve_rk23(exponential_system, RK23Params{
		t_start:       0.0
		t_end:         1.0
		initial_state: [1.0]
		initial_step:  0.1
		max_evals:     1
	})!
	assert evaluation_limited.status == .max_evaluations
	assert evaluation_limited.n_calls == 1

	step_limited := solve_rk23(exponential_system, RK23Params{
		t_start:       0.0
		t_end:         1.0
		initial_state: [1.0]
		initial_step:  1.0
		abs_tol:       1e-30
		rel_tol:       1e-30
		max_steps:     1
	})!
	assert step_limited.status == .max_steps
	assert step_limited.n_steps == 1
	assert step_limited.n_rejected == 1

	non_finite := solve_rk23(non_finite_system, RK23Params{
		t_start:       0.0
		t_end:         1.0
		initial_state: [1.0]
	})!
	assert non_finite.status == .non_finite_function_value

	wrong_shape := solve_rk23(wrong_shape_system, RK23Params{
		t_start:       0.0
		t_end:         1.0
		initial_state: [1.0]
	})!
	assert wrong_shape.status == .invalid_function_output
}

fn test_rk23_zero_duration_does_not_evaluate_callback() {
	result := solve_rk23(non_finite_system, RK23Params{
		t_start:       2.0
		t_end:         2.0
		initial_state: [3.0]
	})!
	assert result.status == .converged
	assert result.state == [3.0]
	assert result.n_calls == 0
	assert result.n_steps == 0
}

fn test_rk23_respects_maximum_step_after_adaptation() {
	result := solve_rk23(zero_system, RK23Params{
		t_start:       0.0
		t_end:         1.0
		initial_state: [0.0]
		initial_step:  0.05
		max_step:      0.1
	})!
	assert result.status == .converged
	assert result.n_accepted >= 10
}

fn test_rk23_rejects_invalid_parameters_and_state() {
	solve_rk23(exponential_system, RK23Params{
		t_start:       0.0
		t_end:         1.0
		initial_state: [1.0]
		abs_tol:       0.0
		rel_tol:       0.0
	}) or {
		assert err.msg().contains('invalid RK23 parameters')
		return
	}
	assert false, 'expected invalid tolerances to be rejected'
}
