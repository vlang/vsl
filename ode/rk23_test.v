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

fn unit_rate_system(_ f64, _ []f64, _ []f64) []f64 {
	return [1.0]
}

fn event_at_four_tenths(_ f64, state []f64, _ []f64) f64 {
	return state[0] - 0.4
}

fn event_at_one(_ f64, state []f64, _ []f64) f64 {
	return state[0] - 1.0
}

fn event_at_zero(_ f64, state []f64, _ []f64) f64 {
	return state[0]
}

fn non_finite_event(_ f64, _ []f64, _ []f64) f64 {
	return math.nan()
}

fn non_finite_event_after_start(t f64, _ []f64, _ []f64) f64 {
	return if t == 0.0 { -1.0 } else { math.inf(1) }
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
		output_times:  [period * 0.5]
	})!
	assert oscillator.status == .converged
	assert math.abs(oscillator.state[0] - 1.0) < 1e-6
	assert math.abs(oscillator.state[1]) < 1e-6
	assert math.abs(oscillator.sampled_states[0][0] + 1.0) < 1e-6
	assert math.abs(oscillator.sampled_states[0][1]) < 1e-6

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
		output_times:  [2.0, 2.0]
	})!
	assert result.status == .converged
	assert result.state == [3.0]
	assert result.sampled_times == [2.0, 2.0]
	assert result.sampled_states == [[3.0], [3.0]]
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

fn test_rk23_samples_requested_times_with_dense_interpolation() {
	result := solve_rk23(exponential_system, RK23Params{
		t_start:       0.0
		t_end:         1.0
		initial_state: [1.0]
		initial_step:  0.7
		abs_tol:       1e-10
		rel_tol:       1e-10
		output_times:  [0.0, 0.25, 0.5, 1.0, 1.0]
	})!
	assert result.status == .converged
	assert result.n_rejected > 0
	assert result.sampled_times == [0.0, 0.25, 0.5, 1.0, 1.0]
	assert result.sampled_states.len == result.sampled_times.len
	for i, time in result.sampled_times {
		assert math.abs(result.sampled_states[i][0] - math.exp(time)) < 1e-8
	}

	backward := solve_rk23(exponential_system, RK23Params{
		t_start:       1.0
		t_end:         0.0
		initial_state: [math.e]
		abs_tol:       1e-10
		rel_tol:       1e-10
		output_times:  [1.0, 0.5, 0.0]
	})!
	assert backward.status == .converged
	assert backward.sampled_times == [1.0, 0.5, 0.0]
	assert math.abs(backward.sampled_states[1][0] - math.exp(0.5)) < 1e-8
	assert math.abs(backward.sampled_states[2][0] - 1.0) < 1e-8
}

fn test_rk23_returns_only_samples_reached_before_execution_limit() {
	result := solve_rk23(exponential_system, RK23Params{
		t_start:       0.0
		t_end:         1.0
		initial_state: [1.0]
		initial_step:  0.1
		abs_tol:       1e-4
		rel_tol:       1e-4
		max_steps:     1
		output_times:  [0.0, 0.05, 0.1, 0.2]
	})!
	assert result.status == .max_steps
	assert result.n_accepted == 1
	assert result.sampled_times == [0.0, 0.05, 0.1]
	assert math.abs(result.sampled_states[1][0] - math.exp(0.05)) < 1e-5
}

fn test_rk23_localizes_events_forward_and_backward() {
	forward := solve_rk23(unit_rate_system, RK23Params{
		t_start:        0.0
		t_end:          1.0
		initial_state:  [0.0]
		initial_step:   1.0
		output_times:   [0.2, 0.6]
		event_function: event_at_four_tenths
	})!
	assert forward.status == .event_detected
	assert math.abs(forward.t - 0.4) < 1e-14
	assert math.abs(forward.state[0] - 0.4) < 1e-14
	assert forward.sampled_times == [0.2]
	assert math.abs(forward.sampled_states[0][0] - 0.2) < 1e-14

	backward := solve_rk23(unit_rate_system, RK23Params{
		t_start:        1.0
		t_end:          0.0
		initial_state:  [1.0]
		initial_step:   1.0
		output_times:   [1.0, 0.75, 0.25]
		event_function: event_at_four_tenths
	})!
	assert backward.status == .event_detected
	assert math.abs(backward.t - 0.4) < 1e-14
	assert math.abs(backward.state[0] - 0.4) < 1e-14
	assert backward.sampled_times == [1.0, 0.75]
	assert math.abs(backward.sampled_states[1][0] - 0.75) < 1e-14
}

