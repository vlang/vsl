module float32

import math

// l2_norm_unitary returns the L2-norm of x.
pub fn l2_norm_unitary(x []f32) f32 {
	// TODO: Change when f32 math is ready
	mut scale := f32(0)
	mut sum_squares := f32(1)
	for v in x {
		if v == 0 {
			continue
		}
		absxi := math.abs(v)
		if math.is_nan(f64(absxi)) {
			return f32(math.nan())
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
	if math.is_inf(f32(scale), 1) {
		return f32(math.inf(1))
	}
	return scale * f32(math.sqrt(sum_squares))
}

// l2_norm_inc returns the L2-norm of x.
pub fn l2_norm_inc(x []f32, n u32, incx u32) f32 {
	// TODO: Change when f32 math is ready
	mut scale := f32(0)
	mut sum_squares := f32(1)
	for ix := u32(0); ix < n * incx; ix += incx {
		val := x[ix]
		if val == 0 {
			continue
		}
		absxi := math.abs(val)
		if math.is_nan(f64(absxi)) {
			return f32(math.nan())
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
	if math.is_inf(f64(scale), 1) {
		return f32(math.inf(1))
	}
	return scale * f32(math.sqrt(sum_squares))
}

// l2_distance_unitary returns the L2-norm of x-y.
pub fn l2_distance_unitary(x []f32, y []f32) f32 {
	// TODO: Change when f32 math is ready
	mut scale := f32(0)
	mut sum_squares := f32(1)
	for i, v in x {
		mut dec_v := v
		dec_v -= y[i]
		if dec_v == 0 {
			continue
		}
		absxi := math.abs(dec_v)
		if math.is_nan(f64(absxi)) {
			return f32(math.nan())
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
	if math.is_inf(f64(scale), 1) {
		return f32(math.inf(1))
	}
	return scale * f32(math.sqrt(sum_squares))
}
