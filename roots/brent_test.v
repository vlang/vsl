module roots

import math
import vsl.func
import vsl.float.float64

fn brent_test_cos(x f64, _ []f64) f64 {
	return math.cos(x)
}

fn brent_test_square_root(x f64, _ []f64) f64 {
	return x * x - 2.0
}

fn brent_test_endpoint_root(x f64, _ []f64) f64 {
	return x - 2.0
}

fn brent_test_nan(_ f64, _ []f64) f64 {
	return math.nan()
}

fn brent_test_nan_interior(x f64, _ []f64) f64 {
	if x == 0.0 || x == 2.0 {
		return x - 1.0
	}
	return math.nan()
}

fn brent_test_near_one(x f64, _ []f64) f64 {
	return x - (1.0 + 1e-15)
}

fn brent_test_identity(x f64, _ []f64) f64 {
	return x
}

fn test_brent_finds_root_and_reports_diagnostics() {
	f := func.Fn.new(f: brent_test_cos)
	mut solver := Brent.new_with_params(f,
		x1:        0.0
		x2:        3.0
		tol:       1e-10
		n_max:     100
		max_evals: 102
	)
	result := solver.solve()!
	assert result.status == .converged
	assert float64.soclose(result.x, math.pi / 2.0, 1e-9)
	assert result.lower <= math.pi / 2.0
	assert result.upper >= math.pi / 2.0
	assert result.n_calls == solver.n_calls
	assert result.n_iter == solver.n_iter
	assert result.n_calls <= solver.max_evals
	assert result.error_bound >= math.max(math.abs(result.x - result.lower), math.abs(result.upper - result.x))
}

fn test_brent_accepts_endpoint_roots() {
	f := func.Fn.new(f: brent_test_endpoint_root)
	mut solver := Brent.new_with_params(f, x1: 2.0, x2: 3.0)
	result := solver.solve()!
	assert result.status == .converged
	assert result.x == 2.0
	assert result.n_calls == 1
}

fn test_brent_reports_invalid_brackets() {
	f := func.Fn.new(f: brent_test_square_root)
	mut solver := Brent.new_with_params(f, x1: 2.0, x2: 3.0)
	result := solver.solve()!
	assert result.status == .invalid_bracket
	assert result.n_calls == 2
}

fn test_brent_reports_non_finite_callback_values() {
	f := func.Fn.new(f: brent_test_nan)
	mut solver := Brent.new_with_params(f, x1: 0.0, x2: 1.0)
	result := solver.solve()!
	assert result.status == .non_finite_function_value
	assert result.n_calls == 1
}

fn test_brent_reports_non_finite_interior_values() {
	f := func.Fn.new(f: brent_test_nan_interior)
	mut solver := Brent.new_with_params(f, x1: 0.0, x2: 2.0)
	result := solver.solve()!
	assert result.status == .non_finite_function_value
	assert result.n_calls == 3
}

fn test_brent_reports_iteration_and_evaluation_limits() {
	f := func.Fn.new(f: brent_test_square_root)
	mut iteration_limited := Brent.new_with_params(f, x1: 0.0, x2: 2.0, n_max: 1)
	iteration_result := iteration_limited.solve()!
	assert iteration_result.status == .max_iterations
	assert iteration_result.n_iter == 1

	mut evaluation_limited := Brent.new_with_params(f, x1: 0.0, x2: 2.0, max_evals: 2)
	evaluation_result := evaluation_limited.solve()!
	assert evaluation_result.status == .max_evaluations
	assert evaluation_result.n_calls == 2
	assert evaluation_result.lower <= evaluation_result.x
	assert evaluation_result.x <= evaluation_result.upper
	assert evaluation_result.fx == f.eval(evaluation_result.x)

	mut single_evaluation := Brent.new_with_params(f, x1: 0.0, x2: 2.0, max_evals: 1)
	single_result := single_evaluation.solve()!
	assert single_result.status == .max_evaluations
	assert single_result.n_calls == 1
}

fn test_brent_converges_at_floating_point_precision() {
	f := func.Fn.new(f: brent_test_near_one)
	mut solver := Brent.new_with_params(f, x1: 1.0, x2: 1.0 + 2e-15, tol: 1e-30)
	result := solver.solve()!
	assert result.status == .precision_limit || result.status == .converged
	assert math.abs(result.x - (1.0 + 1e-15)) <= 1e-15
}

fn test_brent_handles_extreme_finite_brackets() {
	f := func.Fn.new(f: brent_test_identity)
	mut solver := Brent.new_with_params(f, x1: -1e308, x2: 1e308, tol: 1e292)
	result := solver.solve()!
	assert result.status == .converged
	assert result.x == 0.0
	assert result.error_bound == 1e308
}

fn test_brent_rejects_invalid_parameters() {
	f := func.Fn.new(f: brent_test_square_root)
	mut invalid_bounds := Brent.new_with_params(f, x1: 2.0, x2: 0.0)
	invalid_bounds.solve() or { return }
	assert false, 'expected invalid bounds to return an error'
}

fn test_brent_rejects_invalid_tolerance() {
	f := func.Fn.new(f: brent_test_square_root)
	mut solver := Brent.new_with_params(f, x1: 0.0, x2: 2.0, tol: 0.0)
	solver.solve() or {
		assert err.code() == 4
		return
	}
	assert false, 'expected invalid tolerance to return an error'
}
