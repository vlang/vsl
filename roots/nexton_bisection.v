module roots

import vsl.errors
import vsl.func
import math

// Find the root of a function by combining Newton's method with the bisection
// method
pub fn newton_bisection(func func.FnFdf, x_min f64, x_max f64, tol f64, max_iter int) ?f64 {
	func_low, _ := func.eval_f_df(x_min)
	if func_low == 0.0 {
		return x_min
	}
	func_high, _ := func.eval_f_df(x_max)
	if func_high == 0.0 {
		return x_max
	}
	// Root is not bracketed by x1 and x2
	if (func_low > 0.0 && func_high > 0.0) || (func_low < 0.0 && func_high < 0.0) {
		return errors.error('roots is not bracketed by ${x_min} and ${x_max}', .einval)
	}
	mut xl := 0.0
	mut xh := 0.0
	if func_low < 0.0 {
		xl = x_min
		xh = x_max
	} else {
		xl = x_max
		xh = x_min
	}
	mut rts := f64(0.5) * (x_min + x_max)
	mut dx_anc := math.abs(x_max - x_min)
	mut dx := dx_anc
	mut func_current, mut diff_func_current := func.eval_f_df(rts)
	for _ in 0 .. max_iter {
		if (((rts - xh) * diff_func_current - func_current) * ((rts - xl) * diff_func_current - func_current) >= 0.0)
			|| math.abs(2.0 * func_current) > math.abs(dx_anc * diff_func_current) {
			dx_anc = dx
			dx = 0.5 * (xh - xl)
			rts = xl + dx
		} else {
			dx_anc = dx
			dx = func_current / diff_func_current
			rts -= dx
		}
		if math.abs(dx) < tol {
			return rts
		}
		func_current, diff_func_current = func.eval_f_df(rts)
		if func_current < 0.0 {
			xl = rts
		} else {
			xh = rts
		}
	} // Maximum number of iterations exceeded
	return errors.error('maximum number of iterations exceeded', .emaxiter)
}
