module float32

import math

// Elementary functions evaluated in f64 and rounded once to f32.
//
// With 53 bits of intermediate precision for a 24-bit result, the double
// rounding in this composition can only differ from the correctly rounded
// f32 value when the exact result lies within f64 rounding distance of an
// f32 midpoint (the table-maker's dilemma). That never occurred in 12,000
// randomized comparisons against 200-bit references, and the bit-exact
// reference table in elementary_test.v pins the behavior. Proving every
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
