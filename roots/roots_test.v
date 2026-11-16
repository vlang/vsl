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

fn test_bisection_rejects_an_interval_without_a_sign_change() {
	f := func.Fn.new(f: f_positive)
	mut solver := Bisection.new(f, xmin: 0.0, xmax: 1.0)
	if result := solver.solve() {
		assert false, 'expected an invalid bracket, got ${result}'
	}
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
