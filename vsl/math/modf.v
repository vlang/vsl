// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

module math

// modf returns integer and fractional floating-point numbers
// that sum to f. Both values have the same sign as f.
//
// Special cases are:
//	modf(±Inf) = ±Inf, NaN
//	modf(NaN) = NaN, NaN
pub fn modf(f f64) (f64,f64) {
	if f < 1 {
		if f < 0 {
			i, frac := modf(-f)
			return -i, -frac
                }
		if f == 0 {
			return f, f // Return -0, -0 when f == -0
		}
		return f64(0.0), f
	}

	mut x := f64_bits(f)
	e := (x>>shift)&mask - bias

	// Keep the top 12+e bits, the integer part; clear the rest.
	if e < 64-12 {
		x &= 1<<(64-12-e) - 1
		x ^= 1<<(64-12-e) - 1
	}
	i := f64_from_bits(x)
	frac := f - i
	return i, frac
}
