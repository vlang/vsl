// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module specfunc

import vsl.vmath
import vsl.errno
import vsl.internal

pub fn hypot(x f64, y f64) f64 {
	if vmath.is_inf(x, 0) || vmath.is_inf(y, 0) {
		return vmath.inf(1)
	}
	if vmath.is_nan(x) || vmath.is_nan(y) {
		return vmath.nan()
	}
	mut result := 0.0
	if x != 0.0 || y != 0.0 {
		a := vmath.abs(x)
		b := vmath.abs(y)
		min := vmath.min(a, b)
		max := vmath.max(a, b)
		rat := min / max
		root_term := vmath.sqrt(1.0 + rat * rat)
		if max < vmath.max_f64 / root_term {
			result = max * root_term
		} else {
			errno.vsl_panic('overflow in hypot_e function', .eovrflw)
		}
	}
	return result
}

pub fn hypot_e(x f64, y f64) (f64, f64) {
	if vmath.is_inf(x, 0) || vmath.is_inf(y, 0) {
		return vmath.inf(1), 0.0
	}
	if vmath.is_nan(x) || vmath.is_nan(y) {
		return vmath.nan(), 0.0
	}
	mut result := 0.0
	mut result_err := 0.0
	if x != 0.0 || y != 0.0 {
		a := vmath.abs(x)
		b := vmath.abs(y)
		min := vmath.min(a, b)
		max := vmath.max(a, b)
		rat := min / max
		root_term := vmath.sqrt(1.0 + rat * rat)
		if max < vmath.max_f64 / root_term {
			result = max * root_term
			result_err = f64(2.0) * internal.f64_epsilon * vmath.abs(result)
		} else {
			errno.vsl_panic('overflow in hypot_e function', .eovrflw)
		}
	}
	return result, result_err
}
