module roots

import vsl.errors
import vsl.vmath
import vsl.internal
import vsl

const (
	itmax = 100
)

// Search for the root of func in the interval [x1, x2] with a
// given tolerance
pub fn brent(func vsl.Fn, x1 f64, x2 f64, tol f64) ?(f64, f64) {
	mut a := x1
	mut b := x2
	mut c := a
	mut fa := func.eval(a)
	mut fb := func.eval(b)
	mut fc := fa
	if (fa > 0.0 && fb > 0.0) || (fa < 0.0 && fb < 0.0) {
		return errors.vsl_error('roots must be bracketed', .einval)
	}
	// Test if one the endpoints is the root
	if fa == 0.0 {
		return a, 0.0
	}
	if fb == 0.0 {
		return b, 0.0
	}
	mut prev_step := b - a
	mut tol1 := tol
	mut p := 0.0
	mut q := 0.0
	mut r := 0.0
	for iter := 1; iter <= roots.itmax; iter++ {
		prev_step = b - a
		if vmath.abs(fc) < vmath.abs(fb) {
			a = b
			b = c
			c = a
			fa = fb
			fb = fc
			fc = fa
		}
		tol1 = 2.0 * internal.f64_epsilon * vmath.abs(b) + 0.5 * tol
		mut new_step := 0.5 * (c - b)
		if vmath.abs(new_step) <= tol1 || fb == 0.0 {
			return b, vmath.abs(c - b)
		}
		// decide if the interpolation can be tried. if prev_step was
		// large enough and in the right direction
		if vmath.abs(prev_step) >= tol1 && vmath.abs(fa) > vmath.abs(fb) {
			s := fb / fa
			if a == c {
				// if we only have two distinct points, only linear
				// interpolation can be applied
				p = 2.0 * new_step * s
				q = 1.0 - s
			} else { // Quadratic inverse interpolation
				q = fa / fc
				r = fb / fc
				p = s * (2.0 * new_step * q * (q - r) - (b - a) * (r - 1.0))
				q = (q - 1.0) * (r - 1.0) * (s - 1.0)
			}
			// p was calculated with the oppposite sign make p positive and
			// assign the possible minus to q
			if p > 0.0 {
				q = -q
			} else {
				p = -p
			}
			// if b+p/q falls in [b,c] and isn't too large, it is accepted. If
			// p/q is too large the the bisection procedure can reduce [b,c] more
			// significantly
			if 2.0 * p < 3.0 * new_step * q - vmath.abs(tol1 * q)
				&& 2.0 * p < vmath.abs(prev_step * q) {
				new_step = p / q
			} else {
				new_step = 0.5 * (c - b)
				prev_step = new_step
			}
		}
		// adjust the step to be not less than tolerance
		if vmath.abs(new_step) < tol1 {
			new_step = if new_step > 0 { tol1 } else { -tol1 }
		}
		a = b
		fa = fb
		b += new_step
		fb = func.eval(b) // adjust c to have the opposite sign of b
		if (fb < 0 && fc < 0) || (fb > 0 && fc > 0) {
			c = a
			fc = fa
		}
	}
	return b, vmath.abs(c - b)
}
