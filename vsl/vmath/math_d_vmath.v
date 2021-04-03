module vmath

import vsl.vmath.vimpl

// Returns the absolute value.
[inline]
pub fn abs(a f64) f64 {
	return vimpl.abs(a)
}

// acos calculates inverse cosine (arccosine).
[inline]
pub fn acos(a f64) f64 {
	return vimpl.acos(a)
}

// asin calculates inverse sine (arcsine).
[inline]
pub fn asin(a f64) f64 {
	return vimpl.asin(a)
}

// atan calculates inverse tangent (arctangent).
[inline]
pub fn atan(a f64) f64 {
	return vimpl.atan(a)
}

// atan2 calculates inverse tangent with two arguments, returns the angle between the X axis and the point.
[inline]
pub fn atan2(a f64, b f64) f64 {
	return vimpl.atan2(a, b)
}

// cbrt calculates cubic root.
[inline]
pub fn cbrt(a f64) f64 {
	return vimpl.cbrt(a)
}

// ceil returns the nearest f64 greater or equal to the provided value.
[inline]
pub fn ceil(a f64) f64 {
	return vimpl.ceil(a)
}

// copysign returns a value with the magnitude of x and the sign of y
[inline]
pub fn copysign(x f64, y f64) f64 {
	return vimpl.copysign(x, y)
}

// cos calculates cosine.
[inline]
pub fn cos(a f64) f64 {
	return vimpl.cos(a)
}

// cosh calculates hyperbolic cosine.
[inline]
pub fn cosh(a f64) f64 {
	return vimpl.cosh(a)
}

// degrees convert from degrees to radians.
[inline]
pub fn degrees(radians f64) f64 {
	return vimpl.degrees(radians)
}

// digits returns an array of the digits of n in the given base.
[inline]
pub fn digits(n int, base int) []int {
	return vimpl.digits(n, base)
}

// exp calculates exponent of the number (vimpl.pow(vimpl.E, a)).
[inline]
pub fn exp(a f64) f64 {
	return vimpl.exp(a)
}

// erf computes the error function value
[inline]
pub fn erf(a f64) f64 {
	return vimpl.erf(a)
}

// erfc computes the complementary error function value
[inline]
pub fn erfc(a f64) f64 {
	return vimpl.erfc(a)
}

// exp2 returns the base-2 exponential function of a (vimpl.pow(2, a)).
[inline]
pub fn exp2(a f64) f64 {
	return vimpl.exp2(a)
}

// factorial calculates the factorial of the provided value.
pub fn factorial(n f64) f64 {
	return vimpl.factorial(n)
}

// log_factorial calculates the log-factorial of the provided value.
pub fn log_factorial(n f64) f64 {
	return vimpl.log_factorial(n)
}

// floor returns the nearest f64 lower or equal of the provided value.
[inline]
pub fn floor(a f64) f64 {
	return vimpl.floor(a)
}

[inline]
pub fn fmod(x f64, y f64) f64 {
	return vimpl.fmod(x, y)
}

// gamma computes the gamma function value
[inline]
pub fn gamma(a f64) f64 {
	return vimpl.gamma(a)
}

// gcd calculates greatest common (positive) divisor (or zero if a and b are both zero).
[inline]
pub fn gcd(a i64, b i64) i64 {
	return vimpl.gcd(a, b)
}

// Returns hypotenuse of a right triangle.
[inline]
pub fn hypot(a f64, b f64) f64 {
	return vimpl.hypot(a, b)
}

// lcm calculates least common (non-negative) multiple.
[inline]
pub fn lcm(a i64, b i64) i64 {
	return vimpl.lcm(a, b)
}

// log calculates natural (base-e) logarithm of the provided value.
[inline]
pub fn log(a f64) f64 {
	return vimpl.log(a)
}

// log2 calculates base-2 logarithm of the provided value.
[inline]
pub fn log2(a f64) f64 {
	return vimpl.log2(a)
}

// log10 calculates the common (base-10) logarithm of the provided value.
[inline]
pub fn log10(a f64) f64 {
	return vimpl.log10(a)
}

// log_gamma computes the log-gamma function value
[inline]
pub fn log_gamma(a f64) f64 {
	return vimpl.log_gamma(a)
}

// log_n calculates base-N logarithm of the provided value.
[inline]
pub fn log_n(a f64, b f64) f64 {
	return vimpl.log_n(a, b)
}

// max returns the maximum value of the two provided.
[inline]
pub fn max(a f64, b f64) f64 {
	return vimpl.max(a, b)
}

// min returns the minimum value of the two provided.
[inline]
pub fn min(a f64, b f64) f64 {
	return vimpl.min(a, b)
}

// mod returns the floating-point remainder of number / denom (rounded towards zero):
[inline]
pub fn mod(a f64, b f64) f64 {
	return vimpl.mod(a, b)
}

// pow returns base raised to the provided power.
[inline]
pub fn pow(a f64, b f64) f64 {
	return vimpl.pow(a, b)
}

// radians convert from radians to degrees.
[inline]
pub fn radians(degrees f64) f64 {
	return vimpl.radians(degrees)
}

// round returns the integer nearest to the provided value.
[inline]
pub fn round(f f64) f64 {
	return vimpl.round(f)
}

// signbit returns a value with the boolean representation of the sign for x
[inline]
pub fn signbit(x f64) bool {
	return signbit(x)
}

// sin calculates sine.
[inline]
pub fn sin(a f64) f64 {
	return vimpl.sin(a)
}

// sinh calculates hyperbolic sine.
[inline]
pub fn sinh(a f64) f64 {
	return vimpl.sinh(a)
}

// sqrt calculates square-root of the provided value.
[inline]
pub fn sqrt(a f64) f64 {
	return vimpl.sqrt(a)
}

// tan calculates tangent.
[inline]
pub fn tan(a f64) f64 {
	return vimpl.tan(a)
}

// tanh calculates hyperbolic tangent.
[inline]
pub fn tanh(a f64) f64 {
	return vimpl.tanh(a)
}

// trunc rounds a toward zero, returning the nearest integral value that is not
// larger in magnitude than a.
[inline]
pub fn trunc(a f64) f64 {
	return vimpl.trunc(a)
}
