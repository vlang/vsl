// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module math

// gamma function computed by Stirling's formula.
// The pair of results must be multiplied together to get the actual answer.
// The multiplication is left to the caller so that, if careful, the caller can avoid
// infinity for 172 <= x <= 180.
// The polynomial is valid for 33 <= x <= 172; larger values are only used
// in reciprocal and produce denormalized floats. The lower precision there
// masks any imprecision in the polynomial.
fn stirling(x f64) (f64, f64) {
	if x > 200 {
		return inf(1), f64(1.0)
	}
        sqrt_two_pi  := 2.506628274631000502417
        max_stirling := 143.01608
	mut w := f64(1) / x
	w = f64(1) + w*((((GAMMA_S[0]*w+GAMMA_S[1])*w+GAMMA_S[2])*w+GAMMA_S[3])*w+GAMMA_S[4])
	mut y1 := exp(x)
	mut y2 := f64(1)
	if x > max_stirling { // avoid Pow() overflow
		v := pow(x, 0.5*x-0.25)
                y1_ := y1
		y1 = v
                y2 = v/y1_
	} else {
		y1 = pow(x, x-0.5) / y1
	}
	return y1, f64(sqrt_two_pi) * w * y2
}

// gamma returns the gamma function of x.
//
// special cases are:
//	gamma(+inf) = +inf
//	gamma(+0) = +inf
//	gamma(-0) = -inf
//	gamma(x) = nan for integer x < 0
//	gamma(-inf) = nan
//	gamma(nan) = nan
pub fn gamma(x_ f64) f64 {
        mut x := x_
	euler := 0.57721566490153286060651209008240243104215933593992 // A001620
	if is_neg_int(x) || is_inf(x, -1) || is_nan(x) {
		return nan()
        }
	if is_inf(x, 1) {
		return inf(1)
        }
	if x == 0.0 {
		return copysign(inf(1), x)
	}
	mut q := abs(x)
	mut p := floor(q)
	if q > 33 {
		if x >= 0 {
			y1, y2 := stirling(x)
			return y1 * y2
		}
		// Note: x is negative but (checked above) not a negative integer,
		// so x must be small enough to be in range for conversion to i64.
		// If |x| were >= 2⁶³ it would have to be an integer.
		mut signgam := 1
                ip := i64(p)
		if (ip & 1) == 0 {
			signgam = -1
		}
		mut z := q - p
		if z > 0.5 {
			p = p + 1
			z = q - p
		}
		z = q * sin(pi*z)
		if z == 0 {
			return inf(signgam)
		}
		sq1, sq2 := stirling(q)
		absz := abs(z)
		d := absz * sq1 * sq2
		if is_inf(d, 0) {
			z = pi / absz / sq1 / sq2
		} else {
			z = pi / d
		}
		return f64(signgam) * z
	}

	// Reduce argument
	mut z := 1.0
	for x >= 3 {
		x = x - 1
		z = z * x
	}
	for x < 0 {
		if x > -1e-09 {
			goto small
		}
		z = z / x
		x = x + 1
	}
	for x < 2 {
		if x < 1e-09 {
			goto small
		}
		z = z / x
		x = x + 1
	}

	if x == 2 {
		return z
	}

	x = x - 2
	p = (((((x*GAMMA_P[0]+GAMMA_P[1])*x+GAMMA_P[2])*x+GAMMA_P[3])*x+GAMMA_P[4])*x+GAMMA_P[5])*x + GAMMA_P[6]
	q = ((((((x*GAMMA_Q[0]+GAMMA_Q[1])*x+GAMMA_Q[2])*x+GAMMA_Q[3])*x+GAMMA_Q[4])*x+GAMMA_Q[5])*x+GAMMA_Q[6])*x + GAMMA_Q[7]
	if true {
                return z * p / q
        }

small:
	if x == 0 {
		return inf(1)
	}
	return z / ((1.0 + euler*x) * x)
}

