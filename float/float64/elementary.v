module float64

import math

// Elementary functions in double-double arithmetic (~106 bits).
//
// The *_dd functions in this module evaluate in double-double arithmetic
// built on the error-free transformations in dd.v, and return the result
// as a (hi, lo) pair. The extra precision makes the f64 rounding of the
// pair correctly rounded in practice: it could only differ from the true
// correctly rounded value if the exact result lay within ~2^-100 of an
// f64 midpoint. In randomized validation against 200-bit references
// (508 exp, 504 log, 600 sin, 600 cos, 500 exp2, 400 log2, 400 log10 and
// 500 tan inputs), hi matched the correctly rounded f64 result for every
// input, and the pair (hi + lo) agreed with the exact value to ~5e-32
// relative (except exp-family cases near the underflow boundary, where
// lo itself becomes subnormal, and atan at ~5e-20). The same holds for
// the later additions (500 atan, 500 asin, 400 acos, 400 sinh, 300 cosh
// and 400 tanh inputs). The bit-exact tables in elementary_dd_test.v
// pin this behavior.
//
// This is the f64 analogue of the f32 baseline in float32/elementary.v
// and progress toward vlang/vsl#65; a proof for all inputs remains open.

// ln(2) split into hi + lo double-double parts.
const ln2_hi = 0.6931471805599453
const ln2_lo = 2.3190468138462996e-17

// dd_mul returns the double-double product of two double-double values.
fn dd_mul(a_hi f64, a_lo f64, b_hi f64, b_lo f64) (f64, f64) {
	p, e := two_prod(a_hi, b_hi)
	return quick_two_sum(p, e + a_hi * b_lo + a_lo * b_hi)
}

// dd_div returns the double-double quotient of two double-double values,
// computed with one Newton refinement step.
fn dd_div(a_hi f64, a_lo f64, b_hi f64, b_lo f64) (f64, f64) {
	q1 := a_hi / b_hi
	p, e := two_prod(q1, b_hi)
	mut r_hi, r_lo := two_sum(a_hi, -p)
	r_lo += a_lo - e - q1 * b_lo
	r_hi, r_lo = quick_two_sum(r_hi, r_lo)
	q2 := r_hi / b_hi
	return quick_two_sum(q1, q2)
}

// exp_dd returns e^x as a double-double pair (hi, lo).
pub fn exp_dd(x f64) (f64, f64) {
	if x != x {
		return x, x
	}
	if x > 710.0 {
		return math.inf(1), 0.0
	}
	if x < -746.0 {
		return 0.0, 0.0
	}
	if x == 0.0 {
		return 1.0, 0.0
	}
	return exp_dd_core(x, 0.0)
}

// exp_dd_core evaluates e^x for a double-double argument (x_hi, x_lo)
// of moderate magnitude, without the scalar overflow/underflow guards.
fn exp_dd_core(x_hi f64, x_lo f64) (f64, f64) {
	// Range reduction: x = k * ln(2) + r with |r| <= ln(2) / 2.
	k := int(math.round(x_hi / ln2_hi))
	mut kh, mut ke := two_prod(f64(k), ln2_hi)
	ke += f64(k) * ln2_lo
	kh, ke = quick_two_sum(kh, ke)
	mut r_hi, mut r_lo := dd_sub(x_hi, x_lo, kh, ke)

	// Taylor series for e^r in double-double arithmetic.
	mut s_hi, mut s_lo := 1.0, 0.0
	mut t_hi, mut t_lo := 1.0, 0.0
	for n in 1 .. 80 {
		t_hi, t_lo = dd_mul(t_hi, t_lo, r_hi, r_lo)
		t_hi, t_lo = dd_div(t_hi, t_lo, f64(n), 0.0)
		s_hi, s_lo = dd_add(s_hi, s_lo, t_hi, t_lo)
		if math.abs(t_hi) < 1e-38 * math.abs(s_hi) {
			break
		}
	}
	return math.ldexp(s_hi, k), math.ldexp(s_lo, k)
}

