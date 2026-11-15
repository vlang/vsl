module roots

import math
import vsl.errors
import vsl.func

// MultivariateGradientFn evaluates the gradient of an FnND objective.
pub type MultivariateGradientFn = fn (x []f64, params []f64) []f64

// BFGSStatus reports why the optimizer stopped.
pub enum BFGSStatus {
	converged
	max_iterations
	max_evaluations
	line_search_failed
	non_finite_function_value
	invalid_gradient
	precision_limit
}

// BFGSParams configures inverse-Hessian BFGS minimization.
@[params]
pub struct BFGSParams {
pub:
	x0             []f64
	gradient_tol   f64 = 1e-6
	initial_step   f64 = 1.0
	n_max          int = 200
	max_evals      int = 1000
	max_linesearch int = 25
}

// BFGSResult contains the best accepted point and convergence diagnostics.
pub struct BFGSResult {
pub:
	x             []f64
	fx            f64
	gradient_norm f64
	n_calls       int
	n_grad_calls  int
	n_iter        int
	status        BFGSStatus
}

// BFGS minimizes a differentiable scalar objective over an n-dimensional input.
pub struct BFGS {
pub:
	f        func.FnND              @[required]
	gradient MultivariateGradientFn @[required]
pub mut:
	x0             []f64
	gradient_tol   f64
	initial_step   f64
	n_max          int
	max_evals      int
	max_linesearch int
	n_calls        int
	n_grad_calls   int
	n_iter         int
mut:
	gradient_params []f64
}

// BFGS.new creates an optimizer with default tolerances and limits.
// Set x0 before calling solve, or use new_with_params.
pub fn BFGS.new(f func.FnND, gradient MultivariateGradientFn) &BFGS {
	return BFGS.new_with_params(f, gradient, BFGSParams{})
}

// BFGS.new_with_params creates a configured optimizer.
pub fn BFGS.new_with_params(f func.FnND, gradient MultivariateGradientFn, params BFGSParams) &BFGS {
	return &BFGS{
		f:               f
		gradient:        gradient
		gradient_params: f.parameters()
		x0:              params.x0.clone()
		gradient_tol:    params.gradient_tol
		initial_step:    params.initial_step
		n_max:           params.n_max
		max_evals:       params.max_evals
		max_linesearch:  params.max_linesearch
	}
}

fn bfgs_finite(value f64) bool {
	return !math.is_nan(value) && !math.is_inf(value, 0)
}

fn bfgs_finite_vector(values []f64) bool {
	for value in values {
		if !bfgs_finite(value) {
			return false
		}
	}
	return true
}

fn bfgs_dot(a []f64, b []f64) f64 {
	mut value := 0.0
	for i in 0 .. a.len {
		value += a[i] * b[i]
	}
	return value
}

fn bfgs_norm(values []f64) f64 {
	mut scale := 0.0
	mut sum_squares := 1.0
	for value in values {
		absolute := math.abs(value)
		if absolute == 0.0 {
			continue
		}
		if scale < absolute {
			sum_squares = 1.0 + sum_squares * math.pow(scale / absolute, 2.0)
			scale = absolute
		} else {
			sum_squares += math.pow(absolute / scale, 2.0)
		}
	}
	if scale == 0.0 {
		return 0.0
	}
	return scale * math.sqrt(sum_squares)
}

fn bfgs_identity(dimensions int) [][]f64 {
	mut matrix := [][]f64{len: dimensions, init: []f64{len: dimensions, init: 0.0}}
	for i in 0 .. dimensions {
		matrix[i][i] = 1.0
	}
	return matrix
}

fn bfgs_mat_vec(matrix [][]f64, vector []f64) []f64 {
	mut result := []f64{len: vector.len, init: 0.0}
	for i in 0 .. vector.len {
		result[i] = bfgs_dot(matrix[i], vector)
	}
	return result
}

fn bfgs_add_scaled(x []f64, direction []f64, step f64) []f64 {
	mut result := []f64{len: x.len, init: 0.0}
	for i in 0 .. x.len {
		result[i] = x[i] + step * direction[i]
	}
	return result
}

fn (mut solver BFGS) evaluate(x []f64) !f64 {
	value := solver.f.safe_eval(x) or {
		solver.n_calls++
		return err
	}
	solver.n_calls++
	return value
}

fn (mut solver BFGS) evaluate_gradient(x []f64) ([]f64, f64, bool) {
	gradient := solver.gradient(x, solver.gradient_params.clone())
	solver.n_grad_calls++
	if gradient.len != x.len || !bfgs_finite_vector(gradient) {
		return []f64{}, math.inf(1), false
	}
	norm := bfgs_norm(gradient)
	if !bfgs_finite(norm) {
		return []f64{}, math.inf(1), false
	}
	return gradient, norm, true
}

fn (solver BFGS) result(x []f64, fx f64, gradient_norm f64, status BFGSStatus) BFGSResult {
	return BFGSResult{
		x:             x.clone()
		fx:            fx
		gradient_norm: gradient_norm
		n_calls:       solver.n_calls
		n_grad_calls:  solver.n_grad_calls
		n_iter:        solver.n_iter
		status:        status
	}
}

