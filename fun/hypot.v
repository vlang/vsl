module fun

import math
import vsl.errors
import vsl.internal.prec

pub fn hypot(x f64, y f64) f64 {
	if math.is_inf(x, 0) || math.is_inf(y, 0) {
		return math.inf(1)
	}
	if math.is_nan(x) || math.is_nan(y) {
		return math.nan()
	}
	mut result := 0.0
	if x != 0.0 || y != 0.0 {
		abs_x := math.abs(x)
		abs_y := math.abs(y)
		min, max := math.minmax(abs_x, abs_y)
		rat := min / max
		root_term := math.sqrt(1.0 + rat * rat)
		if max < max_f64 / root_term {
			result = max * root_term
		} else {
			errors.vsl_panic('overflow in hypot function', .eovrflw)
		}
	}
	return result
}

pub fn hypot_e(x f64, y f64) (f64, f64) {
	if math.is_inf(x, 0) || math.is_inf(y, 0) {
		return math.inf(1), 0.0
	}
	if math.is_nan(x) || math.is_nan(y) {
		return math.nan(), 0.0
	}
	mut result := 0.0
	mut result_err := 0.0
	if x != 0.0 || y != 0.0 {
		abs_x := math.abs(x)
		abs_y := math.abs(y)
		min, max := math.minmax(abs_x, abs_y)
		rat := min / max
		root_term := math.sqrt(1.0 + rat * rat)
		if max < max_f64 / root_term {
			result = max * root_term
			result_err = f64(2.0) * prec.f64_epsilon * math.abs(result)
		} else {
			errors.vsl_panic('overflow in hypot_e function', .eovrflw)
		}
	}
	return result, result_err
}
