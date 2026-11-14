module roots

import math
import vsl.func

fn golden_section_test_quadratic(x f64, _ []f64) f64 {
	return (x - 1.25) * (x - 1.25)
}

fn golden_section_test_rounded_quadratic(x f64, _ []f64) f64 {
	return (x - 1.25) * (x - 1.25) + 3.0
}

fn golden_section_test_boundary_minimum(x f64, _ []f64) f64 {
	return (x + 2.0) * (x + 2.0)
}

fn golden_section_test_flat(_ f64, _ []f64) f64 {
	return 4.0
}

fn golden_section_test_non_finite(_ f64, _ []f64) f64 {
	return math.nan()
}

fn test_golden_section_finds_unimodal_minimum_and_reports_diagnostics() {
	f := func.Fn.new(f: golden_section_test_quadratic)
	mut solver := GoldenSection.new_with_params(f, GoldenSectionParams{
		xmin:      -5.0
		xmax:      5.0
		tol:       1e-9
		n_max:     100
		max_evals: 104
	})
	result := solver.solve()!
	assert result.status == .converged
	assert math.abs(result.x - 1.25) <= 1e-8
	assert math.abs(result.fx) <= 1e-16
	assert result.lower <= 1.25
	assert 1.25 <= result.upper
	assert result.error_bound <= 1e-9
	assert result.lower <= result.x
	assert result.x <= result.upper
	assert result.n_calls == solver.n_calls
	assert result.n_iter == solver.n_iter
	assert result.n_calls <= solver.max_evals
}

fn test_golden_section_approaches_a_boundary_minimum() {
	f := func.Fn.new(f: golden_section_test_boundary_minimum)
	mut solver := GoldenSection.new_with_params(f, GoldenSectionParams{
		xmin: 0.0
		xmax: 5.0
		tol:  1e-8
	})
	result := solver.solve()!
	assert result.status == .converged
	assert result.lower == 0.0
	assert result.x <= 1e-8
	assert result.fx <= 4.0 + 1e-7
}

fn test_golden_section_reports_flat_objective_without_claiming_unique_location() {
	f := func.Fn.new(f: golden_section_test_flat)
	mut solver := GoldenSection.new_with_params(f, GoldenSectionParams{
		xmin: -1.0
		xmax: 1.0
		tol:  1e-8
	})
	result := solver.solve()!
	assert result.status == .precision_limit
	assert result.fx == 4.0
	assert result.lower <= result.x
	assert result.x <= result.upper
	assert result.n_calls == 2
}

fn test_golden_section_reports_objective_precision_limit_without_excluding_minimum() {
	f := func.Fn.new(f: golden_section_test_rounded_quadratic)
	mut solver := GoldenSection.new_with_params(f, GoldenSectionParams{
		xmin:      -5.0
		xmax:      5.0
		tol:       1e-9
		n_max:     100
		max_evals: 104
	})
	result := solver.solve()!
	assert result.status == .precision_limit
	assert result.lower <= 1.25
	assert 1.25 <= result.upper
	assert result.fx == 3.0
}

fn test_golden_section_reports_non_finite_callback_values() {
	f := func.Fn.new(f: golden_section_test_non_finite)
	mut solver := GoldenSection.new_with_params(f, GoldenSectionParams{
		xmin: 0.0
		xmax: 1.0
	})
	result := solver.solve()!
	assert result.status == .non_finite_function_value
	assert result.n_calls == 1
	assert math.is_nan(result.fx)
}

fn test_golden_section_reports_iteration_and_evaluation_limits() {
	f := func.Fn.new(f: golden_section_test_quadratic)
	mut iteration_limited := GoldenSection.new_with_params(f, GoldenSectionParams{
		xmin:  -5.0
		xmax:  5.0
		tol:   1e-30
		n_max: 1
	})
	iteration_result := iteration_limited.solve()!
	assert iteration_result.status == .max_iterations
	assert iteration_result.n_iter == 1

	mut evaluation_limited := GoldenSection.new_with_params(f, GoldenSectionParams{
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

fn test_golden_section_reports_precision_limit() {
	f := func.Fn.new(f: golden_section_test_flat)
	mut solver := GoldenSection.new_with_params(f, GoldenSectionParams{
		xmin: 1.0
		xmax: 1.0000000000000002
		tol:  1e-30
	})
	result := solver.solve()!
	assert result.status == .precision_limit
	assert result.n_calls == 0
	assert math.is_nan(result.fx)
}

fn test_golden_section_rejects_invalid_parameters() {
	f := func.Fn.new(f: golden_section_test_quadratic)
	mut invalid_bounds := GoldenSection.new_with_params(f, GoldenSectionParams{
		xmin: 2.0
		xmax: 0.0
	})
	invalid_bounds.solve() or {
		assert err.code() == 4
		return
	}
	assert false, 'expected invalid bounds to return an error'
}
