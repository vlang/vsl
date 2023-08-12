module roots

import vsl.errors
import vsl.func
import math

// Find the root of a function using Newton's algorithm with the Armijo line
// search to ensure the absolute value of the function decreases along the
// iterations.
pub fn newton(f func.FnFdf, x0 f64, x_eps f64, fx_eps f64, n_max int) !f64 {
	omega := 1e-4
	gamma := 0.5
	mut root := x0
	mut fval, mut df := f.eval_f_df(root) or {
		return errors.error('function evaluation failed', .efailed)
	}
	mut i := 0
	for i < n_max {
		mut t := 1.0
		if df == 0.0 {
			return errors.error('div by zero', .ezerodiv)
		}
		dx := fval / df
		norm0 := math.abs(fval)
		mut norm := 0.0 // Armijo line search
		for t != 0.0 {
			x_linesearch := root - t * dx
			fval, df = f.eval_f_df(x_linesearch) or {
				return errors.error('function evaluation failed', .efailed)
			}
			norm = math.abs(fval)
			if norm < norm0 * (1.0 - omega * t) {
				root = x_linesearch
				break
			}
			t *= gamma
		}
		if math.abs(dx) < x_eps * math.abs(root) || norm < fx_eps {
			break
		}
		i++
	} // maximum number of iterations reached
	if i == n_max {
		return errors.error('maximum number of iterations reached', .emaxiter)
	}
	return root
}
