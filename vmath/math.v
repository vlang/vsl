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
pub fn cot(x f64) f64 {
	return vimpl.cot(x)
}

[inline]
pub fn expm1(x f64) f64 {
	return vimpl.expm1(x)
}

[inline]
pub fn ilog_b(x f64) int {
	return vimpl.ilog_b(x)
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
pub fn log1p(x f64) f64 {
	return vimpl.log1p(x)
}

[inline]
pub fn log_b(x f64) f64 {
	return vimpl.log_b(x)
}

[inline]
pub fn log_gamma_sign(x f64) (f64, int) {
	return vimpl.log_gamma_sign(x)
}

[inline]
pub fn minmax(a f64, b f64) (f64, f64) {
	return vimpl.minmax(a, b)
}

[inline]
pub fn nextafter(x f64, y f64) f64 {
	return vimpl.nextafter(x, y)
}

[inline]
pub fn nextafter32(x f32, y f32) f32 {
	return vimpl.nextafter32(x, y)
}

// modf returns integer and fractional floating-point numbers
// that sum to f. Both values have the same sign as f.
[inline]
pub fn modf(f f64) (f64, f64) {
	return vimpl.modf(f)
}

[inline]
pub fn round_to_even(x f64) f64 {
	return vimpl.round_to_even(x)
}

[inline]
pub fn pow10(n int) f64 {
	return vimpl.pow10(n)
}

[inline]
pub fn sincos(x f64) (f64, f64) {
	return vimpl.sincos(x)
}