fn test_rk23_events_handle_initial_and_endpoint_roots() {
	initial := solve_rk23(unit_rate_system, RK23Params{
		t_start:        0.0
		t_end:          1.0
		initial_state:  [0.0]
		event_function: event_at_zero
	})!
	assert initial.status == .event_detected
	assert initial.t == 0.0
	assert initial.state == [0.0]
	assert initial.n_calls == 0
	assert initial.n_event_calls == 1

	endpoint := solve_rk23(unit_rate_system, RK23Params{
		t_start:        0.0
		t_end:          1.0
		initial_state:  [0.0]
		initial_step:   1.0
		event_function: event_at_one
	})!
	assert endpoint.status == .event_detected
	assert endpoint.t == 1.0
	assert endpoint.state == [1.0]
	assert endpoint.n_event_calls == 2
}

fn test_rk23_reports_non_finite_event_values() {
	initial := solve_rk23(unit_rate_system, RK23Params{
		t_start:        0.0
		t_end:          1.0
		initial_state:  [0.0]
		event_function: non_finite_event
	})!
	assert initial.status == .non_finite_event_value
	assert initial.n_event_calls == 1

	after_start := solve_rk23(unit_rate_system, RK23Params{
		t_start:        0.0
		t_end:          1.0
		initial_state:  [0.0]
		initial_step:   1.0
		event_function: non_finite_event_after_start
	})!
	assert after_start.status == .non_finite_event_value
	assert after_start.t == 0.0
	assert after_start.n_calls == 4
	assert after_start.n_event_calls == 2
}

fn test_rk23_event_evaluations_share_the_execution_budget() {
	endpoint_limited := solve_rk23(unit_rate_system, RK23Params{
		t_start:        0.0
		t_end:          1.0
		initial_state:  [0.0]
		initial_step:   1.0
		max_evals:      5
		event_function: event_at_four_tenths
	})!
	assert endpoint_limited.status == .max_evaluations
	assert endpoint_limited.t == 0.0
	assert endpoint_limited.n_calls == 4
	assert endpoint_limited.n_event_calls == 1
	assert endpoint_limited.n_accepted == 0

	localization_limited := solve_rk23(unit_rate_system, RK23Params{
		t_start:        0.0
		t_end:          1.0
		initial_state:  [0.0]
		initial_step:   1.0
		max_evals:      7
		event_function: event_at_four_tenths
	})!
	assert localization_limited.status == .max_evaluations
	assert localization_limited.t == 0.0
	assert localization_limited.n_calls == 4
	assert localization_limited.n_event_calls == 3
	assert localization_limited.n_accepted == 0
}

fn test_rk23_rejects_invalid_requested_output_times() {
	for output_times in [[0.8, 0.2], [1.1], [-0.1]] {
		solve_rk23(exponential_system, RK23Params{
			t_start:       0.0
			t_end:         1.0
			initial_state: [1.0]
			output_times:  output_times
		}) or {
			assert err.msg().contains('output times')
			continue
		}
		assert false, 'expected invalid output times to be rejected'
	}
	solve_rk23(exponential_system, RK23Params{
		t_start:       0.0
		t_end:         1.0
		initial_state: [1.0]
		output_times:  [math.nan()]
	}) or {
		assert err.msg().contains('output times')
		return
	}
	assert false, 'expected non-finite output times to be rejected'
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
