module lapack64

import math

// dlapy2 is the LAPACK version of math.hypot.
//
// dlapy2 is an internal routine. It is exported for testing purposes.
pub fn dlapy2(x f64, y f64) f64 {
	return math.hypot(x, y)
}
