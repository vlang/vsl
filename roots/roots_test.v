
module roots

import vsl
import vsl.vmath

const (
	epsabs = 0.0001
	epsrel = 0.00001
	n_max  = 100
)

fn f_cos(x f64, _ []f64) f64 {
	return vmath.cos(x)
}

fn fdf_cos(x f64, _ []f64) (f64, f64) {
	return vmath.cos(x), -vmath.sin(x)
}

fn test_root_bisection() {
	x1 := 0.0
	x2 := f64(3)
	func := vsl.Function{
		function: f_cos
	}
	result := bisection(func, x1, x2, epsrel, epsabs, n_max) or { panic(err) }
	assert compare(result, vmath.pi / 2.00)
}

fn test_root_newton() {
	x0 := f64(0.5)
	func := vsl.FunctionFdf{
		fdf: fdf_cos
	}
	result := newton(func, x0, epsrel, epsabs, n_max) or { panic(err) }
	assert compare(result, vmath.pi / 2.00)
}

// Helper method for comparing floats
fn compare(x f64, y f64) bool {
	tolerance := epsabs
	// Special case for zeroes
	if x < tolerance && x > (-1.0 * tolerance) && y < tolerance && y > (-1.0 * tolerance) {
		return true
	}
	diff := vmath.abs(x - y)
	mean := vmath.abs(x + y) / 2.0
	return if vmath.is_nan(diff / mean) {
		true
	} else {
		((diff / mean) < tolerance)
	}
}
