module fun

import math
import vsl.float.float64

// Airy functions Ai and Bi, and their first derivatives, on the real line.
//
// Method:
//   - |x| <= 8: Maclaurin series of the two independent solutions, summed in
//     double-double arithmetic (about 32 significant digits). The series cancels for
//     large positive x, but the double-double sums keep the relative error below 1e-15
//     on this interval.
//   - x < -8: oscillatory asymptotic expansion (DLMF 9.7.9-9.7.12). Relative error is
//     about 1e-14 at x = -8 and improves as |x| grows.
//   - x > 8: decaying asymptotic expansion in e^{-zeta} and e^{zeta}, with
//     zeta = 2/3 x^{3/2}. Relative error is about 1e-13 at x = 8 and improves as x grows.
//
// Scaled forms (airy_scaled) follow SciPy's airye: for x >= 0 Ai and Ai' are multiplied
// by exp(zeta) and Bi and Bi' by exp(-zeta). For x < 0 nothing is scaled, because those
// functions oscillate with bounded amplitude.
//
// Special values: NaN propagates. Ai(+inf) = Ai'(+inf) = 0 and Bi(+inf) = Bi'(+inf) = +inf.
// The oscillatory limit at -inf does not exist, so every value is NaN there. Unscaled Bi
// and Bi' overflow to +inf beyond x of about 104.

// AiryValues holds Ai, Bi and their first derivatives at one point. err is an estimate of
// the largest absolute error among the four values, derived from the method used.
pub struct AiryValues {
pub:
	ai  f64
	bi  f64
	aip f64
	bip f64
	err f64
}

// Ai(0), -Ai'(0) and sqrt(3) as double-double pairs (hi, lo), from 60-digit decimal
// expansions.
const airy_c1_hi = 0.3550280538878172
const airy_c1_lo = 2.05233632436212e-17
const airy_c2_hi = 0.2588194037928068
const airy_c2_lo = -2.522243111610832e-17
const airy_sqrt3_hi = 1.7320508075688772
const airy_sqrt3_lo = 1.0035084221806903e-16

const airy_series_limit = 8.0
const airy_f64_eps = 2.220446049250313e-16
const airy_max_asymptotic_terms = 60

// AiryDD is an unevaluated sum hi + lo with |lo| <= ulp(hi) / 2.
struct AiryDD {
	hi f64
	lo f64
}

fn airy_dd_add(a AiryDD, b AiryDD) AiryDD {
	s, e := float64.two_sum(a.hi, b.hi)
	t, f := float64.two_sum(a.lo, b.lo)
	e2 := e + t
	u, v := float64.quick_two_sum(s, e2)
	w := v + f
	h, l := float64.quick_two_sum(u, w)
	return AiryDD{
		hi: h
		lo: l
	}
}

fn airy_dd_mul(a AiryDD, b AiryDD) AiryDD {
	p, e := float64.two_prod(a.hi, b.hi)
	e2 := e + (a.hi * b.lo + a.lo * b.hi)
	h, l := float64.quick_two_sum(p, e2)
	return AiryDD{
		hi: h
		lo: l
	}
}

// airy_dd_div_f64 divides a double-double by a double.
fn airy_dd_div_f64(a AiryDD, d f64) AiryDD {
	q1 := a.hi / d
	p, pe := float64.two_prod(q1, d)
	r := airy_dd_add(a, AiryDD{
		hi: -p
		lo: -pe
	})
	q2 := r.hi / d
	h, l := float64.quick_two_sum(q1, q2)
	return AiryDD{
		hi: h
		lo: l
	}
}

