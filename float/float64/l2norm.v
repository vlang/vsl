module float64

import math
import simd

// l2_norm_unitary returns the L2-norm of x.
pub fn l2_norm_unitary(x []f64) f64 {
	mut scale := 0.0
	for v in x {
		absxi := math.abs(v)
		if math.is_nan(absxi) {
			return math.nan()
		}
		if absxi > scale {
			scale = absxi
		}
	}
	if scale == 0 {
		return 0
	}
	if math.is_inf(scale, 1) {
		return math.inf(1)
	}
	// For ordinary magnitudes, avoid dividing every lane by `scale` in the
	// second pass. Keep the scaled algorithm below for tiny or very large
	// values, where direct squaring could underflow or overflow.
	max_safe_scale := math.sqrt(math.max_f64 / f64(x.len))
	if scale >= 1e-150 && scale <= max_safe_scale {
		mut squared_sums := simd.splat_f64x4(0)
		mut offset := 0
		for ; offset + 4 <= x.len; offset += 4 {
			values := simd.load_f64x4_at(x, offset)
			squared_sums += values * values
		}
		mut sum_squares := squared_sums.sum()
		for value in x[offset..] {
			sum_squares += value * value
		}
		if !math.is_inf(sum_squares, 1) {
			return math.sqrt(sum_squares)
		}
	}
	scale_vector := simd.splat_f64x4(scale)
	mut squared_sums := simd.splat_f64x4(0)
	mut offset := 0
	for ; offset + 4 <= x.len; offset += 4 {
		normalized := simd.load_f64x4_at(x, offset) / scale_vector
		squared_sums += normalized * normalized
	}
	mut sum_squares := squared_sums.sum()
	for value in x[offset..] {
		normalized := value / scale
		sum_squares += normalized * normalized
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
