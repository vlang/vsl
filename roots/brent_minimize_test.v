module roots

import math
import vsl.func

fn brent_minimizer_test_quadratic(x f64, _ []f64) f64 {
	return (x - 1.25) * (x - 1.25) + 3.0
}

fn brent_minimizer_test_boundary(x f64, _ []f64) f64 {
	return (x + 2.0) * (x + 2.0)
}

fn brent_minimizer_test_centered(x f64, _ []f64) f64 {
	return x * x
}

fn brent_minimizer_test_flat(_ f64, _ []f64) f64 {
	return 4.0
}

fn brent_minimizer_test_non_finite(_ f64, _ []f64) f64 {
	return math.nan()
}

fn brent_minimizer_test_non_finite_after_start(x f64, _ []f64) f64 {
	if x == 0.0 {
		return 1.0
	}
	return math.nan()
}

fn test_brent_minimizer_finds_quadratic_minimum_and_reports_diagnostics() {
	f := func.Fn.new(f: brent_minimizer_test_quadratic)
	mut minimizer := BrentMinimizer.new_with_params(f, BrentMinimizerParams{
		xmin:      -5.0
		xmax:      5.0
		tol:       1e-8
		n_max:     100
		max_evals: 102
	})
	result := minimizer.solve()!
	assert result.status == .converged
	assert math.abs(result.x - 1.25) <= 1e-8
	assert math.abs(result.fx - 3.0) <= 1e-14
	assert result.lower <= 1.25
	assert 1.25 <= result.upper
	assert result.error_bound <= minimizer.tol
	assert result.n_calls == minimizer.n_calls
	assert result.n_iter == minimizer.n_iter
	assert result.n_calls <= minimizer.max_evals
	mut golden_section := GoldenSection.new_with_params(f, GoldenSectionParams{
		xmin: -5.0
		xmax: 5.0
		tol:  1e-8
	})
	golden_result := golden_section.solve()!
	assert result.n_calls < golden_result.n_calls
}

fn test_brent_minimizer_approaches_boundary_minimum() {
	f := func.Fn.new(f: brent_minimizer_test_boundary)
	mut minimizer := BrentMinimizer.new_with_params(f, BrentMinimizerParams{
		xmin: 0.0
		xmax: 5.0
		tol:  1e-8
	})
	result := minimizer.solve()!
	assert result.status == .converged
	assert result.lower == 0.0
	assert result.x <= 1e-8
	assert result.fx <= 4.0 + 1e-7
}

fn test_brent_minimizer_handles_centered_and_flat_objectives() {
	centered := func.Fn.new(f: brent_minimizer_test_centered)
	mut centered_minimizer := BrentMinimizer.new_with_params(centered, BrentMinimizerParams{
		xmin: -5.0
		xmax: 5.0
		tol:  1e-9
	})
	centered_result := centered_minimizer.solve()!
	assert centered_result.status == .converged
	assert math.abs(centered_result.x) <= 1e-9
	assert centered_result.fx <= 1e-18

	flat := func.Fn.new(f: brent_minimizer_test_flat)
	mut flat_minimizer := BrentMinimizer.new_with_params(flat, BrentMinimizerParams{
		xmin: -1.0
		xmax: 1.0
		tol:  1e-8
	})
	flat_result := flat_minimizer.solve()!
	assert flat_result.status == .converged
	assert flat_result.fx == 4.0
	assert flat_result.error_bound <= flat_minimizer.tol
}

fn test_brent_minimizer_reports_non_finite_callback_values() {
	f := func.Fn.new(f: brent_minimizer_test_non_finite)
	mut minimizer := BrentMinimizer.new_with_params(f, BrentMinimizerParams{
		xmin: -1.0
		xmax: 1.0
	})
	result := minimizer.solve()!
	assert result.status == .non_finite_function_value
	assert result.n_calls == 1
	assert math.is_nan(result.fx)

	finite_start := func.Fn.new(f: brent_minimizer_test_non_finite_after_start)
	mut later_failure := BrentMinimizer.new_with_params(finite_start, BrentMinimizerParams{
		xmin: -1.0
		xmax: 1.0
	})
	later_result := later_failure.solve()!
	assert later_result.status == .non_finite_function_value
	assert later_result.n_calls == 2
	assert later_result.x == 0.0
	assert later_result.fx == 1.0
}

fn test_brent_minimizer_reports_iteration_and_evaluation_limits() {
	f := func.Fn.new(f: brent_minimizer_test_quadratic)
	mut iteration_limited := BrentMinimizer.new_with_params(f, BrentMinimizerParams{
		xmin:  -5.0
		xmax:  5.0
		tol:   1e-30
		n_max: 1
	})
	iteration_result := iteration_limited.solve()!
	assert iteration_result.status == .max_iterations
	assert iteration_result.n_iter == 1

	mut evaluation_limited := BrentMinimizer.new_with_params(f, BrentMinimizerParams{
		xmin:      -5.0
		xmax:      5.0
		tol:       1e-30
		max_evals: 1
	})
	evaluation_result := evaluation_limited.solve()!
	assert evaluation_result.status == .max_evaluations
	assert evaluation_result.n_calls == 1
	assert evaluation_result.lower <= evaluation_result.x
	assert evaluation_result.x <= evaluation_result.upper
	assert evaluation_result.fx == f.eval(evaluation_result.x)
}

fn test_brent_minimizer_reports_precision_limit_without_interior_float() {
	f := func.Fn.new(f: brent_minimizer_test_quadratic)
	mut minimizer := BrentMinimizer.new_with_params(f, BrentMinimizerParams{
		xmin: 1.0
		xmax: 1.0000000000000002
		tol:  1e-30
	})
	result := minimizer.solve()!
	assert result.status == .precision_limit
	assert result.n_calls == 0
	assert math.is_nan(result.fx)
}

fn test_brent_minimizer_rejects_invalid_parameters() {
	f := func.Fn.new(f: brent_minimizer_test_quadratic)
	mut invalid_bounds := BrentMinimizer.new_with_params(f, BrentMinimizerParams{
		xmin: 2.0
		xmax: 0.0
	})
	invalid_bounds.solve() or {
		assert err.code() == 4
		return
	}
	assert false, 'expected invalid bounds to return an error'
}
