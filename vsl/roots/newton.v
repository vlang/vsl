module roots

import vsl.vmath
import vsl.errno
import vsl

// Find the root of a function using Newton's algorithm with the Armijo line
// search to ensure the absolute value of the function decreases along the
// iterations.
pub fn newton(func vsl.FunctionFdf, x0 f64, x_eps f64, fx_eps f64, n_max int) ?f64 {
	omega := 1e-4
	gamma := 0.5
	mut root := x0
	mut f, mut df := func.eval_f_df(root)
	mut i := 0
	for i < n_max {
		mut t := 1.0
		if df == 0.0 {
			errno.vsl_panic('div by zero', .ezerodiv)
		}
		dx := f / df
		norm0 := vmath.abs(f)
		mut norm := 0.0 // Armijo line search
		for t != 0.0 {
			x_linesearch := root - t * dx
			f, df = func.eval_f_df(x_linesearch)
			norm = vmath.abs(f)
			if norm < norm0 * (1.0 - omega * t) {
				root = x_linesearch
				break
			}
			t *= gamma
		}
		if vmath.abs(dx) < x_eps * vmath.abs(root) || norm < fx_eps {
			break
		}
		i++
	} // maximum number of iterations reached
	if i == n_max {
		return error(errno.vsl_error_message('maximum number of iterations reached', .emaxiter))
	}
	return root
}
