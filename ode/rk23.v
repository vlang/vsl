module ode

import math

// ODEFunction computes the derivative vector for the state at time t.
pub type ODEFunction = fn (t f64, state []f64, params []f64) []f64

// ODEEventFunction computes a scalar event value for the state at time t.
pub type ODEEventFunction = fn (t f64, state []f64, params []f64) f64

// RK23Status reports why the adaptive integrator stopped.
pub enum RK23Status {
	converged
	max_steps
	max_evaluations
	non_finite_function_value
	invalid_function_output
	precision_limit
	non_finite_estimate
	event_detected
	non_finite_event_value
}

// RK23Params configures an adaptive Bogacki-Shampine 3(2) initial-value solve.
@[params]
pub struct RK23Params {
pub:
	t_start         f64
	t_end           f64
	initial_state   []f64 @[required]
	function_params []f64
	output_times    []f64
	initial_step    f64
	max_step        f64
	abs_tol         f64 = 1e-9
	rel_tol         f64 = 1e-6
	max_steps       int = 100000
	max_evals       int = 400000
	event_function  ?ODEEventFunction
}

// RK23Result contains the last accepted state and adaptive-step diagnostics.
pub struct RK23Result {
pub:
	t              f64
	state          []f64
	sampled_times  []f64
	sampled_states [][]f64
	error_norm     f64
	n_calls        int
	n_event_calls  int
	n_steps        int
	n_accepted     int
	n_rejected     int
	status         RK23Status
}

struct EvaluationState {
mut:
	calls          int
	event_calls    int
	status         RK23Status
	limit          int
	direction      f64
	output_times   []f64
	output_index   int
	sampled_times  []f64
	sampled_states [][]f64
}

