module roots

import vsl.func
import vsl.float.float64
import math

const epsabs = 0.0001
const epsrel = 0.00001
const n_max = 100

fn f_cos(x f64, _ []f64) f64 {
	return math.cos(x)
}

fn f_scaled_root(x f64, _ []f64) f64 {
	return 1e-12 * (x - 1.0)
}

fn f_identity(x f64, _ []f64) f64 {
	return x
}

fn f_positive(x f64, _ []f64) f64 {
	return x * x + 1.0
}

fn f_adjacent_sign_change(x f64, _ []f64) f64 {
	if x <= 1.0 {
		return 2.0
	}
	return -1.0
}

fn f_large_root(x f64, _ []f64) f64 {
	return x - 1_000_001.0
}

fn f_nonfinite_on_second_midpoint(x f64, _ []f64) f64 {
	if x == 3.0 {
		return math.nan()
	}
	return x - 3.5
}

fn fdf_cos(x f64, _ []f64) (f64, f64) {
	return math.cos(x), -math.sin(x)
}

fn test_root_bisection() {
	f := func.Fn.new(f: f_cos)
	mut solver := Bisection.new(f,
		xmin:   0.0
		xmax:   3.0
		epsrel: epsrel
		epsabs: epsabs
		n_max:  n_max
	)
	result := solver.solve()?
	assert float64.soclose(result.x, math.pi / 2.00, epsabs)
}

fn test_bisection_uses_x_tolerance_and_counts_endpoint_evaluations() {
	f := func.Fn.new(f: f_scaled_root)
	mut solver := Bisection.new(f,
		xmin:   0.0
		xmax:   4.0
		epsrel: 0.0
		epsabs: 1e-6
		n_max:  100
	)
	result := solver.solve()?
	assert math.abs(result.x - 1.0) <= 1.1e-6
	assert result.n_iter > 1
	assert result.n_f_calls == result.n_iter + 2
}

fn test_bisection_uses_relative_x_tolerance() {
	f := func.Fn.new(f: f_large_root)
	mut solver := Bisection.new(f,
		xmin:   0.0
		xmax:   2_000_000.0
		epsrel: 1e-6
		epsabs: 0.0
		n_max:  100
	)
	result := solver.solve()?
	assert math.abs(result.x - 1_000_001.0) <= 1.1
	assert result.n_iter < 25
}

fn test_bisection_returns_an_exact_endpoint_root() {
	f := func.Fn.new(f: f_identity)
	mut solver := Bisection.new(f, xmin: 0.0, xmax: 1.0)
	result := solver.solve()?
	assert result.x == 0.0
	assert result.fx == 0.0
	assert result.n_iter == 0
	assert result.n_f_calls == 1
}

fn test_bisection_returns_best_estimate_when_precision_stagnates() {
	f := func.Fn.new(f: f_adjacent_sign_change)
	xmin := 1.0
	xmax := 1.0000000000000002
	mut solver := Bisection.new(f,
		xmin:   0.0
		xmax:   2.0
		epsrel: 0.0
		epsabs: 0.0
		n_max:  10
	)
	first := solver.next()?
	assert first.x == 1.0
	assert first.n_iter == 1

	solver.xmin = xmin
	solver.xmax = xmax
	result := solver.next()?
	assert result.x == xmax
	assert result.fx == -1.0
	assert result.n_iter == 0
	assert result.n_f_calls == 5
	if next_result := solver.next() {
		assert false, 'a precision-limited solver must be finished, got ${next_result}'
	}

	mut solve_solver := Bisection.new(f,
		xmin:   xmin
		xmax:   xmax
		epsrel: 0.0
		epsabs: 0.0
		n_max:  10
	)
	solve_result := solve_solver.solve()?
	assert solve_result.x == xmax
	assert solve_result.fx == -1.0
	assert solve_result.n_iter == 0
	assert solve_result.n_f_calls == 2

	exact_root_f := func.Fn.new(f: f_identity)
	mut exact_root_solver := Bisection.new(exact_root_f, xmin: 0.0, xmax: 1.0)
	exact_root := exact_root_solver.solve()?
	assert exact_root.x == 0.0
	assert exact_root.fx == 0.0
	assert exact_root.n_iter == 0
	assert exact_root.n_f_calls == 1
}

fn test_bisection_rejects_an_interval_without_a_sign_change() {
	f := func.Fn.new(f: f_positive)
	mut solver := Bisection.new(f, xmin: 0.0, xmax: 1.0)
	if result := solver.solve() {
		assert false, 'expected an invalid bracket, got ${result}'
	}
}

fn test_bisection_retries_after_initial_bounds_are_corrected() {
	f := func.Fn.new(f: f_identity)
	mut solver := Bisection.new(f, xmin: 1.0, xmax: 2.0)
	if result := solver.next() {
		assert false, 'expected an invalid bracket, got ${result}'
	}
	assert solver.n_f_calls == 2
	if result := solver.next() {
		assert false, 'unchanged invalid bounds must remain terminal, got ${result}'
	}
	assert solver.n_f_calls == 2

	solver.xmin = -1.0
	solver.xmax = 1.0
	result := solver.solve()?
	assert result.x == 0.0
	assert result.fx == 0.0
	assert result.n_iter == 1
}

fn test_bisection_revalidates_bounds_changed_between_steps() {
	f := func.Fn.new(f: f_nonfinite_on_second_midpoint)
	mut solver := Bisection.new(f,
		xmin:   0.0
		xmax:   4.0
		epsrel: 0.0
		epsabs: 0.0
		n_max:  10
	)
	first := solver.next()?
	assert first.x == 2.0
	solver.xmin = 4.0
	solver.xmax = 6.0
	if result := solver.next() {
		assert false, 'expected changed bounds without a sign change to return none, got ${result}'
	}
}

fn test_bisection_does_not_return_a_stale_result_after_nonfinite_evaluation() {
	f := func.Fn.new(f: f_nonfinite_on_second_midpoint)
	mut solver := Bisection.new(f,
		xmin:   0.0
		xmax:   4.0
		epsrel: 0.0
		epsabs: 0.0
		n_max:  10
	)
	first := solver.next()?
	assert first.x == 2.0
	if result := solver.solve() {
		assert false, 'expected a non-finite midpoint to return none, got ${result}'
	}
}

fn test_root_newton() {
	x0 := f64(0.5)
	f := func.FnFdf.new(fdf: fdf_cos)
	result := newton(f, x0, epsrel, epsabs, n_max)!
	assert float64.soclose(result, math.pi / 2.00, epsabs)
}
