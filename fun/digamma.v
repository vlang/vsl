module fun

import math
import vsl.poly

@[inline]
pub fn digamma(x f64) f64 {
	return psi(x)
}

pub fn psi(x_ f64) f64 {
	mut x := x_
	mut negative := false
	mut nz := 0.0
	mut y := 0.0
	if x <= 0.0 {
		negative = true
		q := x
		mut p := math.floor(q)
		if p == q {
			return math.max_f64
		}
		// Remove the zeros of tan(PI x)
		// by subtracting the nearest integer from x
		nz = q - p
		if nz != 0.5 {
			if nz > 0.5 {
				p += 1.0
				nz = q - p
			}
			nz = math.pi / math.tan(math.pi * nz)
		} else {
			nz = 0.0
		}
		x = 1.0 - x
	}
	// check for positive integer up to 10
	if x <= 10.0 && x == math.floor(x) {
		y = 0.0
		n := int(x)
		for i := 1; i < n; i++ {
			w := f64(i)
			y += 1.0 / w
		}
		y -= eul
		unsafe {
			goto done
		}
	}
	mut s := x
	mut w := 0.0
	for s < 10.0 {
		w += 1.0 / s
		s += 1.0
	}
	if s < 1.0e+17 {
		z := 1.0 / (s * s)
		y = z * poly.eval(digamma_a, z)
	} else {
		y = 0.0
	}
	y = math.log(s) - (0.5 / s) - y - w
	done:
	if negative {
		y -= nz
	}
	return y
}
