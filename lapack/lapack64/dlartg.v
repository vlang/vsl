module lapack64

import math

// dlartg generates a plane rotation so that
//
//	[ cs sn] * [f] = [r]
//	[-sn cs]   [g] = [0]
//
// where cs*cs + sn*sn = 1.
//
// This is a more accurate version of BLAS Drotg that uses scaling to avoid
// overflow or underflow, with the other differences that
//   - cs >= 0
//   - if g = 0, then cs = 1 and sn = 0
//   - if f = 0 and g != 0, then cs = 0 and sn = sign(1,g)
//
// dlartg is an internal routine. It is exported for testing purposes.
pub fn dlartg(f f64, g f64) (f64, f64, f64) {
	if g == 0 {
		return 1, 0, f
	}

	g1 := math.abs(g)

	if f == 0 {
		return 0, math.copysign(1, g), g1
	}

	safmin := dlamch_s
	safmax := 1 / safmin
	rtmin := math.sqrt(safmin)
	rtmax := math.sqrt(safmax / 2)

	f1 := math.abs(f)

	if rtmin < f1 && f1 < rtmax && rtmin < g1 && g1 < rtmax {
		d := math.sqrt(f * f + g * g)
		cs := f1 / d
		r := math.copysign(d, f)
		sn := g / r

		return cs, sn, r
	}

	u := math.min(math.max(safmin, math.max(f1, g1)), safmax)
	fs := f / u
	gs := g / u
	d := math.sqrt(fs * fs + gs * gs)
	cs := math.abs(fs) / d
	mut r := math.copysign(d, f)
	sn := gs / r
	r *= u

	return cs, sn, r
}
