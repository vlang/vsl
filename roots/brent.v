module roots

import vsl.errors
import vsl.func
import vsl.internal.prec
import math

const itmax = 100

// Brent implements Brent's method for finding roots of a function
// in a given interval. The function must be continuous and the
// interval must contain a root.
pub struct Brent {
pub:
	f func.Fn @[required]
pub mut:
	x1      f64
	x2      f64
	tol     f64
	n_max   int
	n_calls int
	n_iter  int
}

// Brent.new creates a new Brent object
pub fn Brent.new(f func.Fn) &Brent {
	return &Brent{
		f:   f
		tol: 1e-6
	}
}

// BrentIteration is a single iteration of Brent's method
pub struct BrentIteration {
	x       f64
	fx      f64
	n_calls int
	n_iter  int
}

// Search for the root of func in the interval [x1, x2] with a
// given tolerance
fn brent(f func.Fn, x1 f64, x2 f64, tol f64) !(f64, f64) {
	mut a := x1
	mut b := x2
	mut c := a
	mut fa := f.eval(a)
	mut fb := f.eval(b)
	mut fc := fa
	if (fa > 0.0 && fb > 0.0) || (fa < 0.0 && fb < 0.0) {
		return errors.error('roots must be bracketed', .einval)
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
	for iter := 1; iter <= itmax; iter++ {
		prev_step = b - a
		if math.abs(fc) < math.abs(fb) {
			a = b
			b = c
			c = a
			fa = fb
			fb = fc
			fc = fa
		}
		tol1 = 2.0 * prec.f64_epsilon * math.abs(b) + 0.5 * tol
		mut new_step := 0.5 * (c - b)
		if math.abs(new_step) <= tol1 || fb == 0.0 {
			return b, math.abs(c - b)
		}
		// decide if the interpolation can be tried. if prev_step was
		// large enough and in the right direction
		if math.abs(prev_step) >= tol1 && math.abs(fa) > math.abs(fb) {
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
			if 2.0 * p < 3.0 * new_step * q - math.abs(tol1 * q)
				&& 2.0 * p < math.abs(prev_step * q) {
				new_step = p / q
			} else {
				new_step = 0.5 * (c - b)
				prev_step = new_step
			}
		}
		// adjust the step to be not less than tolerance
		if math.abs(new_step) < tol1 {
			new_step = if new_step > 0 { tol1 } else { -tol1 }
		}
		a = b
		fa = fb
		b += new_step
		fb = f.eval(b) // adjust c to have the opposite sign of b
		if (fb < 0 && fc < 0) || (fb > 0 && fc > 0) {
			c = a
			fc = fa
		}
	}
	return b, math.abs(c - b)
}