fn bfgs_update_inverse(mut inverse_hessian [][]f64, s []f64, y []f64) {
	ys := bfgs_dot(y, s)
	if !bfgs_finite(ys) || ys <= 0.0 {
		inverse_hessian = bfgs_identity(s.len).clone()
		return
	}
	norm_product := bfgs_norm(s) * bfgs_norm(y)
	if !bfgs_finite(norm_product) || ys <= 1e-12 * norm_product {
		return
	}
	rho := 1.0 / ys
	hy := bfgs_mat_vec(inverse_hessian, y)
	yhy := bfgs_dot(y, hy)
	coefficient := (1.0 + rho * yhy) * rho
	mut updated := [][]f64{len: s.len, init: []f64{len: s.len, init: 0.0}}
	for i in 0 .. s.len {
		for j in 0 .. s.len {
			value := inverse_hessian[i][j] + coefficient * s[i] * s[j] -
				rho * (hy[i] * s[j] + s[i] * hy[j])
			if !bfgs_finite(value) {
				inverse_hessian = bfgs_identity(s.len).clone()
				return
			}
			updated[i][j] = value
		}
	}
	inverse_hessian = updated.clone()
}

// solve minimizes the objective with inverse-Hessian BFGS and an Armijo
// backtracking line search. Invalid parameters return errors; callback
// failures and execution limits are reported in the result.
pub fn (mut solver BFGS) solve() !BFGSResult {
	solver.n_calls = 0
	solver.n_grad_calls = 0
	solver.n_iter = 0
	dimensions := solver.x0.len
	if dimensions == 0 || !bfgs_finite(solver.gradient_tol) || solver.gradient_tol <= 0.0
		|| !bfgs_finite(solver.initial_step) || solver.initial_step <= 0.0 || solver.n_max <= 0
		|| solver.max_evals < 1 || solver.max_linesearch <= 0 {
		return errors.error('invalid BFGS parameters', .einval)
	}
	if !bfgs_finite_vector(solver.x0) {
		return errors.error('BFGS initial point must be finite', .einval)
	}

	mut x := solver.x0.clone()
	mut fx := solver.evaluate(x) or {
		return solver.result(x, math.nan(), math.inf(1), .non_finite_function_value)
	}
	mut gradient, mut gradient_norm, valid_gradient := solver.evaluate_gradient(x)
	if !valid_gradient {
		return solver.result(x, fx, math.inf(1), .invalid_gradient)
	}
	if gradient_norm <= solver.gradient_tol {
		return solver.result(x, fx, gradient_norm, .converged)
	}

	mut inverse_hessian := bfgs_identity(dimensions)
	for solver.n_iter < solver.n_max {
		direction := bfgs_mat_vec(inverse_hessian, gradient)
		mut search_direction := []f64{len: dimensions, init: 0.0}
		for i in 0 .. dimensions {
			search_direction[i] = -direction[i]
		}
		mut directional_derivative := bfgs_dot(gradient, search_direction)
		if !bfgs_finite_vector(search_direction) || !bfgs_finite(directional_derivative)
			|| directional_derivative >= 0.0 {
			inverse_hessian = bfgs_identity(dimensions).clone()
			for i in 0 .. dimensions {
				search_direction[i] = -gradient[i]
			}
			directional_derivative = -bfgs_dot(gradient, gradient)
		}
		if !bfgs_finite(directional_derivative) || directional_derivative >= 0.0 {
			return solver.result(x, fx, gradient_norm, .precision_limit)
		}

		mut accepted := false
		mut saw_no_progress := false
		mut trial_evaluations := 0
		mut x_next := []f64{}
		mut fx_next := fx
		mut step := solver.initial_step
		for _ in 0 .. solver.max_linesearch {
			if solver.n_calls >= solver.max_evals {
				return solver.result(x, fx, gradient_norm, .max_evaluations)
			}
			candidate := bfgs_add_scaled(x, search_direction, step)
			if !bfgs_finite_vector(candidate) {
				step *= 0.5
				continue
			}
			if candidate == x {
				saw_no_progress = true
				step *= 0.5
				continue
			}
			candidate_value := solver.evaluate(candidate) or {
				trial_evaluations++
				step *= 0.5
				continue
			}
			trial_evaluations++
			if candidate_value < fx && candidate_value <= fx + 1e-4 * step * directional_derivative {
				accepted = true
				x_next = candidate.clone()
				fx_next = candidate_value
				break
			}
			step *= 0.5
		}
		if !accepted {
			mut status := BFGSStatus.line_search_failed
			if solver.n_calls >= solver.max_evals {
				status = .max_evaluations
			} else if saw_no_progress && trial_evaluations == 0 {
				status = .precision_limit
			}
			return solver.result(x, fx, gradient_norm, status)
		}
		mut gradient_next, mut gradient_norm_next, valid_gradient_next := solver.evaluate_gradient(x_next)
		if !valid_gradient_next {
			return solver.result(x_next, fx_next, math.inf(1), .invalid_gradient)
		}

		mut s := []f64{len: dimensions, init: 0.0}
		mut y := []f64{len: dimensions, init: 0.0}
		for i in 0 .. dimensions {
			s[i] = x_next[i] - x[i]
			y[i] = gradient_next[i] - gradient[i]
		}
		bfgs_update_inverse(mut inverse_hessian, s, y)
		x = x_next.clone()
		fx = fx_next
		gradient = gradient_next.clone()
		gradient_norm = gradient_norm_next
		solver.n_iter++
		if gradient_norm <= solver.gradient_tol {
			return solver.result(x, fx, gradient_norm, .converged)
		}
	}
	return solver.result(x, fx, gradient_norm, .max_iterations)
}