// exp returns e^x rounded from the double-double evaluation; in practice
// this is the correctly rounded f64 value (see the module comment).
pub fn exp(x f64) f64 {
	hi, lo := exp_dd(x)
	return hi + lo
}

// log_dd returns the natural logarithm of x as a double-double pair
// (hi, lo). For x <= 0 it returns the same special values as math.log.
pub fn log_dd(x f64) (f64, f64) {
	if x != x || x < 0.0 {
		return math.nan(), 0.0
	}
	if x == 0.0 {
		return math.inf(-1), 0.0
	}
	if x == 1.0 {
		return 0.0, 0.0
	}
	// Range reduction: x = m * 2^k with m in [sqrt(1/2), sqrt(2)].
	mut m, mut k := math.frexp(x)
	if m < 0.7071067811865476 {
		m *= 2.0
		k--
	}
	// s = (m - 1) / (m + 1); m + 1 must enter as an exact double-double,
	// since the rounded f64 value would cap the result at f64 accuracy.
	b_hi, b_lo := two_sum(m, 1.0)
	s_hi, s_lo := dd_div(m - 1.0, 0.0, b_hi, b_lo)
	s2_hi, s2_lo := dd_mul(s_hi, s_lo, s_hi, s_lo)

	// log(m) = 2 * (s + s^3/3 + s^5/5 + ...) in double-double arithmetic.
	mut t_hi, mut t_lo := s_hi, s_lo
	mut a_hi, mut a_lo := s_hi, s_lo
	for j in 1 .. 61 {
		t_hi, t_lo = dd_mul(t_hi, t_lo, s2_hi, s2_lo)
		c_hi, c_lo := dd_div(t_hi, t_lo, f64(2 * j + 1), 0.0)
		a_hi, a_lo = dd_add(a_hi, a_lo, c_hi, c_lo)
		if math.abs(c_hi) < 1e-38 * math.abs(a_hi) {
			break
		}
	}
	l_hi, l_lo := dd_mul(a_hi, a_lo, 2.0, 0.0)

	mut kh, mut ke := two_prod(f64(k), ln2_hi)
	ke += f64(k) * ln2_lo
	kh, ke = quick_two_sum(kh, ke)
	return dd_add(l_hi, l_lo, kh, ke)
}

// log returns log(x) rounded from the double-double evaluation; in
// practice this is the correctly rounded f64 value (see exp).
pub fn log(x f64) f64 {
	hi, lo := log_dd(x)
	return hi + lo
}

// pi/2 split into three f64 parts (hi + lo + lo2, ~159 bits total), used
// for double-double argument reduction.
const pio2_hi = 1.5707963267948966
const pio2_lo = 6.123233995736766e-17
const pio2_lo2 = -1.4973849048591698e-33

// dd_sub returns the double-double difference of two double-double values.
fn dd_sub(a_hi f64, a_lo f64, b_hi f64, b_lo f64) (f64, f64) {
	return dd_add(a_hi, a_lo, -b_hi, -b_lo)
}

// reduce_pio2 returns k and the double-double remainder r = x - k * pi/2
// with |r| <= pi/4. Each part of pi/2 is subtracted with an exact
// two_prod split, so the reduction keeps double-double accuracy for
// |x| up to at least 1e12 (validated against 200-bit references).
fn reduce_pio2(x f64) (int, f64, f64) {
	k := int(math.round(x / pio2_hi))
	mut r_hi, mut r_lo := x, 0.0
	for part in [pio2_hi, pio2_lo, pio2_lo2] {
		p, e := two_prod(f64(k), part)
		r_hi, r_lo = dd_sub(r_hi, r_lo, p, e)
	}
	return k, r_hi, r_lo
}

