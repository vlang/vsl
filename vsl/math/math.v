// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module math

#include <math.h>
fn C.acos(x f64) f64


fn C.asin(x f64) f64


fn C.cbrt(x f64) f64


fn C.cosh(x f64) f64


fn C.erf(x f64) f64


fn C.erfc(x f64) f64


fn C.exp(x f64) f64


fn C.exp2(x f64) f64


fn C.log2(x f64) f64


fn C.log10(x f64) f64


fn C.lgamma(x f64) f64


fn C.pow(x f64, y f64) f64


fn C.sinh(x f64) f64


fn C.sqrt(x f64) f64


fn C.tgamma(x f64) f64


fn C.tan(x f64) f64


fn C.tanh(x f64) f64


// acos calculates inverse cosine (arccosine).
pub fn acos(a f64) f64 {
	return C.acos(a)
}

// asin calculates inverse sine (arcsine).
pub fn asin(a f64) f64 {
	return C.asin(a)
}

// cbrt calculates cubic root.
pub fn cbrt(a f64) f64 {
	return C.cbrt(a)
}

// cosh calculates hyperbolic cosine.
pub fn cosh(a f64) f64 {
	return C.cosh(a)
}

// degrees convert from degrees to radians.
pub fn degrees(radians f64) f64 {
	return radians * (180.0 / pi)
}

// exp calculates exponent of the number (math.pow(math.E, a)).
pub fn exp(a f64) f64 {
	return C.exp(a)
}

// erf computes the error function value
pub fn erf(a f64) f64 {
	return C.erf(a)
}

// erfc computes the complementary error function value
pub fn erfc(a f64) f64 {
	return C.erfc(a)
}

// exp2 returns the base-2 exponential function of a (math.pow(2, a)).
pub fn exp2(a f64) f64 {
	return C.exp2(a)
}

// gamma computes the gamma function value
pub fn gamma(a f64) f64 {
	return C.tgamma(a)
}

// log2 calculates base-2 logarithm of the provided value.
pub fn log2(a f64) f64 {
	return C.log2(a)
}

// log10 calculates the common (base-10) logarithm of the provided value.
pub fn log10(a f64) f64 {
	return C.log10(a)
}

// log_gamma computes the log-gamma function value
pub fn log_gamma(a f64) f64 {
	return C.lgamma(a)
}

// pow returns base raised to the provided power.
pub fn pow(a, b f64) f64 {
	return C.pow(a, b)
}

// radians convert from radians to degrees.
pub fn radians(degrees f64) f64 {
	return degrees * (pi / 180.0)
}

// sinh calculates hyperbolic sine.
pub fn sinh(a f64) f64 {
	return C.sinh(a)
}

// sqrt calculates square-root of the provided value.
pub fn sqrt(a f64) f64 {
	return C.sqrt(a)
}

// tan calculates tangent.
pub fn tan(a f64) f64 {
	return C.tan(a)
}

// tanh calculates hyperbolic tangent.
pub fn tanh(a f64) f64 {
	return C.tanh(a)
}
