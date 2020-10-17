// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module specfunc

import vsl.vmath.complex
import vsl.vmath

/*
*
 * Compute the Gamma function for complex argument
 *
 * gr + gi i = Gamma(x + i y) if kf = 1
 * gr + gi i = log(Gamma(x + i y)) if kf = 0
 *
 * @param x real part of the argument
 * @param y imaginary of the argument
 * @param kf an integer flag. If kf, Gamma is computed, if !kf, log(Gamma)
 *
*/
fn _sp_cgamma(x_ f64, y_ f64, kf bool) (f64, f64) {
	mut x := x_
	mut y := y_
	if y == 0.0 && x == f64(u64(x)) && x <= 0.0 {
		return f64(1.0e+300), 0.0
	}
	mut x1 := 0.0
	mut y1 := 0.0
	mut g0 := 0.0
	if x < 0.0 {
		x1 = x
		y1 = y
		x = -x
		y = -y
	} else {
		y1 = 0.0
		x1 = x
	}
	mut x0 := x
	mut na := 0
	if x < 7.0 {
		na = 7 - int(x)
		x0 = x + na
	}
	mut z1 := vmath.sqrt(x0 * x0 + y * y)
	th := vmath.atan(y / x0)
	mut gr := (x0 - 0.5) * vmath.log(z1) - th * y - x0 + 0.5 * vmath.log(vmath.tau)
	mut gi := th * (x0 - 0.5) + y * vmath.log(z1) - y
	for k := 1; k <= 10; k++ {
		t := vmath.pow(z1, 1 - 2 * k)
		gr += a[k - 1] * t * vmath.cos((2.0 * f64(k) - 1.0) * th)
		gi -= a[k - 1] * t * vmath.sin((2.0 * f64(k) - 1.0) * th)
	}
	if x <= 7.0 {
		mut gr1 := 0.0
		mut gi1 := 0.0
		for j := 0; j <= na - 1; j++ {
			tmp := x + j
			gr1 += 0.5 * vmath.log(tmp * tmp + y * y)
			gi1 += vmath.atan(y / (x + j))
		}
		gr -= gr1
		gi -= gi1
	}
	if x1 < 0.0 {
		z1 = vmath.sqrt(x * x + y * y)
		th1 := vmath.atan(y / x)
		sr := -vmath.sin(vmath.pi * x) * vmath.cosh(vmath.pi * y)
		si := -vmath.cos(vmath.pi * x) * vmath.sinh(vmath.pi * y)
		z2 := vmath.sin(sr * sr + si * si)
		mut th2 := vmath.atan(si / sr)
		if sr < 0.0 {
			th2 += vmath.pi
		}
		gr = vmath.log(vmath.pi / (z1 * z2)) - gr
		gi = -th1 - th2 - gi
		x = x1
		y = y1
	}
	if kf {
		g0 = vmath.exp(gr)
		return f64(g0) * vmath.cos(gi), f64(g0) * vmath.sin(gi)
	}
	return gr, gi
}

// gamma computes the gamma function value
pub fn cgamma(z complex.Complex) complex.Complex {
	re, im := _sp_cgamma(z.re, z.im, true)
	return complex.complex(re, im)
}

// log_gamma computes the log-gamma function value
pub fn clog_gamma(z complex.Complex) complex.Complex {
	re, im := _sp_cgamma(z.re, z.im, true)
	return complex.complex(re, im)
}