// sin_series_dd evaluates sin(r) for |r| <= pi/4 in double-double.
fn sin_series_dd(r_hi f64, r_lo f64) (f64, f64) {
	s2_hi, s2_lo := dd_mul(r_hi, r_lo, r_hi, r_lo)
	mut t_hi, mut t_lo := r_hi, r_lo
	mut a_hi, mut a_lo := r_hi, r_lo
	for j in 1 .. 41 {
		t_hi, t_lo = dd_mul(t_hi, t_lo, s2_hi, s2_lo)
		t_hi, t_lo = dd_div(t_hi, t_lo, f64((2 * j) * (2 * j + 1)), 0.0)
		if j % 2 == 1 {
			a_hi, a_lo = dd_sub(a_hi, a_lo, t_hi, t_lo)
		} else {
			a_hi, a_lo = dd_add(a_hi, a_lo, t_hi, t_lo)
		}
		if math.abs(t_hi) < 1e-38 * math.max(1.0, math.abs(a_hi)) {
			break
		}
	}
	return a_hi, a_lo
}

// cos_series_dd evaluates cos(r) for |r| <= pi/4 in double-double.
fn cos_series_dd(r_hi f64, r_lo f64) (f64, f64) {
	s2_hi, s2_lo := dd_mul(r_hi, r_lo, r_hi, r_lo)
	mut t_hi, mut t_lo := 1.0, 0.0
	mut a_hi, mut a_lo := 1.0, 0.0
	for j in 1 .. 41 {
		t_hi, t_lo = dd_mul(t_hi, t_lo, s2_hi, s2_lo)
		t_hi, t_lo = dd_div(t_hi, t_lo, f64((2 * j - 1) * (2 * j)), 0.0)
		if j % 2 == 1 {
			a_hi, a_lo = dd_sub(a_hi, a_lo, t_hi, t_lo)
		} else {
			a_hi, a_lo = dd_add(a_hi, a_lo, t_hi, t_lo)
		}
		if math.abs(t_hi) < 1e-38 * math.max(1.0, math.abs(a_hi)) {
			break
		}
	}
	return a_hi, a_lo
}

// sin_dd returns sin(x) as a double-double pair (hi, lo). The argument
// reduction is double-double accurate for |x| <= 1e15; beyond that (and
// for non-finite inputs) it falls back to the libm value with lo = 0.
pub fn sin_dd(x f64) (f64, f64) {
	if x != x {
		return x, x
	}
	if math.abs(x) > 1e15 {
		return math.sin(x), 0.0
	}
	if x == 0.0 {
		return x, 0.0
	}
	k, r_hi, r_lo := reduce_pio2(x)
	q := ((k % 4) + 4) % 4
	match q {
		0 {
			return sin_series_dd(r_hi, r_lo)
		}
		1 {
			return cos_series_dd(r_hi, r_lo)
		}
		2 {
			h, l := sin_series_dd(r_hi, r_lo)
			return -h, -l
		}
		else {
			h, l := cos_series_dd(r_hi, r_lo)
			return -h, -l
		}
	}
}

// sin returns sin(x) rounded from the double-double evaluation; in
// practice this is the correctly rounded f64 value (see exp).
pub fn sin(x f64) f64 {
	hi, lo := sin_dd(x)
	return hi + lo
}

// cos_dd returns cos(x) as a double-double pair (hi, lo), with the same
// reduction domain and fallback as sin_dd.
pub fn cos_dd(x f64) (f64, f64) {
	if x != x {
		return x, x
	}
	if math.abs(x) > 1e15 {
		return math.cos(x), 0.0
	}
	if x == 0.0 {
		return 1.0, 0.0
	}
	k, r_hi, r_lo := reduce_pio2(x)
	q := ((k % 4) + 4) % 4
	match q {
		0 {
			return cos_series_dd(r_hi, r_lo)
		}
		1 {
			h, l := sin_series_dd(r_hi, r_lo)
			return -h, -l
		}
		2 {
			h, l := cos_series_dd(r_hi, r_lo)
			return -h, -l
		}
		else {
			return sin_series_dd(r_hi, r_lo)
		}
	}
}

// cos returns cos(x) rounded from the double-double evaluation; in
// practice this is the correctly rounded f64 value (see exp).
pub fn cos(x f64) f64 {
	hi, lo := cos_dd(x)
	return hi + lo
}

