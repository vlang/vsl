module lapack64

import math

pub fn dlaev2(a f64, b f64, c f64) (f64, f64, f64, f64) {
	sm := a + c
	df := a - c
	adf := math.abs(df)
	tb := b + b
	ab := math.abs(tb)
	mut acmx := c
	mut acmn := a
	if math.abs(a) > math.abs(c) {
		acmx = a
		acmn = c
	}
	mut rt := 0.0
	if adf > ab {
		rt = adf * math.sqrt(1 + (ab / adf) * (ab / adf))
	} else if adf < ab {
		rt = ab * math.sqrt(1 + (adf / ab) * (adf / ab))
	} else {
		rt = ab * math.sqrt(2)
	}
	mut rt1 := 0.0
	mut rt2 := 0.0
	mut cs1 := 0.0
	mut sn1 := 0.0
	mut sgn1 := 0.0
	if sm < 0 {
		rt1 = 0.5 * (sm - rt)
		sgn1 = -1
		rt2 = (acmx / rt1) * acmn - (b / rt1) * b
	} else if sm > 0 {
		rt1 = 0.5 * (sm + rt)
		sgn1 = 1
		rt2 = (acmx / rt1) * acmn - (b / rt1) * b
	} else {
		rt1 = 0.5 * rt
		rt2 = -0.5 * rt
		sgn1 = 1
	}
	mut cs := 0.0
	mut sgn2 := 0.0
	if df >= 0 {
		cs = df + rt
		sgn2 = 1
	} else {
		cs = df - rt
		sgn2 = -1
	}
	acs := math.abs(cs)
	if acs > ab {
		ct := -tb / cs
		sn1 = 1 / math.sqrt(1 + ct * ct)
		cs1 = ct * sn1
	} else {
		if ab == 0 {
			cs1 = 1
			sn1 = 0
		} else {
			tn := -cs / tb
			cs1 = 1 / math.sqrt(1 + tn * tn)
			sn1 = tn * cs1
		}
	}
	if sgn1 == sgn2 {
		tn := cs1
		cs1 = -sn1
		sn1 = tn
	}
	return rt1, rt2, cs1, sn1
}
