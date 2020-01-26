// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

module math

// special cases are:
//	sqrt(+inf) = +inf
//	sqrt(±0) = ±0
//	sqrt(x < 0) = nan
//	sqrt(nan) = nan
pub fn sqrt(x_ f64) f64 {
        mut x := x_
	if x == f64(0.0) || is_nan(x) || is_inf(x, 1) {
		return x
        }
	if x < f64(0.0) {
		return nan()
	}
	z, e := frexp(x)
	w := x

        // approximate square root of number between 0.5 and 1
        // relative error of approximation = 7.47e-3
        x = 4.173075996388649989089e-1 + 5.9016206709064458299663e-1 * z

        /* adjust for odd powers of 2 */
        if (e & 1) != 0 {
                x *= sqrt2
        }

        x = ldexp(x, e >> 1)

        // newton iterations
        x = 0.5*(x + w/x)
        x = 0.5*(x + w/x)
        x = 0.5*(x + w/x)
        
        return x
}
