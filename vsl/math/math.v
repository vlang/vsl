// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module math

#include <math.h>
fn C.acos(x f64) f64


fn C.asin(x f64) f64


fn C.atan(x f64) f64


fn C.atan2(y f64, x f64) f64


fn C.cbrt(x f64) f64


fn C.ceil(x f64) f64


fn C.cosh(x f64) f64


fn C.erf(x f64) f64


fn C.erfc(x f64) f64


fn C.exp(x f64) f64


fn C.exp2(x f64) f64


fn C.fabs(x f64) f64


fn C.floor(x f64) f64


fn C.fmod(x f64, y f64) f64


fn C.hypot(x f64, y f64) f64


fn C.log(x f64) f64


fn C.log2(x f64) f64


fn C.log10(x f64) f64


fn C.lgamma(x f64) f64


fn C.pow(x f64, y f64) f64


fn C.round(x f64) f64


fn C.sinh(x f64) f64


fn C.sqrt(x f64) f64


fn C.tgamma(x f64) f64


fn C.tan(x f64) f64


fn C.tanh(x f64) f64


fn C.trunc(x f64) f64

// NOTE
// When adding a new function, please make sure it's in the right place.
// All functions are sorted alphabetically.
// Returns the absolute value.
pub fn abs(a f64) f64 {
	return C.fabs(a)
}

// acos calculates inverse cosine (arccosine).
pub fn acos(a f64) f64 {
	return C.acos(a)
}

// asin calculates inverse sine (arcsine).
pub fn asin(a f64) f64 {
	return C.asin(a)
}

// atan calculates inverse tangent (arctangent).
pub fn atan(a f64) f64 {
	return C.atan(a)
}

// atan2 calculates inverse tangent with two arguments, returns the angle between the X axis and the point.
pub fn atan2(a, b f64) f64 {
	return C.atan2(a, b)
}

// cbrt calculates cubic root.
pub fn cbrt(a f64) f64 {
	return C.cbrt(a)
}

// ceil returns the nearest f64 greater or equal to the provided value.
pub fn ceil(a f64) f64 {
	return C.ceil(a)
}

pub fn copysign(x, y f64) f64 {
	if (x < 0 && y > 0) || (x > 0 && y < 0) {
                return -x
        }

        return x
}

// cosh calculates hyperbolic cosine.
pub fn cosh(a f64) f64 {
	return C.cosh(a)
}

// degrees convert from degrees to radians.
pub fn degrees(radians f64) f64 {
	return radians * (180.0 / pi)
}

// exp calculates exponent of the number (math.pow(math.E, a)).
pub fn exp(a f64) f64 {
	return C.exp(a)
}

// digits returns an array of the digits of n in the given base.
pub fn digits(_n, base int) []int {
	if base < 2 {
		panic('digits: Cannot find digits of n with base $base')
	}
	mut n := _n
	mut sign := 1
	if n < 0 {
		sign = -1
		n = -n
	}
	mut res := []int
	for n != 0 {
		res << (n % base) * sign
		n /= base
	}
	return res
}

// erf computes the error function value
pub fn erf(a f64) f64 {
	return C.erf(a)
}

// erfc computes the complementary error function value
pub fn erfc(a f64) f64 {
	return C.erfc(a)
}

// exp2 returns the base-2 exponential function of a (math.pow(2, a)).
pub fn exp2(a f64) f64 {
	return C.exp2(a)
}

// floor returns the nearest f64 lower or equal of the provided value.
pub fn floor(a f64) f64 {
	return C.floor(a)
}

// fmod returns the floating-point remainder of number / denom (rounded towards zero):
pub fn fmod(a, b f64) f64 {
	return C.fmod(a, b)
}

// gamma computes the gamma function value
pub fn gamma(a f64) f64 {
	return C.tgamma(a)
}

// gcd calculates greatest common (positive) divisor (or zero if a and b are both zero).
pub fn gcd(a_, b_ i64) i64 {
	mut a := a_
	mut b := b_
	if a < 0 {
		a = -a
	}
	if b < 0 {
		b = -b
	}
	for b != 0 {
		a %= b
		if a == 0 {
			return b
		}
		b %= a
	}
	return a
}

// Returns hypotenuse of a right triangle.
pub fn hypot(a, b f64) f64 {
	return C.hypot(a, b)
}

// lcm calculates least common (non-negative) multiple.
pub fn lcm(a, b i64) i64 {
	if a == 0 {
		return a
	}
	res := a * (b / gcd(b, a))
	if res < 0 {
		return -res
	}
	return res
}

