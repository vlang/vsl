module vmath

import vsl.vmath.vimpl

[inline]
pub fn acosh(x f64) f64 {
	return vimpl.acosh(x)
}

[inline]
pub fn asinh(x f64) f64 {
	return vimpl.asinh(x)
}

[inline]
pub fn atanh(x f64) f64 {
	return vimpl.atanh(x)
}

[inline]
pub fn expm1(x f64) f64 {
	return vimpl.expm1(x)
}

[inline]
pub fn frexp(x f64) (f64, int) {
	return vimpl.frexp(x)
}

[inline]
pub fn ldexp(x f64, e int) f64 {
	return vimpl.ldexp(x, e)
}

[inline]
pub fn log_gamma_sign(x f64) (f64, int) {
	return vimpl.log_gamma_sign(x)
}

[inline]
pub fn minmax(a f64, b f64) (f64, f64) {
	return vimpl.minmax(a, b)
}

// modf returns integer and fractional floating-point numbers
// that sum to f. Both values have the same sign as f.
[inline]
pub fn modf(f f64) (f64, f64) {
	return vimpl.modf(f)
}

[inline]
pub fn sincos(x f64) (f64, f64) {
	return vimpl.sincos(x)
}