// solve_rk23 integrates y'=f(t,y) from t_start to t_end using adaptive
// Bogacki-Shampine 3(2) steps. It is intended for non-stiff systems.
pub fn solve_rk23(f ODEFunction, params RK23Params) !RK23Result {
	if !finite_value(params.t_start) || !finite_value(params.t_end)
		|| params.initial_state.len == 0 || !finite_value(params.initial_step)
		|| !finite_value(params.max_step) || !finite_value(params.abs_tol)
		|| !finite_value(params.rel_tol) || params.initial_step < 0.0 || params.max_step < 0.0
		|| params.abs_tol < 0.0 || params.rel_tol < 0.0
		|| (params.abs_tol == 0.0 && params.rel_tol == 0.0) || params.max_steps < 1
		|| params.max_evals < 1 {
		return error('invalid RK23 parameters')
	}
	for value in params.initial_state {
		if !finite_value(value) {
			return error('RK23 initial state must contain only finite values')
		}
	}
	for value in params.function_params {
		if !finite_value(value) {
			return error('RK23 function parameters must contain only finite values')
		}
	}
	direction := if params.t_start <= params.t_end { 1.0 } else { -1.0 }
	if !valid_output_times(params.output_times, params.t_start, params.t_end, direction) {
		return error('RK23 output times must be finite, ordered, and within the integration interval')
	}
	mut evaluation := EvaluationState{
		limit:        params.max_evals
		direction:    direction
		output_times: params.output_times.clone()
	}
	sample_initial_state(params.t_start, params.initial_state, mut evaluation)
	mut event_value := 0.0
	mut has_event := false
	if event_function := params.event_function {
		has_event = true
		event_value = evaluate_event(event_function, params.t_start, params.initial_state,
			params.function_params, mut evaluation)
		if evaluation.status != .converged {
			return rk23_result(params.t_start, params.initial_state, 0.0, evaluation, 0, 0,
				0, evaluation.status)
		}
		if event_value == 0.0 {
			return rk23_result(params.t_start, params.initial_state, 0.0, evaluation, 0, 0,
				0, .event_detected)
		}
	}
	if params.t_start == params.t_end {
		return rk23_result(params.t_end, params.initial_state, 0.0, evaluation, 0, 0, 0,
			.converged)
	}
	span := math.abs(params.t_end - params.t_start)
	if !finite_value(span) {
		return error('RK23 integration span must be finite')
	}
	mut state := params.initial_state.clone()
	mut t := params.t_start
	mut step_size := if params.initial_step > 0.0 {
		params.initial_step
	} else {
		span / 100.0
	}
	if params.max_step > 0.0 {
		step_size = math.min(step_size, params.max_step)
	}
	mut n_steps := 0
	mut n_accepted := 0
	mut n_rejected := 0
	mut last_error_norm := 0.0
	for t != params.t_end {
		if n_steps >= params.max_steps {
			return rk23_result(t, state, last_error_norm, evaluation, n_steps, n_accepted,
				n_rejected, .max_steps)
		}
		remaining := math.abs(params.t_end - t)
		step := direction * math.min(step_size, remaining)
		if step == 0.0 || t + step == t {
			return rk23_result(t, state, last_error_norm, evaluation, n_steps, n_accepted,
				n_rejected, .precision_limit)
		}
		reaches_end := step_size >= remaining
		n_steps++
		step_start := t
		step_start_state := if has_event || evaluation.output_index < evaluation.output_times.len {
			state.clone()
		} else {
			[]f64{}
		}
		k1 := evaluate(f, t, state, params.function_params, mut evaluation)
		if evaluation.status != .converged {
			return rk23_result(t, state, last_error_norm, evaluation, n_steps, n_accepted,
				n_rejected, evaluation.status)
		}
		mut stage2 := []f64{len: state.len}
		for i, value in state {
			stage2[i] = value + step * 0.5 * k1[i]
		}
		if !finite_state(stage2) {
			return rk23_result(t, state, last_error_norm, evaluation, n_steps, n_accepted,
				n_rejected, .non_finite_estimate)
		}
		k2 := evaluate(f, t + step * 0.5, stage2, params.function_params, mut evaluation)
		if evaluation.status != .converged {
			return rk23_result(t, state, last_error_norm, evaluation, n_steps, n_accepted,
				n_rejected, evaluation.status)
		}
		mut stage3 := []f64{len: state.len}
		for i, value in state {
			stage3[i] = value + step * 0.75 * k2[i]
		}
		if !finite_state(stage3) {
			return rk23_result(t, state, last_error_norm, evaluation, n_steps, n_accepted,
				n_rejected, .non_finite_estimate)
		}
		k3 := evaluate(f, t + step * 0.75, stage3, params.function_params, mut evaluation)
		if evaluation.status != .converged {
			return rk23_result(t, state, last_error_norm, evaluation, n_steps, n_accepted,
				n_rejected, evaluation.status)
		}
		mut candidate := []f64{len: state.len}
		for i, value in state {
			candidate[i] = value + step * (2.0 / 9.0 * k1[i] + 1.0 / 3.0 * k2[i] +
				4.0 / 9.0 * k3[i])
		}
		if !finite_state(candidate) {
			return rk23_result(t, state, last_error_norm, evaluation, n_steps, n_accepted,
				n_rejected, .non_finite_estimate)
		}
		k4 := evaluate(f, t + step, candidate, params.function_params, mut evaluation)
		if evaluation.status != .converged {
			return rk23_result(t, state, last_error_norm, evaluation, n_steps, n_accepted,
				n_rejected, evaluation.status)
		}
		last_error_norm = 0.0
		for i, value in state {
			lower_order := value + step * (7.0 / 24.0 * k1[i] + 1.0 / 4.0 * k2[i] +
				1.0 / 3.0 * k3[i] + 1.0 / 8.0 * k4[i])
			error_value := math.abs(candidate[i] - lower_order)
			scale := params.abs_tol + params.rel_tol * math.max(math.abs(value),
				math.abs(candidate[i]))
			component_error := if scale == 0.0 {
				if error_value == 0.0 { 0.0 } else { math.inf(1) }
			} else {
				error_value / scale
			}
			last_error_norm = math.max(last_error_norm, component_error)
		}
		if math.is_nan(last_error_norm) {
			return rk23_result(t, state, last_error_norm, evaluation, n_steps, n_accepted,
				n_rejected, .non_finite_estimate)
		}
		if last_error_norm <= 1.0 {
			step_end := if reaches_end { params.t_end } else { t + step }
			mut reached_event := false
			mut event_time := step_end
			mut event_state := candidate.clone()
			if event_function := params.event_function {
				next_event_value := evaluate_event(event_function, step_end, candidate,
					params.function_params, mut evaluation)
				if evaluation.status != .converged {
					return rk23_result(step_start, step_start_state, last_error_norm,
						evaluation, n_steps, n_accepted, n_rejected, evaluation.status)
				}
				if event_crossed(event_value, next_event_value) {
					location := localize_rk23_event(event_function, step_start,
						step_start_state, step_end, candidate, k1, k4, event_value,
						next_event_value, params.function_params, mut evaluation)
					if evaluation.status != .converged {
						return rk23_result(step_start, step_start_state, last_error_norm,
							evaluation, n_steps, n_accepted, n_rejected, evaluation.status)
					}
					event_time = location.t
					event_state = location.state
					reached_event = true
				} else {
					event_value = next_event_value
				}
			}
			sample_rk23_interval(step_start, step_start_state, step_end, candidate, k1, k4,
				if reached_event { event_time } else { step_end }, mut evaluation)
			if evaluation.status != .converged {
				return rk23_result(step_start, step_start_state, last_error_norm, evaluation,
					n_steps, n_accepted, n_rejected, evaluation.status)
			}
			if reached_event {
				n_accepted++
				return rk23_result(event_time, event_state, last_error_norm, evaluation,
					n_steps, n_accepted, n_rejected, .event_detected)
			}
			state = candidate.clone()
			t = step_end
			n_accepted++
			if t == params.t_end {
				return rk23_result(t, state, last_error_norm, evaluation, n_steps, n_accepted,
					n_rejected, .converged)
			}
			step_size = adjusted_step_size(step_size, last_error_norm, true, params.max_step,
				span)
		} else {
			n_rejected++
			step_size = adjusted_step_size(step_size, last_error_norm, false, params.max_step,
				span)
		}
		if step_size == 0.0 || !finite_value(step_size) {
			return rk23_result(t, state, last_error_norm, evaluation, n_steps, n_accepted,
				n_rejected, .precision_limit)
		}
	}
	return rk23_result(t, state, last_error_norm, evaluation, n_steps, n_accepted,
		n_rejected, .converged)
}

