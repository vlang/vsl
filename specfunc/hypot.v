// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module specfunc

import vsl.math
import vsl.errno
import vsl.internal

pub fn hypot(x, y f64) f64 {
	if math.is_inf(x, 0) || math.is_inf(y, 0) {
		return math.inf(1)
	}
	if math.is_nan(x) || math.is_nan(y) {
		return math.nan()
	}
	mut result := 0.0
	if x != 0.0 || y != 0.0 {
		a := math.abs(x)
		b := math.abs(y)
		min := math.min(a, b)
		max := math.max(a, b)
		rat := min / max
		root_term := math.sqrt(f64(1.0) + rat * rat)
		if max < math.max_f64 / root_term {
			result = max * root_term
		} else {
			errno.vsl_panic('overflow in hypot_e function', .eovrflw)
		}
	}
	return result
}

pub fn hypot_e(x, y f64) (f64, f64) {
	if math.is_inf(x, 0) || math.is_inf(y, 0) {
		return math.inf(1), 0.0
	}
	if math.is_nan(x) || math.is_nan(y) {
		return math.nan(), 0.0
	}
	mut result := 0.0
	mut result_err := 0.0
	if x != 0.0 || y != 0.0 {
		a := math.abs(x)
		b := math.abs(y)
		min := math.min(a, b)
		max := math.max(a, b)
		rat := min / max
		root_term := math.sqrt(f64(1.0) + rat * rat)
		if max < math.max_f64 / root_term {
			result = max * root_term
			result_err = f64(2.0) * internal.f64_epsilon * math.abs(result)
		} else {
			errno.vsl_panic('overflow in hypot_e function', .eovrflw)
		}
	}
	return result, result_err
}