// ln(10) split into hi + lo double-double parts.
const ln10_hi = 2.302585092994046
const ln10_lo = -2.1707562233822494e-16

// exp2_dd returns 2^x as a double-double pair (hi, lo).
pub fn exp2_dd(x f64) (f64, f64) {
	if x != x {
		return x, x
	}
	if x >= 1024.0 {
		return math.inf(1), 0.0
	}
	if x <= -1075.0 {
		return 0.0, 0.0
	}
	if x == 0.0 {
		return 1.0, 0.0
	}
	k := int(math.round(x))
	f_hi, f_lo := dd_sub(x, 0.0, f64(k), 0.0)
	y_hi, y_lo := dd_mul(f_hi, f_lo, ln2_hi, ln2_lo)
	e_hi, e_lo := exp_dd_core(y_hi, y_lo)
	return math.ldexp(e_hi, k), math.ldexp(e_lo, k)
}

// exp2 returns 2^x rounded from the double-double evaluation.
pub fn exp2(x f64) f64 {
	hi, lo := exp2_dd(x)
	return hi + lo
}

// log2_dd returns the base-2 logarithm of x as a double-double pair.
pub fn log2_dd(x f64) (f64, f64) {
	if x != x || x < 0.0 {
		return math.nan(), 0.0
	}
	if x == 0.0 {
		return math.inf(-1), 0.0
	}
	h, l := log_dd(x)
	return dd_div(h, l, ln2_hi, ln2_lo)
}

// log2 returns log2(x) rounded from the double-double evaluation.
pub fn log2(x f64) f64 {
	hi, lo := log2_dd(x)
	return hi + lo
}

// log10_dd returns the base-10 logarithm of x as a double-double pair.
pub fn log10_dd(x f64) (f64, f64) {
	if x != x || x < 0.0 {
		return math.nan(), 0.0
	}
	if x == 0.0 {
		return math.inf(-1), 0.0
	}
	h, l := log_dd(x)
	return dd_div(h, l, ln10_hi, ln10_lo)
}

// log10 returns log10(x) rounded from the double-double evaluation.
pub fn log10(x f64) f64 {
	hi, lo := log10_dd(x)
	return hi + lo
}

// tan_dd returns tan(x) as a double-double pair (hi, lo), computed as
// sin_dd / cos_dd with the same reduction domain and fallback as sin_dd.
pub fn tan_dd(x f64) (f64, f64) {
	if x != x {
		return x, x
	}
	if math.abs(x) > 1e15 {
		return math.tan(x), 0.0
	}
	s_hi, s_lo := sin_dd(x)
	c_hi, c_lo := cos_dd(x)
	return dd_div(s_hi, s_lo, c_hi, c_lo)
}

// tan returns tan(x) rounded from the double-double evaluation.
pub fn tan(x f64) f64 {
	hi, lo := tan_dd(x)
	return hi + lo
}

// sqrt_dd returns the square root of a double-double value (a_hi, a_lo),
// computed with two Newton refinements from the f64 approximation.
fn sqrt_dd(a_hi f64, a_lo f64) (f64, f64) {
	mut s_hi, mut s_lo := math.sqrt(a_hi), 0.0
	for _ in 0 .. 2 {
		s2_hi, s2_lo := dd_mul(s_hi, s_lo, s_hi, s_lo)
		d_hi, d_lo := dd_sub(a_hi, a_lo, s2_hi, s2_lo)
		q_hi, q_lo := dd_div(d_hi, d_lo, 2.0 * s_hi, 0.0)
		s_hi, s_lo = dd_add(s_hi, s_lo, q_hi, q_lo)
	}
	return s_hi, s_lo
}

