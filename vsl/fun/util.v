module fun

import vsl.vmath as math

fn tolerance(a f64, b f64, tol f64) bool {
	mut e_ := tol
	// Multiplying by e_ here can underflow denormal values to zero.
	// Check a==b so that at least if a and b are small and identical
	// we say they match.
	if a == b {
		return true
	}
	mut d := a - b
	if d < 0 {
		d = -d
	}
	// note: b is correct (expected) value, a is actual value.
	// make error tolerance a fraction of b, not a.
	if b != 0 {
		e_ = e_ * b
		if e_ < 0 {
			e_ = -e_
		}
	}
	return d < e_
}

fn close(a f64, b f64) bool {
	return tolerance(a, b, 1e-14)
}

fn veryclose(a f64, b f64) bool {
	return tolerance(a, b, 4e-16)
}

fn soclose(a f64, b f64, e_ f64) bool {
	return tolerance(a, b, e_)
}

fn alike(a f64, b f64) bool {
	if math.is_nan(a) && math.is_nan(b) {
		return true
	} else if a == b {
		return math.signbit(a) == math.signbit(b)
	}
	return false
}
