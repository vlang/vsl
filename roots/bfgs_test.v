module roots

import math
import vsl.func

fn bfgs_test_quadratic(x []f64, params []f64) f64 {
	mut value := 0.0
	for i, coordinate in x {
		delta := coordinate - params[i]
		value += params[i + x.len] * delta * delta
	}
	return value
}

fn bfgs_test_quadratic_gradient(x []f64, params []f64) []f64 {
	mut gradient := []f64{len: x.len, init: 0.0}
	for i, coordinate in x {
		gradient[i] = 2.0 * params[i + x.len] * (coordinate - params[i])
	}
	return gradient
}

fn bfgs_test_rosenbrock(x []f64, _ []f64) f64 {
	a := 1.0 - x[0]
	b := x[1] - x[0] * x[0]
	return a * a + 100.0 * b * b
}

fn bfgs_test_rosenbrock_gradient(x []f64, _ []f64) []f64 {
	b := x[1] - x[0] * x[0]
	return [2.0 * (x[0] - 1.0) - 400.0 * x[0] * b, 200.0 * b]
}

fn bfgs_test_flat(_ []f64, _ []f64) f64 {
	return 0.0
}

fn bfgs_test_bounded_quadratic(x []f64, _ []f64) f64 {
	if x[0] < -0.75 {
		return math.nan()
	}
	delta := x[0] + 0.5
	return delta * delta
}

fn bfgs_test_bounded_quadratic_gradient(x []f64, _ []f64) []f64 {
	return [2.0 * (x[0] + 0.5)]
}

fn bfgs_test_non_finite(_ []f64, _ []f64) f64 {
	return math.nan()
}

fn bfgs_test_constant_gradient(_ []f64, _ []f64) []f64 {
	return [1.0]
}

fn bfgs_test_bad_gradient(_ []f64, _ []f64) []f64 {
	return [math.nan()]
}

fn bfgs_test_wrong_size_gradient(_ []f64, _ []f64) []f64 {
	return [1.0]
}

fn test_bfgs_minimizes_parameterized_quadratic() {
	params := [2.0, -1.0, 0.5, 1.0, 10.0, 100.0]
	objective := func.FnND.new_with_params(bfgs_test_quadratic, params)
	mut optimizer := BFGS.new_with_params(objective, bfgs_test_quadratic_gradient, BFGSParams{
		x0:           [0.0, 0.0, 0.0]
		gradient_tol: 1e-8
		n_max:        500
		max_evals:    2000
	})
	result := optimizer.solve()!
	assert result.status == .converged
	assert math.abs(result.x[0] - 2.0) <= 1e-7
	assert math.abs(result.x[1] + 1.0) <= 1e-7
	assert math.abs(result.x[2] - 0.5) <= 1e-7
	assert result.fx <= 1e-14
	assert result.gradient_norm <= optimizer.gradient_tol
	assert result.n_calls == optimizer.n_calls
	assert result.n_grad_calls == optimizer.n_grad_calls
	assert result.n_iter == optimizer.n_iter
	assert result.n_grad_calls == result.n_iter + 1

	mut at_minimum := BFGS.new_with_params(objective, bfgs_test_quadratic_gradient,
		BFGSParams{
			x0: [2.0, -1.0, 0.5]
		})
	minimum_result := at_minimum.solve()!
	assert minimum_result.status == .converged
	assert minimum_result.n_iter == 0
	assert minimum_result.n_calls == 1
	assert minimum_result.gradient_norm == 0.0
}

fn test_bfgs_converges_on_rosenbrock() {
	objective := func.FnND.new(bfgs_test_rosenbrock)
	mut optimizer := BFGS.new_with_params(objective, bfgs_test_rosenbrock_gradient,
		BFGSParams{
			x0:             [-1.2, 1.0]
			gradient_tol:   1e-6
			n_max:          1000
			max_evals:      5000
			max_linesearch: 40
		})
	result := optimizer.solve()!
	assert result.status == .converged
	assert math.abs(result.x[0] - 1.0) <= 1e-5
	assert math.abs(result.x[1] - 1.0) <= 1e-5
	assert result.fx <= 1e-10
}