// airy_series returns f, g, f' and g' of the two Maclaurin series in double-double, and
// the sum of absolute term sizes (which bounds the rounding error of the sums).
//   f(x)  = sum_n c_n x^{3n},   c_{n+1} = c_n x^3 / ((3n+2)(3n+3)), c_0 = 1
//   g(x)  = sum_n b_n x^{3n+1}, b_{n+1} = b_n x^3 / ((3n+3)(3n+4)), b_0 = 1
//   f'(x) = sum_{n>=1} 3n c_n x^{3n-1}
//   g'(x) = sum_{n>=0} (3n+1) b_n x^{3n}
// Each derivative term is carried by its own recurrence, so no division by x is needed.
fn airy_series(x f64) (AiryDD, AiryDD, AiryDD, AiryDD, f64) {
	x_dd := AiryDD{
		hi: x
		lo: 0
	}
	x2 := airy_dd_mul(x_dd, x_dd)
	x3 := airy_dd_mul(x2, x_dd)
	mut term_f := AiryDD{
		hi: 1
		lo: 0
	}
	mut term_g := x_dd
	mut term_fp := airy_dd_div_f64(x2, 2) // 3 c_1 x^2 = x^2 / 2
	mut term_gp := AiryDD{
		hi: 1
		lo: 0
	}
	mut sum_f := AiryDD{}
	mut sum_g := AiryDD{}
	mut sum_fp := AiryDD{}
	mut sum_gp := AiryDD{}
	mut magnitude := 0.0
	for n in 0 .. 400 {
		nf := f64(n)
		sum_f = airy_dd_add(sum_f, term_f)
		sum_g = airy_dd_add(sum_g, term_g)
		sum_gp = airy_dd_add(sum_gp, term_gp)
		if n >= 1 {
			sum_fp = airy_dd_add(sum_fp, term_fp)
		}
		size := math.abs(term_f.hi) + math.abs(term_g.hi) + math.abs(term_fp.hi) +
			math.abs(term_gp.hi)
		magnitude += size
		if n >= 3 && size <= 1e-34 * (1 + math.abs(sum_f.hi) + math.abs(sum_g.hi)) {
			break
		}
		term_f = airy_dd_div_f64(airy_dd_mul(term_f, x3), (3 * nf + 2) * (3 * nf + 3))
		term_g = airy_dd_div_f64(airy_dd_mul(term_g, x3), (3 * nf + 3) * (3 * nf + 4))
		term_gp = airy_dd_div_f64(airy_dd_mul(term_gp, x3), (3 * nf + 1) * (3 * nf + 3))
		if n >= 1 {
			term_fp = airy_dd_div_f64(airy_dd_mul(term_fp, x3), 3 * nf * (3 * nf + 2))
		}
	}
	return sum_f, sum_g, sum_fp, sum_gp, magnitude
}

// airy_coefficients returns u_k and v_k = -(6k+1)/(6k-1) u_k for k < n, the coefficients
// of the Airy asymptotic expansions (DLMF 9.7.2).
fn airy_coefficients(n int) ([]f64, []f64) {
	mut u := []f64{len: n}
	mut v := []f64{len: n}
	u[0] = 1
	for k in 1 .. n {
		kf := f64(k)
		u[k] = u[k - 1] * (6 * kf - 5) * (6 * kf - 3) * (6 * kf - 1) / ((2 * kf - 1) * 216 * kf)
	}
	for k in 0 .. n {
		kf := f64(k)
		v[k] = -(6 * kf + 1) / (6 * kf - 1) * u[k]
	}
	return u, v
}

// airy_sums evaluates, at zeta, the sums of u_m zeta^{-m} and v_m zeta^{-m} with the sign
// pattern chosen by the caller. parity_sign(m) gives the sign of term m. The sums stop at
// the smallest term of the asymptotic series, which is where truncation error is least.
// The returned err is the size of the last term included, a bound on the truncation error.
fn airy_sums(zeta f64, sign_of fn (int) f64) (f64, f64, f64) {
	u, v := airy_coefficients(airy_max_asymptotic_terms)
	mut sum_u := 0.0
	mut sum_v := 0.0
	mut power := 1.0
	mut previous := math.inf(1)
	mut last := 0.0
	for m in 0 .. airy_max_asymptotic_terms {
		term_size := math.abs(u[m] * power)
		if term_size > previous {
			break
		}
		sign := sign_of(m)
		sum_u += sign * u[m] * power
		sum_v += sign * v[m] * power
		last = term_size
		previous = term_size
		if term_size < airy_f64_eps * 0.01 {
			break
		}
		power /= zeta
	}
	return sum_u, sum_v, last
}

