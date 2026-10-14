module float32

import math
import vsl.float.float64 as f64m

// Elementary functions correctly rounded in practice, evaluated in
// double-double arithmetic (~106 bits) and rounded once to f32 by
// exact midpoint comparison.
//
// The previous implementation evaluated in f64 and rounded to f32.
// That double rounding is wrong whenever the exact result lies
// within f64 rounding distance of an f32 midpoint, and the committed
// exhaustive suite found a concrete case: for log, input bits
// 0x41178feb (x = 9.47263622283935546875) has exact value
// 2.24840724468231192940..., which is 8.2e-17 below the f32 midpoint
// 2.24840724468231201171..., so the correctly rounded result ends in
// bits ...e7; the f64 evaluation rounds up to exactly the midpoint
// and then to ...e8. Evaluating in double-double shrinks the danger
// zone around each midpoint from ~2^-53 to ~2^-100 relative, the
// same basis as the float64 *_dd functions, themselves validated
// against 200-bit references on millions of sampled and directed
// hard cases and, for f32, by the committed exhaustive suites
// (hundreds of millions of inputs, zero mismatches after this fix).
// An all-inputs RLIBM-style proof remains the goal of vlang/vsl#65.
//
// Non-finite inputs keep the exact host-libm behavior of the old
// implementation; finite inputs always take the double-double path
// (for |x| > 1e15 the trig *_dd functions themselves fall back to
// libm, so accuracy there stays bounded by libm argument reduction,
// as documented in float64). The double-double evaluation is slower
// than a single libm call; these functions favor correctness.

// f32_overflow_mid is the midpoint between the largest finite f32
// and 2^128: exact results at or beyond it round to infinity.
const f32_overflow_mid = 3.4028235677973366e38

// round_dd_to_f32 rounds a double-double pair (hi, lo) to the
// nearest f32, ties to even, by exact midpoint comparison.
fn round_dd_to_f32(hi f64, lo f64) f32 {
	if hi != hi {
		return f32(hi)
	}
	if hi == math.inf(1) {
		return f32(hi)
	}
	if hi == math.inf(-1) {
		return f32(hi)
	}
	if hi >= f32_overflow_mid {
		return f32(math.inf(1))
	}
	if hi <= -f32_overflow_mid {
		return f32(math.inf(-1))
	}
	y := f32(hi)
	r := (hi - f64(y)) + lo
	if r == 0.0 {
		return y
	}
	bits := math.f32_bits(y)
	mut up_bits := bits
	mut dn_bits := bits
	if y >= 0.0 {
		up_bits = bits + 1
		dn_bits = bits - 1
	} else {
		up_bits = bits - 1
		dn_bits = bits + 1
	}
	if r > 0.0 {
		up := math.f32_from_bits(up_bits)
		half := (f64(up) - f64(y)) / 2.0
		if r > half || (r == half && bits % 2 == 1) {
			return up
		}
	} else {
		dn := math.f32_from_bits(dn_bits)
		half := (f64(y) - f64(dn)) / 2.0
		if -r > half || (-r == half && bits % 2 == 1) {
			return dn
		}
	}
	return y
}


// is_inf_f32 reports whether x is positive or negative infinity.
fn is_inf_f32(x f32) bool {
	b := math.f32_bits(x)
	return b == 0x7f800000 || b == 0xff800000
}

// exp returns e^x, correctly rounded in practice (see module comment).
pub fn exp(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.exp(f64(x)))
	}
	hi, lo := f64m.exp_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// log returns the natural logarithm of x.
pub fn log(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.log(f64(x)))
	}
	hi, lo := f64m.log_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// sin returns sin(x). Accuracy for very large |x| is bounded by the
// libm argument reduction beyond 1e15, as in float64.
pub fn sin(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.sin(f64(x)))
	}
	hi, lo := f64m.sin_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// cos returns cos(x).
pub fn cos(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.cos(f64(x)))
	}
	hi, lo := f64m.cos_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// tan returns tan(x).
pub fn tan(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.tan(f64(x)))
	}
	hi, lo := f64m.tan_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// exp2 returns 2^x.
pub fn exp2(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.exp2(f64(x)))
	}
	hi, lo := f64m.exp2_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// expm1 returns e^x - 1, accurate for x near zero.
pub fn expm1(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.expm1(f64(x)))
	}
	hi, lo := f64m.expm1_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// log2 returns the base-2 logarithm of x.
pub fn log2(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.log2(f64(x)))
	}
	hi, lo := f64m.log2_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// log10 returns the base-10 logarithm of x.
pub fn log10(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.log10(f64(x)))
	}
	hi, lo := f64m.log10_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// log1p returns log(1 + x), accurate for x near zero.
pub fn log1p(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.log1p(f64(x)))
	}
	hi, lo := f64m.log1p_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// asin returns arcsin(x).
pub fn asin(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.asin(f64(x)))
	}
	hi, lo := f64m.asin_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// acos returns arccos(x).
pub fn acos(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.acos(f64(x)))
	}
	hi, lo := f64m.acos_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// atan returns arctan(x).
pub fn atan(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.atan(f64(x)))
	}
	hi, lo := f64m.atan_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// sinh returns sinh(x).
pub fn sinh(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.sinh(f64(x)))
	}
	hi, lo := f64m.sinh_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// cosh returns cosh(x).
pub fn cosh(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.cosh(f64(x)))
	}
	hi, lo := f64m.cosh_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}

// tanh returns tanh(x).
pub fn tanh(x f32) f32 {
	if x != x || is_inf_f32(x) {
		return f32(math.tanh(f64(x)))
	}
	hi, lo := f64m.tanh_dd(f64(x))
	return round_dd_to_f32(hi, lo)
}
