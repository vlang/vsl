module fun

import vsl.vmath as math
import vsl.internal

// data for a Chebyshev series over a given interval
pub struct ChebSeries {
pub:
	c     []f64 // coefficients
	order int   // order of expansion
	a     f64   // lower interval point
	b     f64   // upper interval point
}

pub fn (cs ChebSeries) eval_e(x f64) (f64, f64) {
	mut d := 0.0
	mut dd := 0.0
	y := (2.0 * x - cs.a - cs.b) / (cs.b - cs.a)
	y2 := 2.0 * y
	mut e := 0.0
	mut temp := 0.0
	for j := cs.order; j >= 1; j-- {
		temp = d
		d = y2 * d - dd + cs.c[j]
		e += math.abs(y2 * temp) + math.abs(dd) + math.abs(cs.c[j])
		dd = temp
	}
	temp = d
	d = y * d - dd + 0.5 * cs.c[0]
	e += math.abs(y * temp) + math.abs(dd) + 0.5 * math.abs(cs.c[0])
	return d, f64(internal.f64_epsilon) * e + math.abs(cs.c[cs.order])
}
