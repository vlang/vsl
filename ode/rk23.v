module ode

import math

// ODEFunction computes the derivative vector for the state at time t.
pub type ODEFunction = fn (t f64, state []f64, params []f64) []f64

// RK23Status reports why the adaptive integrator stopped.
pub enum RK23Status {
	converged
	max_steps
	max_evaluations
	non_finite_function_value
	invalid_function_output
	precision_limit
	non_finite_estimate
}

// RK23Params configures an adaptive Bogacki-Shampine 3(2) initial-value solve.
@[params]
pub struct RK23Params {
pub:
	t_start         f64
	t_end           f64
	initial_state   []f64 @[required]
	function_params []f64
	initial_step    f64
	max_step        f64
	abs_tol         f64 = 1e-9
	rel_tol         f64 = 1e-6
	max_steps       int = 100000
	max_evals       int = 400000
}

// RK23Result contains the last accepted state and adaptive-step diagnostics.
pub struct RK23Result {
pub:
	t          f64
	state      []f64
	error_norm f64
	n_calls    int
	n_steps    int
	n_accepted int
	n_rejected int
	status     RK23Status
}

struct EvaluationState {
mut:
	calls  int
	status RK23Status
	limit  int
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
	if params.t_start == params.t_end {
		return RK23Result{
			t:      params.t_end
			state:  params.initial_state.clone()
			status: .converged
		}
	}
	span := math.abs(params.t_end - params.t_start)
	if !finite_value(span) {
		return error('RK23 integration span must be finite')
	}
	direction := if params.t_start < params.t_end { 1.0 } else { -1.0 }
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
	mut evaluation := EvaluationState{
		limit: params.max_evals
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
			state = candidate.clone()
			t = if reaches_end { params.t_end } else { t + step }
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

fn evaluate(f ODEFunction, t f64, state []f64, params []f64, mut evaluation EvaluationState) []f64 {
	if evaluation.calls >= evaluation.limit {
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
		t:          t
		state:      state.clone()
		error_norm: error_norm
		n_calls:    evaluation.calls
		n_steps:    n_steps
		n_accepted: n_accepted
		n_rejected: n_rejected
		status:     status
	}
}
