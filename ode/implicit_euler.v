module ode

import math

// ImplicitEulerStatus reports why the stiff integrator stopped.
pub enum ImplicitEulerStatus {
	converged
	max_steps
	max_evaluations
	newton_failed
	non_finite_function_value
	invalid_function_output
	non_finite_estimate
	precision_limit
}

// ImplicitEulerParams configures an adaptive implicit-Euler solve. The method
// is A-stable and intended for stiff systems; it is first order, so it needs
// smaller steps than RK23 for the same accuracy on non-stiff problems.
@[params]
pub struct ImplicitEulerParams {
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
	newton_max_iter int = 20
	newton_tol      f64 = 1e-10
}

// ImplicitEulerResult contains the last accepted state and step diagnostics.
pub struct ImplicitEulerResult {
pub:
	t          f64
	state      []f64
	error_norm f64
	n_calls    int
	n_newton   int
	n_steps    int
	n_accepted int
	n_rejected int
	status     ImplicitEulerStatus
}

struct StiffEvaluation {
mut:
	calls  int
	status ImplicitEulerStatus
	limit  int
}

fn stiff_evaluate(f ODEFunction, t f64, state []f64, params []f64, mut eval StiffEvaluation) []f64 {
	if eval.calls >= eval.limit {
		eval.status = .max_evaluations
		return []
	}
	eval.calls++
	value := f(t, state.clone(), params.clone())
	if value.len != state.len {
		eval.status = .invalid_function_output
		return []
	}
	for item in value {
		if !finite_value(item) {
			eval.status = .non_finite_function_value
			return []
		}
	}
	return value
}

fn solve_small_linear(matrix [][]f64, rhs []f64) ![]f64 {
	n := rhs.len
	mut a := matrix.clone()
	mut b := rhs.clone()
	for column in 0 .. n {
		mut pivot := column
		for row in column + 1 .. n {
			if math.abs(a[row][column]) > math.abs(a[pivot][column]) {
				pivot = row
			}
		}
		if math.abs(a[pivot][column]) < 1e-280 {
			return error('implicit Newton system is singular')
		}
		if pivot != column {
			tmp_row := a[pivot]
			a[pivot] = a[column]
			a[column] = tmp_row
			tmp_value := b[pivot]
			b[pivot] = b[column]
			b[column] = tmp_value
		}
		for row in column + 1 .. n {
			factor := a[row][column] / a[column][column]
			a[row][column] = 0.0
			for j in column + 1 .. n {
				a[row][j] -= factor * a[column][j]
			}
			b[row] -= factor * b[column]
		}
	}
	mut solution := []f64{len: n}
	for i := n - 1; i >= 0; i-- {
		mut total := b[i]
		for j in i + 1 .. n {
			total -= a[i][j] * solution[j]
		}
		solution[i] = total / a[i][i]
	}
	return solution
}

fn implicit_step(f ODEFunction, t f64, initial []f64, step f64, params ImplicitEulerParams, mut eval StiffEvaluation) ![]f64 {
	n := initial.len
	mut candidate := initial.clone()
	target := t + step
	for _ in 0 .. params.newton_max_iter {
		derivative := stiff_evaluate(f, target, candidate, params.function_params, mut eval)
		if eval.status != .converged {
			return error('derivative evaluation failed in implicit step')
		}
		mut jacobian := [][]f64{len: n, init: []f64{len: n}}
		for j in 0 .. n {
			jacobian[j][j] = 1.0
		}
		for column in 0 .. n {
			perturbation := 1.4901161193847656e-8 * math.max(1.0, math.abs(candidate[column]))
			mut shifted := candidate.clone()
			shifted[column] += perturbation
			perturbed := stiff_evaluate(f, target, shifted, params.function_params, mut eval)
			if eval.status != .converged {
				return error('derivative evaluation failed in Jacobian')
			}
			for row in 0 .. n {
				jacobian[row][column] -= step * (perturbed[row] - derivative[row]) / perturbation
			}
		}
		mut residual := []f64{len: n}
		for i in 0 .. n {
			residual[i] = candidate[i] - initial[i] - step * derivative[i]
		}
		mut negated := []f64{len: n}
		for i in 0 .. n {
			negated[i] = -residual[i]
		}
		delta := solve_small_linear(jacobian, negated) or {
			return err
		}
		for i in 0 .. n {
			candidate[i] += delta[i]
		}
		if !finite_state(candidate) {
			return error('implicit Newton iterate is not finite')
		}
		mut largest := 0.0
		for i in 0 .. n {
			scale := math.max(1.0, math.abs(candidate[i]))
			largest = math.max(largest, math.abs(delta[i]) / scale)
		}
		eval.calls++
		if largest <= params.newton_tol {
			return candidate
		}
	}
	eval.status = .newton_failed
	return error('implicit Newton iteration did not converge')
}

