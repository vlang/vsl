module roots

import math
import vsl.func

fn nelder_mead_test_quadratic(x []f64, _ []f64) f64 {
	targets := [2.0, -1.0, 0.5]
	mut sum := 0.0
	for i, value in x {
		delta := value - targets[i]
		sum += delta * delta
	}
	return sum
}

fn nelder_mead_test_rosenbrock(x []f64, _ []f64) f64 {
	a := 1.0 - x[0]
	b := x[1] - x[0] * x[0]
	return a * a + 100.0 * b * b
}

fn nelder_mead_test_flat(_ []f64, _ []f64) f64 {
	return 4.0
}

fn nelder_mead_test_nan(_ []f64, _ []f64) f64 {
	return math.nan()
}

fn nelder_mead_test_finite_origin(x []f64, _ []f64) f64 {
	if x[0] == 0.0 && x[1] == 0.0 {
		return 1.0
	}
	return math.nan()
}

fn test_nelder_mead_minimizes_multivariate_quadratic() {
	f := func.FnND.new(nelder_mead_test_quadratic)
	mut optimizer := NelderMead.new_with_params(f, NelderMeadParams{
		x0:           [0.0, 0.0, 0.0]
		initial_step: 0.4
		x_tol:        1e-8
		f_tol:        1e-12
		n_max:        500
		max_evals:    2000
	})
	result := optimizer.solve()!
	assert result.status == .converged
	assert math.abs(result.x[0] - 2.0) <= 1e-7
	assert math.abs(result.x[1] + 1.0) <= 1e-7
	assert math.abs(result.x[2] - 0.5) <= 1e-7
	assert result.fx <= 1e-12
	assert result.x_spread <= optimizer.x_tol
	assert result.f_spread <= optimizer.f_tol
	assert result.n_calls == optimizer.n_calls
	assert result.n_iter == optimizer.n_iter
}

fn test_nelder_mead_converges_on_rosenbrock() {
	f := func.FnND.new(nelder_mead_test_rosenbrock)
	mut optimizer := NelderMead.new_with_params(f, NelderMeadParams{
		x0:           [-1.2, 1.0]
		initial_step: 0.5
		x_tol:        1e-6
		f_tol:        1e-12
		n_max:        2000
		max_evals:    5000
	})
	result := optimizer.solve()!
	assert result.status == .converged
	assert math.abs(result.x[0] - 1.0) <= 1e-4
	assert math.abs(result.x[1] - 1.0) <= 1e-4
	assert result.fx <= 1e-8
}

fn test_nelder_mead_shrinks_flat_objectives_without_claiming_a_unique_point() {
	f := func.FnND.new(nelder_mead_test_flat)
	mut optimizer := NelderMead.new_with_params(f, NelderMeadParams{
		x0:           [1.0, -1.0]
		initial_step: 0.5
		x_tol:        1e-6
		f_tol:        1e-12
	})
	result := optimizer.solve()!
	assert result.status == .converged
	assert result.fx == 4.0
	assert result.f_spread == 0.0
	assert result.x_spread <= optimizer.x_tol
}

fn test_nelder_mead_reports_non_finite_callbacks_without_losing_best_point() {
	f := func.FnND.new(nelder_mead_test_nan)
	mut optimizer := NelderMead.new_with_params(f, NelderMeadParams{
		x0: [0.0, 0.0]
	})
	result := optimizer.solve()!
	assert result.status == .non_finite_function_value
	assert result.n_calls == 1
	assert math.is_nan(result.fx)

	finite_start := func.FnND.new(nelder_mead_test_finite_origin)
	mut later_failure := NelderMead.new_with_params(finite_start, NelderMeadParams{
		x0:           [0.0, 0.0]
		initial_step: 0.5
	})
	later_result := later_failure.solve()!
	assert later_result.status == .non_finite_function_value
	assert later_result.n_calls == 2
	assert later_result.x == [0.0, 0.0]
	assert later_result.fx == 1.0
}

fn test_nelder_mead_reports_evaluation_iteration_and_precision_limits() {
	f := func.FnND.new(nelder_mead_test_quadratic)
	mut evaluation_limited := NelderMead.new_with_params(f, NelderMeadParams{
		x0:        [0.0, 0.0, 0.0]
		max_evals: 4
	})
	evaluation_result := evaluation_limited.solve()!
	assert evaluation_result.status == .max_evaluations
	assert evaluation_result.n_calls == 4

	mut iteration_limited := NelderMead.new_with_params(f, NelderMeadParams{
		x0:    [0.0, 0.0, 0.0]
		n_max: 1
	})
	iteration_result := iteration_limited.solve()!
	assert iteration_result.status == .max_iterations
	assert iteration_result.n_iter == 1

	mut precision_limited := NelderMead.new_with_params(f, NelderMeadParams{
		x0:           [1e20, -1e20]
		initial_step: 1e-10
	})
	precision_result := precision_limited.solve()!
	assert precision_result.status == .precision_limit
	assert precision_result.n_calls == 0
	assert math.is_nan(precision_result.fx)
}

fn test_nelder_mead_rejects_invalid_parameters() {
	f := func.FnND.new(nelder_mead_test_quadratic)
	mut empty_point := NelderMead.new_with_params(f, NelderMeadParams{})
	empty_point.solve() or {
		assert err.code() == 4
		return
	}
	assert false, 'expected an empty initial point to return an error'
}