// airy_decaying_asymptotic evaluates Ai, Ai' (scaled by exp(zeta)) and Bi, Bi' (scaled by
// exp(-zeta)) for x > 8 from the non-oscillatory expansion.
fn airy_decaying_asymptotic(x f64, scaled bool) AiryValues {
	zeta := 2.0 / 3.0 * x * math.sqrt(x)
	z4 := math.sqrt(math.sqrt(x))
	sp := math.sqrt(math.pi)
	alt_u, alt_v, last := airy_sums(zeta, fn (m int) f64 {
		return if m % 2 == 0 { 1.0 } else { -1.0 }
	})
	plain_u, plain_v, _ := airy_sums(zeta, fn (m int) f64 {
		return 1.0
	})
	// Scaled values: Ai e^{zeta}, Ai' e^{zeta}, Bi e^{-zeta}, Bi' e^{-zeta}.
	ai_s := alt_u / (2 * sp * z4)
	aip_s := -z4 * alt_v / (2 * sp)
	bi_s := plain_u / (sp * z4)
	bip_s := z4 * plain_v / sp
	// The exponential factor carries a relative error of about zeta * eps from the rounding of
	// its argument, and the sums add a few more roundings.
	err_rel := last + (4 + zeta) * airy_f64_eps
	if scaled {
		return AiryValues{
			ai:  ai_s
			bi:  bi_s
			aip: aip_s
			bip: bip_s
			err: err_rel * max4(ai_s, bi_s, aip_s, bip_s)
		}
	}
	ez := math.exp(zeta)
	emz := math.exp(-zeta)
	ai := ai_s * emz
	aip := aip_s * emz
	bi := bi_s * ez
	bip := bip_s * ez
	return AiryValues{
		ai:  ai
		bi:  bi
		aip: aip
		bip: bip
		err: err_rel * max4(ai, bi, aip, bip)
	}
}

// airy_oscillatory_asymptotic evaluates the expansion for x < -8, where z = -x and
// zeta = 2/3 z^{3/2}. The phase rounding error grows with zeta, which is included in err.
fn airy_oscillatory_asymptotic(x f64) AiryValues {
	z := -x
	zeta := 2.0 / 3.0 * z * math.sqrt(z)
	z4 := math.sqrt(math.sqrt(z))
	scale := 1 / math.sqrt(math.pi)
	// Even terms carry sign (-1)^{m/2}, odd terms carry (-1)^{(m-1)/2}. The P and Q
	// split is done by evaluating the sums on each parity separately.
	even_u, even_v, last_even := airy_sums(zeta, fn (m int) f64 {
		if m % 2 == 0 {
			return if (m / 2) % 2 == 0 { 1.0 } else { -1.0 }
		}
		return 0.0
	})
	odd_u, odd_v, last_odd := airy_sums(zeta, fn (m int) f64 {
		if m % 2 == 1 {
			return if (m / 2) % 2 == 0 { 1.0 } else { -1.0 }
		}
		return 0.0
	})
	phase := zeta + math.pi / 4
	sn := math.sin(phase)
	cs := math.cos(phase)
	ai := scale / z4 * (sn * even_u - cs * odd_u)
	bi := scale / z4 * (cs * even_u + sn * odd_u)
	aip := -scale * z4 * (cs * even_v + sn * odd_v)
	bip := scale * z4 * (sn * even_v - cs * odd_v)
	err_rel := math.max(last_even, last_odd) + zeta * airy_f64_eps + airy_f64_eps
	return AiryValues{
		ai:  ai
		bi:  bi
		aip: aip
		bip: bip
		err: err_rel * max4(ai, bi, aip, bip)
	}
}