fn valid_output_times(times []f64, start f64, end f64, direction f64) bool {
	mut previous := start
	for index, value in times {
		if !finite_value(value) || value < math.min(start, end) || value > math.max(start, end) {
			return false
		}
		if index > 0 && ((direction > 0.0 && value < previous)
			|| (direction < 0.0 && value > previous)) {
			return false
		}
		previous = value
	}
	return true
}

fn sample_initial_state(t f64, state []f64, mut evaluation EvaluationState) {
	for evaluation.output_index < evaluation.output_times.len
		&& evaluation.output_times[evaluation.output_index] == t {
		evaluation.sampled_times << t
		evaluation.sampled_states << state.clone()
		evaluation.output_index++
	}
}

fn sample_rk23_interval(start f64, start_state []f64, end f64, end_state []f64, start_derivative []f64, end_derivative []f64, sample_end f64, mut evaluation EvaluationState) {
	mut output_index := evaluation.output_index
	mut step_sample_times := []f64{}
	mut step_sample_states := [][]f64{}
	for output_index < evaluation.output_times.len {
		sample_time := evaluation.output_times[output_index]
		if (evaluation.direction > 0.0 && sample_time > sample_end)
			|| (evaluation.direction < 0.0 && sample_time < sample_end) {
			break
		}
		sampled_state := interpolate_rk23_state(start, start_state, end, end_state,
			start_derivative, end_derivative, sample_time)
		if !finite_state(sampled_state) {
			evaluation.status = .non_finite_estimate
			return
		}
		step_sample_times << sample_time
		step_sample_states << sampled_state
		output_index++
	}
	for sample_time in step_sample_times {
		evaluation.sampled_times << sample_time
	}
	for sampled_state in step_sample_states {
		evaluation.sampled_states << sampled_state
	}
	evaluation.output_index = output_index
}

fn evaluate(f ODEFunction, t f64, state []f64, params []f64, mut evaluation EvaluationState) []f64 {
	if evaluation.calls + evaluation.event_calls >= evaluation.limit {
		evaluation.status = .max_evaluations
		return []f64{}
	}
	values := f(t, state, params)
	evaluation.calls++
	if values.len != state.len {
		evaluation.status = .invalid_function_output
		return []f64{}
	}
	for value in values {
		if !finite_value(value) {
			evaluation.status = .non_finite_function_value
			return []f64{}
		}
	}
	return values
}

fn evaluate_event(f ODEEventFunction, t f64, state []f64, params []f64, mut evaluation EvaluationState) f64 {
	if evaluation.calls + evaluation.event_calls >= evaluation.limit {
		evaluation.status = .max_evaluations
		return 0.0
	}
	value := f(t, state.clone(), params)
	evaluation.event_calls++
	if !finite_value(value) {
		evaluation.status = .non_finite_event_value
	}
	return value
}