// log calculates natural (base-e) logarithm of the provided value.
pub fn log(a f64) f64 {
	return C.log(a)
}

// log2 calculates base-2 logarithm of the provided value.
pub fn log2(a f64) f64 {
	return C.log2(a)
}

// log10 calculates the common (base-10) logarithm of the provided value.
pub fn log10(a f64) f64 {
	return C.log10(a)
}

// log_gamma computes the log-gamma function value
pub fn log_gamma(a f64) f64 {
	return C.lgamma(a)
}

// log_n calculates base-N logarithm of the provided value.
pub fn log_n(a, b f64) f64 {
	return C.log(a) / C.log(b)
}

// max returns the maximum value of the two provided.
pub fn max(a, b f64) f64 {
	if a > b {
		return a
	}
	return b
}

// min returns the minimum value of the two provided.
pub fn min(a, b f64) f64 {
	if a < b {
		return a
	}
	return b
}

// nextafter32 returns the next representable f32 value after x towards y.
//
// Special cases are:
//	nextafter32(x, x)   = x
//	nextafter32(nan, y) = nan
//	nextafter32(x, nan) = nan
pub fn nextafter32(x, y f32) f32 {
        mut r := 0.0

	if is_nan(f64(x)) || is_nan(f64(y)) { // special case
		r = f32(nan())
        }
	else if x == y {
		r = x
        }
	else if x == 0 {
		r = f32(copysign(f64(f32_from_bits(1)), f64(y)))
        }
	else if (y > x) == (x > 0) {
		r = f32_from_bits(f32_bits(x) + 1)
        }
	else {
		r = f32_from_bits(f32_bits(x) - 1)
        }

	return r
}

// nextafter returns the next representable f64 value after x towards y.
//
// Special cases are:
//	nextafter(x, x)   = x
//	nextafter(nan, y) = nan
//	nextafter(x, nan) = nan
pub fn nextafter(x, y f64) f64 {
        mut r := f64(0.0)

	if is_nan(x) || is_nan(y) { // special case
		r = nan()
        }
	else if x == y {
		r = x
        }
	else if x == 0 {
		r = copysign(f64_from_bits(1), y)
        }
	else if (y > x) == (x > 0) {
		r = f64_from_bits(f64_bits(x) + 1)
        }
	else {
		r = f64_from_bits(f64_bits(x) - 1)
        }

	return r
}


// pow returns base raised to the provided power.
pub fn pow(a, b f64) f64 {
	return C.pow(a, b)
}

// radians convert from radians to degrees.
pub fn radians(degrees f64) f64 {
	return degrees * (pi / 180.0)
}

// round returns the integer nearest to the provided value.
pub fn round(f f64) f64 {
	return C.round(f)
}

pub fn signbit(x f64) bool {
        return false
	//return f64_bits(x)&(1<<63) != 0
}

// sinh calculates hyperbolic sine.
pub fn sinh(a f64) f64 {
	return C.sinh(a)
}

// sqrt calculates square-root of the provided value.
pub fn sqrt(a f64) f64 {
	return C.sqrt(a)
}

// tan calculates tangent.
pub fn tan(a f64) f64 {
	return C.tan(a)
}

// tanh calculates hyperbolic tangent.
pub fn tanh(a f64) f64 {
	return C.tanh(a)
}

// trunc rounds a toward zero, returning the nearest integral value that is not
// larger in magnitude than a.
pub fn trunc(a f64) f64 {
	return C.trunc(a)
}

[inline]
fn poly_n_eval(c []f64, n int, x f64) f64 {
	if c.len == 0 {
                panic('coeficients can not be empty')
        }

        len := int(min(c.len, n))
        mut ans := c[len-1]

        for e in c[..len-1] {
                ans = e + x * ans
        }

        return ans
}

[inline]
fn poly_n_1_eval(c []f64, n int, x f64) f64 {
        if c.len == 0 {
                panic('coeficients can not be empty')
        }

        len := int(min(c.len, n)) - 1
        mut ans := c[len-1]

        for e in c[..len-1] {
                ans = e + x * ans
        }

        return ans
}

[inline]
fn poly_eval(c []f64, x f64) f64 {
        return poly_n_eval(c, c.len, x)
}

[inline]
fn poly_1_eval(c []f64, x f64) f64 {
        return poly_n_1_eval(c, c.len, x)
}
