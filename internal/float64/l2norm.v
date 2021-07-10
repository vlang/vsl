module float64

import vsl.vmath as math

// l2_norm_unitary returns the L2-norm of x.
pub fn l2_norm_unitary(x []f64) f64 {
	mut scale := 0.0
	mut sum_squares := 1.0
	for v in x {
		if v == 0 {
			continue
		}
		absxi := math.abs(v)
		if math.is_nan(absxi) {
			return math.nan()
		}
		if scale < absxi {
			s := scale / absxi
			sum_squares = 1 + sum_squares * s * s
			scale = absxi
		} else {
			s := absxi / scale
			sum_squares += s * s
		}
	}
	if math.is_inf(scale, 1) {
		return math.inf(1)
	}
	return scale * math.sqrt(sum_squares)
}

// l2_norm_inc returns the L2-norm of x.
pub fn l2_norm_inc(x []f64, n u32, incx u32) f64 {
	mut scale := 0.0
	mut sum_squares := 1.0
	for ix := u32(0); ix < n * incx; ix += incx {
		val := x[ix]
		if val == 0 {
			continue
		}
		absxi := math.abs(val)
		if math.is_nan(absxi) {
			return math.nan()
		}
		if scale < absxi {
			s := scale / absxi
			sum_squares = 1 + sum_squares * s * s
			scale = absxi
		} else {
			s := absxi / scale
			sum_squares += s * s
		}
	}
	if math.is_inf(scale, 1) {
		return math.inf(1)
	}
	return scale * math.sqrt(sum_squares)
}

// l2_distance_unitary returns the L2-norm of x-y.
pub fn l2_distance_unitary(x []f64, y []f64) f64 {
	mut scale := 0.0
	mut sum_squares := 1.0
	for i, v in x {
		mut dec_v := v
		dec_v -= y[i]
		if dec_v == 0 {
			continue
		}
		absxi := math.abs(dec_v)
		if math.is_nan(absxi) {
			return math.nan()
		}
		if scale < absxi {
			s := scale / absxi
			sum_squares = 1 + sum_squares * s * s
			scale = absxi
		} else {
			s := absxi / scale
			sum_squares += s * s
		}
	}
	if math.is_inf(scale, 1) {
		return math.inf(1)
	}
	return scale * math.sqrt(sum_squares)
}