fn implicit_error_norm(coarse []f64, fine []f64, params ImplicitEulerParams) f64 {
	mut largest := 0.0
	for i in 0 .. coarse.len {
		scale := params.abs_tol + params.rel_tol * math.max(math.abs(coarse[i]), math.abs(fine[i]))
		largest = math.max(largest, 2.0 * math.abs(fine[i] - coarse[i]) / scale)
	}
	return largest
}

fn implicit_next_step(step f64, error_norm f64, max_step f64, remaining f64) f64 {
	mut factor := 0.9
	if error_norm > 0.0 {
		factor *= math.pow(error_norm, -0.5)
	}
	if factor < 0.2 {
		factor = 0.2
	}
	if factor > 5.0 {
		factor = 5.0
	}
	return math.min(math.min(max_step, remaining), step * factor)
}

fn implicit_result(t f64, state []f64, error_norm f64, eval StiffEvaluation, n_steps int, n_accepted int, n_rejected int, status ImplicitEulerStatus) ImplicitEulerResult {
	return ImplicitEulerResult{
		t:          t
		state:      state
		error_norm: error_norm
		n_calls:    eval.calls
		n_steps:    n_steps
		n_accepted: n_accepted
		n_rejected: n_rejected
		status:     status
	}
}

// solve_implicit_euler integrates y' = f(t, y) using adaptive implicit Euler
// with step doubling. It is A-stable and suitable for stiff systems, where
// RK23 would be forced to take very small steps.
pub fn solve_implicit_euler(f ODEFunction, params ImplicitEulerParams) !ImplicitEulerResult {
	if !finite_value(params.t_start) || !finite_value(params.t_end)
		|| params.initial_state.len == 0 || !finite_value(params.initial_step)
		|| !finite_value(params.max_step) || !finite_value(params.abs_tol)
		|| !finite_value(params.rel_tol) || params.initial_step <= 0.0 || params.max_step <= 0.0
		|| params.abs_tol < 0.0 || params.rel_tol < 0.0
		|| (params.abs_tol == 0.0 && params.rel_tol == 0.0)
		|| params.max_steps < 1 || params.max_evals < 1 || params.newton_max_iter < 1
		|| !finite_value(params.newton_tol) || params.newton_tol <= 0.0 {
		return error('invalid implicit Euler parameters')
	}
	for value in params.initial_state {
		if !finite_value(value) {
			return error('implicit Euler initial state must contain only finite values')
		}
	}
	for value in params.function_params {
		if !finite_value(value) {
			return error('implicit Euler function parameters must contain only finite values')
		}
	}

	direction := if params.t_start <= params.t_end { 1.0 } else { -1.0 }
	span := math.abs(params.t_end - params.t_start)
	mut eval := StiffEvaluation{ limit: params.max_evals }
	mut t := params.t_start
	mut state := params.initial_state.clone()
	if params.t_start == params.t_end {
		return implicit_result(t, state, 0.0, eval, 0, 0, 0, .converged)
	}

	mut step := math.min(math.min(params.initial_step, params.max_step), span)
	mut n_steps := 0
	mut n_accepted := 0
	mut n_rejected := 0
	mut error_norm := 0.0
	for n_steps < params.max_steps {
		remaining := math.abs(params.t_end - t)
		if remaining <= 0.0 {
			break
		}
		signed_step := direction * math.min(step, remaining)
		if t + signed_step == t {
			return implicit_result(t, state, error_norm, eval, n_steps, n_accepted,
				n_rejected, .precision_limit)
		}
		n_steps++

		coarse := implicit_step(f, t, state, signed_step, params, mut eval) or {
			status := if eval.status == .converged { .newton_failed } else { eval.status }
			return implicit_result(t, state, error_norm, eval, n_steps, n_accepted,
				n_rejected, status)
		}
		half_step := signed_step * 0.5
		mid := implicit_step(f, t, state, half_step, params, mut eval) or {
			status := if eval.status == .converged { .newton_failed } else { eval.status }
			return implicit_result(t, state, error_norm, eval, n_steps, n_accepted,
				n_rejected, status)
		}
		fine := implicit_step(f, t + half_step, mid, half_step, params, mut eval) or {
			status := if eval.status == .converged { .newton_failed } else { eval.status }
			return implicit_result(t, state, error_norm, eval, n_steps, n_accepted,
				n_rejected, status)
		}
		error_norm = implicit_error_norm(coarse, fine, params)
		if !finite_value(error_norm) {
			return implicit_result(t, state, error_norm, eval, n_steps, n_accepted,
				n_rejected, .non_finite_estimate)
		}
		if eval.status != .converged {
			return implicit_result(t, state, error_norm, eval, n_steps, n_accepted,
				n_rejected, eval.status)
		}
		if error_norm <= 1.0 {
			t += signed_step
			state = fine.clone()
			n_accepted++
		} else {
			n_rejected++
		}
		step = implicit_next_step(step, error_norm, params.max_step,
			math.abs(params.t_end - t))
	}
	mut status := ImplicitEulerStatus.max_steps
	if math.abs(params.t_end - t) <= 1e-13 {
		status = .converged
	}
	return implicit_result(t, state, error_norm, eval, n_steps, n_accepted, n_rejected, status)
}
