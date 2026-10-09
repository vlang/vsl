module float32

import math
import simd

// l2_norm_unitary returns the L2-norm of x.
pub fn l2_norm_unitary(x []f32) f32 {
	// TODO: Change when f32 math is ready
	// For long vectors with ordinary magnitudes, use SIMD to sum squares.
	// Keep the scaled scalar algorithm below for short vectors and values where
	// squaring could overflow or underflow.
	if x.len >= 64 {
		mut scale := f32(0)
		for value in x {
			abs_value := math.abs(value)
			if math.is_nan(f64(abs_value)) {
				return f32(math.nan())
			}
			if scale < abs_value {
				scale = abs_value
			}
		}
		if math.is_inf(f64(scale), 1) {
			return f32(math.inf(1))
		}
		if scale == 0 {
			return 0
		}
		max_f32 := f64(f32(3.4028234663852886e38))
		max_safe_scale := math.sqrt(max_f32 / f64(x.len))
		if scale >= f32(1e-18) && f64(scale) <= max_safe_scale {
			mut squared_sums := simd.splat_f32x8(0)
			mut offset := 0
			for ; offset + 8 <= x.len; offset += 8 {
				values := simd.load_f32x8_at(x, offset)
				squared_sums += values * values
			}
			mut sum_squares := squared_sums.sum()
			for value in x[offset..] {
				sum_squares += value * value
			}
			if !math.is_inf(f64(sum_squares), 1) {
				return f32(math.sqrt(f64(sum_squares)))
			}
		}
	}
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
