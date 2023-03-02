module roots

import vsl.errors
import vsl.func
import math

// Find the root of a function using a bisection method
pub fn bisection(f func.Fn, xmin f64, xmax f64, epsrel f64, epsabs f64, n_max int) !f64 {
	fxmin := f.safe_eval(xmin)?
	fxmax := f.safe_eval(xmax)?
	if (fxmin < 0.0 && fxmax < 0.0) || (fxmin > 0.0 && fxmax > 0.0) {
		return errors.error('endpoints do not straddle y=0', .einval)
	}
	mut a := xmin
	mut b := xmax
	if fxmin > 0.0 {
		a = xmax
		b = xmin
	}
	// mut fa := f.safe_eval(a)?
	// mut fb := f.safe_eval(b)?
	mut i := 0
	for i < n_max {
		c := (a + b) / 2.0
		fc := f.safe_eval(c)?
		if fc < 0.0 {
			a = c
			// fa = fc
		} else {
			b = c
			// fb = fc
		}
		if math.abs(b - a) < epsabs + epsrel * math.abs(a) {
			break
		}
		i++
	} // maximum number of iterations reached
	if i == n_max {
		return error('maximum number of iterations reached')
	}
	return (a + b) / 2.0
}