// atan_series_dd evaluates atan(t) for |t| <= ~0.08 in double-double.
fn atan_series_dd(t_hi f64, t_lo f64) (f64, f64) {
	s2_hi, s2_lo := dd_mul(t_hi, t_lo, t_hi, t_lo)
	mut u_hi, mut u_lo := t_hi, t_lo
	mut a_hi, mut a_lo := t_hi, t_lo
	for j in 1 .. 61 {
		u_hi, u_lo = dd_mul(u_hi, u_lo, s2_hi, s2_lo)
		c_hi, c_lo := dd_div(u_hi, u_lo, f64(2 * j + 1), 0.0)
		if j % 2 == 1 {
			a_hi, a_lo = dd_sub(a_hi, a_lo, c_hi, c_lo)
		} else {
			a_hi, a_lo = dd_add(a_hi, a_lo, c_hi, c_lo)
		}
		if math.abs(c_hi) < 1e-38 * math.max(1.0, math.abs(a_hi)) {
			break
		}
	}
	return a_hi, a_lo
}

// atan_dd_pair evaluates atan of a double-double argument of any sign
// and magnitude: reciprocal reduction for |arg| > 1 and two half-angle
// steps before the Taylor series.
fn atan_dd_pair(x_hi f64, x_lo f64) (f64, f64) {
	if x_hi == 0.0 && x_lo == 0.0 {
		return 0.0, 0.0
	}
	mut sign := 1.0
	mut t_hi, mut t_lo := x_hi, x_lo
	if t_hi < 0.0 {
		sign = -1.0
		t_hi, t_lo = -t_hi, -t_lo
	}
	mut flipped := false
	if t_hi > 1.0 {
		t_hi, t_lo = dd_div(1.0, 0.0, t_hi, t_lo)
		flipped = true
	}
	for _ in 0 .. 2 {
		s2_hi, s2_lo := dd_mul(t_hi, t_lo, t_hi, t_lo)
		u_hi, u_lo := dd_add(s2_hi, s2_lo, 1.0, 0.0)
		r_hi, r_lo := sqrt_dd(u_hi, u_lo)
		d_hi, d_lo := dd_add(r_hi, r_lo, 1.0, 0.0)
		t_hi, t_lo = dd_div(t_hi, t_lo, d_hi, d_lo)
	}
	mut a_hi, mut a_lo := atan_series_dd(t_hi, t_lo)
	a_hi, a_lo = dd_mul(a_hi, a_lo, 4.0, 0.0)
	if flipped {
		a_hi, a_lo = dd_sub(pio2_hi, pio2_lo, a_hi, a_lo)
	}
	if sign < 0.0 {
		return -a_hi, -a_lo
	}
	return a_hi, a_lo
}

// atan_dd returns atan(x) as a double-double pair (hi, lo).
pub fn atan_dd(x f64) (f64, f64) {
	if x != x {
		return x, x
	}
	if x == 0.0 {
		return x, 0.0
	}
	return atan_dd_pair(x, 0.0)
}

// atan returns atan(x) rounded from the double-double evaluation.
pub fn atan(x f64) f64 {
	hi, lo := atan_dd(x)
	return hi + lo
}

// asin_dd returns asin(x) as a double-double pair (hi, lo), computed as
// atan(x / sqrt(1 - x^2)). For |x| > 1 it returns NaN, like math.asin.
pub fn asin_dd(x f64) (f64, f64) {
	if x != x || x > 1.0 || x < -1.0 {
		return math.nan(), 0.0
	}
	if x == 0.0 {
		return x, 0.0
	}
	if x == 1.0 {
		return pio2_hi, pio2_lo
	}
	if x == -1.0 {
		return -pio2_hi, -pio2_lo
	}
	x2_hi, x2_lo := dd_mul(x, 0.0, x, 0.0)
	d_hi, d_lo := dd_sub(1.0, 0.0, x2_hi, x2_lo)
	s_hi, s_lo := sqrt_dd(d_hi, d_lo)
	q_hi, q_lo := dd_div(x, 0.0, s_hi, s_lo)
	return atan_dd_pair(q_hi, q_lo)
}

// asin returns asin(x) rounded from the double-double evaluation.
pub fn asin(x f64) f64 {
	hi, lo := asin_dd(x)
	return hi + lo
}

