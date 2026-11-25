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

fn f_positive(x f64, _ []f64) f64 {
	return x * x + 1.0
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

fn test_root_bisection_uses_bracket_width_for_convergence() {
	f := func.Fn.new(f: f_scaled_root)
	mut solver := Bisection.new(f,
		xmin:   0.0
		xmax:   4.0
		epsrel: 0.0
		epsabs: 1e-6
		n_max:  100
	)
	result := solver.solve()?
	assert math.abs(result.x - 1.0) <= 1e-6
	assert result.n_iter > 1
}

fn test_root_bisection_rejects_non_bracketing_interval() {
	f := func.Fn.new(f: f_positive)
	mut solver := Bisection.new(f, xmin: 0.0, xmax: 1.0)
	if result := solver.solve() {
		assert false, 'expected an invalid bracket, got ${result}'
	}
}

fn test_root_newton() {
	x0 := f64(0.5)
	f := func.FnFdf.new(fdf: fdf_cos)
	result := newton(f, x0, epsrel, epsabs, n_max)!
	assert float64.soclose(result, math.pi / 2.00, epsabs)
}