fn event_crossed(start_value f64, end_value f64) bool {
	return (start_value < 0.0 && end_value >= 0.0) || (start_value > 0.0 && end_value <= 0.0)
}

struct EventLocation {
	t     f64
	state []f64
}

fn localize_rk23_event(f ODEEventFunction, start f64, start_state []f64, end f64, end_state []f64, start_derivative []f64, end_derivative []f64, start_value f64, end_value f64, params []f64, mut evaluation EvaluationState) EventLocation {
	if end_value == 0.0 {
		return EventLocation{
			t:     end
			state: end_state.clone()
		}
	}
	mut left := start
	mut right := end
	mut left_value := start_value
	mut right_value := end_value
	for {
		midpoint := left + (right - left) * 0.5
		if midpoint == left || midpoint == right {
			break
		}
		midpoint_state := interpolate_rk23_state(start, start_state, end, end_state,
			start_derivative, end_derivative, midpoint)
		if !finite_state(midpoint_state) {
			evaluation.status = .non_finite_estimate
			return EventLocation{
				t:     midpoint
				state: midpoint_state
			}
		}
		midpoint_value := evaluate_event(f, midpoint, midpoint_state, params, mut evaluation)
		if evaluation.status != .converged || midpoint_value == 0.0 {
			return EventLocation{
				t:     midpoint
				state: midpoint_state
			}
		}
		if (left_value < 0.0 && midpoint_value < 0.0)
			|| (left_value > 0.0 && midpoint_value > 0.0) {
			left = midpoint
			left_value = midpoint_value
		} else {
			right = midpoint
			right_value = midpoint_value
		}
	}
	if math.abs(left_value) <= math.abs(right_value) {
		return EventLocation{
			t:     left
			state: interpolate_rk23_state(start, start_state, end, end_state,
				start_derivative, end_derivative, left)
		}
	}
	return EventLocation{
		t:     right
		state: interpolate_rk23_state(start, start_state, end, end_state, start_derivative,
			end_derivative, right)
	}
}

fn interpolate_rk23_state(start f64, start_state []f64, end f64, end_state []f64, start_derivative []f64, end_derivative []f64, t f64) []f64 {
	if t == start {
		return start_state.clone()
	}
	if t == end {
		return end_state.clone()
	}
	h := end - start
	s := (t - start) / h
	s2 := s * s
	s3 := s2 * s
	h00 := 2.0 * s3 - 3.0 * s2 + 1.0
	h10 := s3 - 2.0 * s2 + s
	h01 := -2.0 * s3 + 3.0 * s2
	h11 := s3 - s2
	mut sampled_state := []f64{len: start_state.len}
	for i in 0 .. start_state.len {
		sampled_state[i] = h00 * start_state[i] + h10 * h * start_derivative[i] +
			h01 * end_state[i] + h11 * h * end_derivative[i]
	}
	return sampled_state
}

fn step_factor(error_norm f64, accepted bool) f64 {
	if error_norm == 0.0 {
		return 5.0
	}
	factor := 0.9 * math.pow(1.0 / error_norm, 1.0 / 3.0)
	if accepted {
		return math.min(5.0, math.max(0.2, factor))
	}
	return math.min(0.5, math.max(0.1, factor))
}

fn adjusted_step_size(step_size f64, error_norm f64, accepted bool, max_step f64, span f64) f64 {
	mut next := step_size * step_factor(error_norm, accepted)
	if !finite_value(next) {
		next = span
	}
	next = math.min(next, span)
	if max_step > 0.0 {
		next = math.min(next, max_step)
	}
	return next
}

fn finite_state(state []f64) bool {
	for value in state {
		if !finite_value(value) {
			return false
		}
	}
	return true
}

fn finite_value(value f64) bool {
	return !math.is_nan(value) && !math.is_inf(value, 0)
}

fn rk23_result(t f64, state []f64, error_norm f64, evaluation EvaluationState, n_steps int, n_accepted int, n_rejected int, status RK23Status) RK23Result {
	return RK23Result{
		t:              t
		state:          state.clone()
		sampled_times:  evaluation.sampled_times.clone()
		sampled_states: evaluation.sampled_states.clone()
		error_norm:     error_norm
		n_calls:        evaluation.calls
		n_event_calls:  evaluation.event_calls
		n_steps:        n_steps
		n_accepted:     n_accepted
		n_rejected:     n_rejected
		status:         status
	}
}
