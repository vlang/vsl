module vmath

import vsl.vmath.vimpl

// inf returns positive infinity if sign >= 0, negative infinity if sign < 0.
pub fn inf(sign int) f64 {
	return vimpl.inf(sign)
}

// nan returns an IEEE 754 ``not-a-number'' value.
pub fn nan() f64 {
	return vimpl.nan()
}

// is_nan reports whether f is an IEEE 754 ``not-a-number'' value.
pub fn is_nan(f f64) bool {
	return vimpl.is_nan(f)
}

// is_inf reports whether f is an infinity, according to sign.
// If sign > 0, is_inf reports whether f is positive infinity.
// If sign < 0, is_inf reports whether f is negative infinity.
// If sign == 0, is_inf reports whether f is either infinity.
pub fn is_inf(f f64, sign int) bool {
	return vimpl.is_inf(f, sign)
}

pub fn is_finite(f f64) bool {
	return vimpl.is_finite(f)
}

// normalize returns a normal number y and exponent exp
// satisfying x == y × 2**exp. It assumes x is finite and non-zero.
pub fn normalize(x f64) (f64, int) {
	return vimpl.normalize(x)
}
