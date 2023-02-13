module roots

import vsl.func
import math

const (
	epsabs = 0.0001
	epsrel = 0.00001
	n_max  = 100
)

fn f_cos(x f64, _ []f64) f64 {
	return math.cos(x)
}

fn fdf_cos(x f64, _ []f64) (f64, f64) {
	return math.cos(x), -math.sin(x)
}

fn test_root_bisection() {
	x1 := 0.0
	x2 := f64(3)
	f := func.new_func(f: f_cos)
	result := bisection(f, x1, x2, roots.epsrel, roots.epsabs, roots.n_max)?
	assert compare(result, math.pi / 2.00)
}

fn test_root_newton() {
	x0 := f64(0.5)
	f := func.new_func_fdf(fdf: fdf_cos)
	result := newton(f, x0, roots.epsrel, roots.epsabs, roots.n_max)?
	assert compare(result, math.pi / 2.00)
}

// Helper method for comparing floats
fn compare(x f64, y f64) bool {
	tolerance := roots.epsabs
	// Special case for zeroes
	if x < tolerance && x > (-1.0 * tolerance) && y < tolerance && y > (-1.0 * tolerance) {
		return true
	}
	diff := math.abs(x - y)
	mean := math.abs(x + y) / 2.0
	return if math.is_nan(diff / mean) { true } else { ((diff / mean) < tolerance) }
}
