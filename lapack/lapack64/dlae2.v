module lapack64

import math

// dlae2 computes the eigenvalues of a 2×2 symmetric matrix
//
//  [a b]
//  [b c]
//
// and returns the eigenvalue with the larger absolute value as rt1 and the
// smaller as rt2.
//
// dlae2 is an internal routine. It is exported for testing purposes.
pub fn dlae2(a f64, b f64, c f64) (f64, f64) {
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
		rt = adf * math.sqrt(1.0 + (ab / adf) * (ab / adf))
	} else if adf < ab {
		rt = ab * math.sqrt(1.0 + (adf / ab) * (adf / ab))
	} else {
		rt = ab * math.sqrt(2.0)
	}
	mut rt1 := 0.0
	mut rt2 := 0.0
	if sm < 0 {
		rt1 = 0.5 * (sm - rt)
		rt2 = (acmx / rt1) * acmn - (b / rt1) * b
	} else if sm > 0 {
		rt1 = 0.5 * (sm + rt)
		rt2 = (acmx / rt1) * acmn - (b / rt1) * b
	} else {
		rt1 = 0.5 * rt
		rt2 = -0.5 * rt
	}
	return rt1, rt2
}