// airy_from_series combines the double-double series into Ai, Bi and their derivatives.
// For x >= 0 the scaled variant multiplies by the exponential factors exp(zeta) and
// exp(-zeta); for x < 0 the values are the same in both variants.
fn airy_from_series(x f64, scaled bool) AiryValues {
	f, g, fp, gp, magnitude := airy_series(x)
	zeta := if x > 0 { 2.0 / 3.0 * x * math.sqrt(x) } else { 0.0 }
	c1 := AiryDD{
		hi: airy_c1_hi
		lo: airy_c1_lo
	}
	c2 := AiryDD{
		hi: airy_c2_hi
		lo: airy_c2_lo
	}
	s3 := AiryDD{
		hi: airy_sqrt3_hi
		lo: airy_sqrt3_lo
	}
	ai_dd := airy_dd_add(airy_dd_mul(c1, f), airy_dd_mul(AiryDD{
		hi: -c2.hi
		lo: -c2.lo
	}, g))
	bi_dd := airy_dd_mul(s3, airy_dd_add(airy_dd_mul(c1, f), airy_dd_mul(c2, g)))
	aip_dd := airy_dd_add(airy_dd_mul(c1, fp), airy_dd_mul(AiryDD{
		hi: -c2.hi
		lo: -c2.lo
	}, gp))
	bip_dd := airy_dd_mul(s3, airy_dd_add(airy_dd_mul(c1, fp), airy_dd_mul(c2, gp)))

	mut ai := ai_dd.hi + ai_dd.lo
	mut bi := bi_dd.hi + bi_dd.lo
	mut aip := aip_dd.hi + aip_dd.lo
	mut bip := bip_dd.hi + bip_dd.lo
	if x > 0 {
		if scaled {
			ai *= math.exp(zeta)
			aip *= math.exp(zeta)
			bi *= math.exp(-zeta)
			bip *= math.exp(-zeta)
		}
	}
	// Rounding error of the double-double sums, plus the final rounding to f64.
	err_dd := 1e-30 * magnitude + (4 + zeta) * airy_f64_eps * max4(ai, bi, aip, bip)
	return AiryValues{
		ai:  ai
		bi:  bi
		aip: aip
		bip: bip
		err: err_dd
	}
}

fn max4(a f64, b f64, c f64, d f64) f64 {
	return math.max(math.max(math.abs(a), math.abs(b)), math.max(math.abs(c), math.abs(d)))
}

// airy_special handles NaN and infinite arguments. ok reports whether x was special.
fn airy_special(x f64, scaled bool) (AiryValues, bool) {
	if math.is_nan(x) {
		nan := math.nan()
		return AiryValues{
			ai:  nan
			bi:  nan
			aip: nan
			bip: nan
			err: nan
		}, true
	}
	if math.is_inf(x, -1) {
		nan := math.nan()
		return AiryValues{
			ai:  nan
			bi:  nan
			aip: nan
			bip: nan
			err: nan
		}, true
	}
	if math.is_inf(x, 1) {
		inf := math.inf(1)
		if scaled {
			// e^{zeta} Ai ~ 1 / (2 sqrt(pi) x^{1/4}) and similar go to 0 or infinity as x grows.
			return AiryValues{
				ai:  0
				bi:  0
				aip: math.inf(-1)
				bip: inf
				err: 0
			}, true
		}
		return AiryValues{
			ai:  0
			bi:  inf
			aip: 0
			bip: inf
			err: 0
		}, true
	}
	return AiryValues{}, false
}

// airy computes Ai, Bi, Ai' and Bi' at x, in unscaled form.
pub fn airy(x f64) AiryValues {
	return airy_eval(x, false)
}

// airy_scaled computes the exponentially scaled forms, as SciPy's airye does. For x >= 0,
// Ai and Ai' are multiplied by exp(zeta) and Bi and Bi' by exp(-zeta), with zeta = 2/3 x^{3/2}.
// For x < 0 the result equals airy(x).
pub fn airy_scaled(x f64) AiryValues {
	return airy_eval(x, true)
}

fn airy_eval(x f64, scaled bool) AiryValues {
	special, is_special := airy_special(x, scaled)
	if is_special {
		return special
	}
	if x >= -airy_series_limit && x <= airy_series_limit {
		return airy_from_series(x, scaled)
	}
	if x < 0 {
		return airy_oscillatory_asymptotic(x)
	}
	return airy_decaying_asymptotic(x, scaled)
}

// airy_ai returns Ai(x).
pub fn airy_ai(x f64) f64 {
	return airy(x).ai
}

// airy_bi returns Bi(x).
pub fn airy_bi(x f64) f64 {
	return airy(x).bi
}

// airy_aip returns Ai'(x).
pub fn airy_aip(x f64) f64 {
	return airy(x).aip
}

// airy_bip returns Bi'(x).
pub fn airy_bip(x f64) f64 {
	return airy(x).bip
}
