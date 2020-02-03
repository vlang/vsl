// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module math

#include <math.h>
fn C.exp(x f64) f64


fn C.exp2(x f64) f64


fn C.lgamma(x f64) f64


fn C.tanh(x f64) f64


fn C.tgamma(x f64) f64

// degrees convert from degrees to radians.
pub fn degrees(radians f64) f64 {
	return radians * (180.0 / pi)
}

// exp calculates exponent of the number (math.pow(math.E, a)).
pub fn exp(a f64) f64 {
	return C.exp(a)
}

// exp2 returns the base-2 exponential function of a (math.pow(2, a)).
pub fn exp2(a f64) f64 {
	return C.exp2(a)
}

// gamma computes the gamma function value
pub fn gamma(a f64) f64 {
	return C.tgamma(a)
}

// log_gamma computes the log-gamma function value
pub fn log_gamma(a f64) f64 {
	return C.lgamma(a)
}

// radians convert from radians to degrees.
pub fn radians(degrees f64) f64 {
	return degrees * (pi / 180.0)
}

// tanh calculates hyperbolic tangent.
pub fn tanh(a f64) f64 {
	return C.tanh(a)
}
