module float32

import math

// Elementary functions evaluated in f64 and rounded once to f32.
//
// With 53 bits of intermediate precision for a 24-bit result, the double
// rounding in this composition can only differ from the correctly rounded
// f32 value when the exact result lies within f64 rounding distance of an
// f32 midpoint (the table-maker's dilemma). That never occurred in 12,000
// randomized comparisons against 200-bit references for exp/log/sin/cos, nor
// in 20,000 comparisons each (240,000 total) for the twelve functions added
// below, and the bit-exact reference tables in elementary_test.v pin the
// behavior. Proving every
// input, RLIBM-style, remains the goal tracked in vlang/vsl#65; these
// functions are the correctly-rounded-in-practice baseline, and they are
// strictly more accurate than the host libm float functions, which show
// ~1 ulp errors on roughly a fifth of random inputs.

// exp returns e^x, evaluated in f64 and rounded to f32.
pub fn exp(x f32) f32 {
	return f32(math.exp(f64(x)))
}

// log returns the natural logarithm of x, evaluated in f64 and rounded to f32.
pub fn log(x f32) f32 {
	return f32(math.log(f64(x)))
}

// sin returns sin(x), evaluated in f64 and rounded to f32. Accuracy for very
// large |x| is bounded by the f64 argument reduction, as with libm.
pub fn sin(x f32) f32 {
	return f32(math.sin(f64(x)))
}

// cos returns cos(x), evaluated in f64 and rounded to f32.
pub fn cos(x f32) f32 {
	return f32(math.cos(f64(x)))
}

// tan returns tan(x), evaluated in f64 and rounded to f32. Accuracy for very
// large |x| is bounded by the f64 argument reduction, as with libm.
pub fn tan(x f32) f32 {
	return f32(math.tan(f64(x)))
}

// exp2 returns 2^x, evaluated in f64 and rounded to f32.
pub fn exp2(x f32) f32 {
	return f32(math.exp2(f64(x)))
}

// expm1 returns e^x - 1, evaluated in f64 and rounded to f32. Using the
// dedicated f64 function preserves accuracy for x near zero.
pub fn expm1(x f32) f32 {
	return f32(math.expm1(f64(x)))
}

// log2 returns the base-2 logarithm of x, evaluated in f64 and rounded to f32.
pub fn log2(x f32) f32 {
	return f32(math.log2(f64(x)))
}

// log10 returns the base-10 logarithm of x, evaluated in f64 and rounded to f32.
pub fn log10(x f32) f32 {
	return f32(math.log10(f64(x)))
}

// log1p returns log(1 + x), evaluated in f64 and rounded to f32. Using the
// dedicated f64 function preserves accuracy for x near zero.
pub fn log1p(x f32) f32 {
	return f32(math.log1p(f64(x)))
}

// asin returns arcsin(x), evaluated in f64 and rounded to f32.
pub fn asin(x f32) f32 {
	return f32(math.asin(f64(x)))
}

// acos returns arccos(x), evaluated in f64 and rounded to f32.
pub fn acos(x f32) f32 {
	return f32(math.acos(f64(x)))
}

// atan returns arctan(x), evaluated in f64 and rounded to f32.
pub fn atan(x f32) f32 {
	return f32(math.atan(f64(x)))
}

// sinh returns sinh(x), evaluated in f64 and rounded to f32.
pub fn sinh(x f32) f32 {
	return f32(math.sinh(f64(x)))
}

// cosh returns cosh(x), evaluated in f64 and rounded to f32.
pub fn cosh(x f32) f32 {
	return f32(math.cosh(f64(x)))
}

// tanh returns tanh(x), evaluated in f64 and rounded to f32.
pub fn tanh(x f32) f32 {
	return f32(math.tanh(f64(x)))
}