fn test_bfgs_reports_execution_limits_and_line_search_failure() {
	objective := func.FnND.new_with_params(bfgs_test_quadratic,
		[2.0, -1.0, 0.5, 1.0, 10.0, 100.0])
	mut evaluation_limited := BFGS.new_with_params(objective,
		bfgs_test_quadratic_gradient, BFGSParams{
			x0:        [0.0, 0.0, 0.0]
			max_evals: 1
		})
	evaluation_result := evaluation_limited.solve()!
	assert evaluation_result.status == .max_evaluations
	assert evaluation_result.n_calls == 1

	rosenbrock := func.FnND.new(bfgs_test_rosenbrock)
	mut iteration_limited := BFGS.new_with_params(rosenbrock, bfgs_test_rosenbrock_gradient,
		BFGSParams{
			x0:    [-1.2, 1.0]
			n_max: 1
		})
	iteration_result := iteration_limited.solve()!
	assert iteration_result.status == .max_iterations
	assert iteration_result.n_iter == 1

	flat_objective := func.FnND.new(bfgs_test_flat)
	mut line_search_limited := BFGS.new_with_params(flat_objective,
		bfgs_test_constant_gradient, BFGSParams{
			x0: [0.0]
		})
	line_search_result := line_search_limited.solve()!
	assert line_search_result.status == .line_search_failed
	assert line_search_result.x == [0.0]
	assert line_search_result.n_iter == 0
}

fn test_bfgs_reports_non_finite_objective_and_invalid_gradient() {
	non_finite := func.FnND.new(bfgs_test_non_finite)
	mut objective_limited := BFGS.new_with_params(non_finite, bfgs_test_constant_gradient,
		BFGSParams{
			x0: [0.0]
		})
	objective_result := objective_limited.solve()!
	assert objective_result.status == .non_finite_function_value
	assert objective_result.n_calls == 1
	assert math.is_nan(objective_result.fx)

	objective := func.FnND.new(bfgs_test_flat)
	mut gradient_limited := BFGS.new_with_params(objective, bfgs_test_bad_gradient,
		BFGSParams{
			x0: [0.0]
		})
	gradient_result := gradient_limited.solve()!
	assert gradient_result.status == .invalid_gradient
	assert gradient_result.n_calls == 1
	assert gradient_result.n_grad_calls == 1

	mut wrong_size := BFGS.new_with_params(objective, bfgs_test_wrong_size_gradient,
		BFGSParams{
			x0: [0.0, 0.0]
		})
	wrong_size_result := wrong_size.solve()!
	assert wrong_size_result.status == .invalid_gradient
	assert wrong_size_result.n_grad_calls == 1
}

fn test_bfgs_detects_floating_point_step_limit() {
	objective := func.FnND.new(bfgs_test_flat)
	mut optimizer := BFGS.new_with_params(objective, bfgs_test_constant_gradient,
		BFGSParams{
			x0: [1e20]
		})
	result := optimizer.solve()!
	assert result.status == .precision_limit
	assert result.n_calls == 1
	assert result.x == [1e20]
}

fn test_bfgs_backtracks_past_non_finite_trial_values() {
	objective := func.FnND.new(bfgs_test_bounded_quadratic)
	mut optimizer := BFGS.new_with_params(objective, bfgs_test_bounded_quadratic_gradient,
		BFGSParams{
			x0: [0.0]
		})
	result := optimizer.solve()!
	assert result.status == .converged
	assert result.x == [-0.5]
	assert result.fx == 0.0
	assert result.n_calls == 3
}

fn test_bfgs_rejects_invalid_parameters_and_initial_point() {
	objective := func.FnND.new(bfgs_test_flat)
	mut empty_point := BFGS.new_with_params(objective, bfgs_test_constant_gradient,
		BFGSParams{})
	empty_point.solve() or {
		assert err.code() == 4
		return
	}
	assert false, 'expected an empty initial point to return an error'

	mut invalid_point := BFGS.new_with_params(objective, bfgs_test_constant_gradient,
		BFGSParams{
			x0: [math.inf(1)]
		})
	invalid_point.solve() or {
		assert err.code() == 4
		assert err.msg().contains('initial point must be finite')
		return
	}
	assert false, 'expected a non-finite initial point to return an error'
}
