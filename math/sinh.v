// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

module math

#include <math.h>
fn C.sinh(a f64) f64

// sinh calculates hyperbolic sine.
pub fn sinh(a f64) f64 {
	return C.sinh(a)
}

pub fn cosh(x f64) f64 {
	abs_x := abs(x)
	if abs_x > 21 {
		return exp(abs_x) * 0.5
	}
	ex := exp(abs_x)
	return (ex + 1.0/ex) * 0.5
}