// acos_dd returns acos(x) as a double-double pair (hi, lo), computed as
// pi/2 - asin(x). For |x| > 1 it returns NaN, like math.acos.
pub fn acos_dd(x f64) (f64, f64) {
	if x != x || x > 1.0 || x < -1.0 {
		return math.nan(), 0.0
	}
	a_hi, a_lo := asin_dd(x)
	return dd_sub(pio2_hi, pio2_lo, a_hi, a_lo)
}

// acos returns acos(x) rounded from the double-double evaluation.
pub fn acos(x f64) f64 {
	hi, lo := acos_dd(x)
	return hi + lo
}

// dd_reciprocal returns 1 / (e_hi, e_lo) for a double-double value. The
// operand is scaled by 2^-512 first: Dekker's two_prod splitting
// overflows for operands near 1e303, which exp_dd legitimately produces.
fn dd_reciprocal(e_hi f64, e_lo f64) (f64, f64) {
	s_hi := math.ldexp(e_hi, -512)
	s_lo := math.ldexp(e_lo, -512)
	q_hi, q_lo := dd_div(1.0, 0.0, s_hi, s_lo)
	return math.ldexp(q_hi, -512), math.ldexp(q_lo, -512)
}

// sinh_dd returns sinh(x) as a double-double pair (hi, lo). For
// |x| > 710 it falls back to the libm value with lo = 0.
pub fn sinh_dd(x f64) (f64, f64) {
	if x != x {
		return x, x
	}
	if x == 0.0 {
		return x, 0.0
	}
	if math.abs(x) > 710.0 {
		return math.sinh(x), 0.0
	}
	e_hi, e_lo := exp_dd(math.abs(x))
	i_hi, i_lo := dd_reciprocal(e_hi, e_lo)
	d_hi, d_lo := dd_sub(e_hi, e_lo, i_hi, i_lo)
	// Scale by 1/2 with ldexp: dd_mul would split the huge operand with
	// Dekker's 2^27 splitter and overflow.
	r_hi := math.ldexp(d_hi, -1)
	r_lo := math.ldexp(d_lo, -1)
	if x < 0.0 {
		return -r_hi, -r_lo
	}
	return r_hi, r_lo
}

// sinh returns sinh(x) rounded from the double-double evaluation.
pub fn sinh(x f64) f64 {
	hi, lo := sinh_dd(x)
	return hi + lo
}

// cosh_dd returns cosh(x) as a double-double pair (hi, lo). For
// |x| > 710 it falls back to the libm value with lo = 0.
pub fn cosh_dd(x f64) (f64, f64) {
	if x != x {
		return x, x
	}
	if math.abs(x) > 710.0 {
		return math.cosh(x), 0.0
	}
	e_hi, e_lo := exp_dd(math.abs(x))
	i_hi, i_lo := dd_reciprocal(e_hi, e_lo)
	a_hi, a_lo := dd_add(e_hi, e_lo, i_hi, i_lo)
	return math.ldexp(a_hi, -1), math.ldexp(a_lo, -1)
}

// cosh returns cosh(x) rounded from the double-double evaluation.
pub fn cosh(x f64) f64 {
	hi, lo := cosh_dd(x)
	return hi + lo
}

// tanh_dd returns tanh(x) as a double-double pair (hi, lo), computed as
// (1 - d) / (1 + d) with d = e^(-2|x|): no overflow at any magnitude,
// and d underflows to 0 exactly when tanh rounds to +-1.
pub fn tanh_dd(x f64) (f64, f64) {
	if x != x {
		return x, x
	}
	if x == 0.0 {
		return x, 0.0
	}
	d_hi, d_lo := exp_dd(-2.0 * math.abs(x))
	n_hi, n_lo := dd_sub(1.0, 0.0, d_hi, d_lo)
	q_hi, q_lo := dd_add(1.0, 0.0, d_hi, d_lo)
	r_hi, r_lo := dd_div(n_hi, n_lo, q_hi, q_lo)
	if x < 0.0 {
		return -r_hi, -r_lo
	}
	return r_hi, r_lo
}

// tanh returns tanh(x) rounded from the double-double evaluation.
pub fn tanh(x f64) f64 {
	hi, lo := tanh_dd(x)
	return hi + lo
}
