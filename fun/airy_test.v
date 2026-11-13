module fun

import math

// Reference values from 140-digit decimal evaluation of the Maclaurin series with 51-digit
// constants. They are valid on the tested points, where the cancellation in the series
// stays within the decimal precision.
struct AiryFixture {
	x   f64
	ai  f64
	bi  f64
	aip f64
	bip f64
}

const airy_fixtures = [
	AiryFixture{-20, -0.1764061270779847, -0.20013930932265134, 0.8928628567364713, -0.7914290338395364},
	AiryFixture{-12, -0.06655517505437313, -0.2957199120780731, 1.0231104533679707, -0.23673219783112331},
	AiryFixture{-9, -0.022133721547341403, 0.3249473234552449, -0.9756639809263316, -0.05740051384366925},
	AiryFixture{-8.5, -0.33029023763020887, 0.007754436447658404, -0.03231334828463914, -0.9629691651201748},
	AiryFixture{-8, -0.0527050503563862, -0.33125158075113786, 0.9355609381983065, -0.1594504978129814},
	AiryFixture{-5, 0.35076100902411433, -0.13836913490160058, 0.32719281855444315, 0.7784117730018992},
	AiryFixture{-2, 0.22740742820168558, -0.4123025879563985, 0.618259020741691, 0.2787951669211695},
	AiryFixture{-0.5, 0.4757280916105396, 0.38035265975105387, -0.20408167033954738, 0.5059337136238472},
	AiryFixture{0, 0.3550280538878172, 0.6149266274460007, -0.25881940379280680, 0.44828835735382636},
	AiryFixture{0.5, 0.23169360648083348, 0.8542770431031554, -0.2249105326646839, 0.5445725641405923},
	AiryFixture{2, 0.03492413042327438, 3.2980949999782148, -0.05309038443365363, 4.10068204993289},
	AiryFixture{5, 0.00010834442813607442, 657.7920441711711, -0.0002474138908684625, 1435.8190802179824},
	AiryFixture{8, 4.6922076160992316e-08, 1199586.00412446, -1.3414392979067865e-07, 3354342.3127445388},
	AiryFixture{8.5, 1.0997009755195506e-08, 4965319.541471302, -3.237725440447602e-08, 14326301.030662058},
	AiryFixture{10, 1.1047532552898686e-10, 455641153.54822516, -3.5206336767389237e-10, 1429236134.4828658},
	AiryFixture{12, 1.3931846888753607e-13, 329807225829.07416, -4.854736554985309e-13, 1135507502443.3708},
]

fn airy_rel_close(got f64, want f64, rel f64) bool {
	if want == 0 {
		return math.abs(got) <= rel
	}
	return math.abs(got - want) <= rel * math.abs(want)
}

fn test_airy_matches_high_precision_reference() {
	for fixture in airy_fixtures {
		// Series region |x| <= 8 is held to 1e-13; asymptotic regions to 1e-12.
		rel := if math.abs(fixture.x) <= airy_series_limit { 1e-13 } else { 1e-12 }
		v := airy(fixture.x)
		assert airy_rel_close(v.ai, fixture.ai, rel), 'Ai(${fixture.x}) = ${v.ai}, want ${fixture.ai}'
		assert airy_rel_close(v.bi, fixture.bi, rel), 'Bi(${fixture.x}) = ${v.bi}, want ${fixture.bi}'
		assert airy_rel_close(v.aip, fixture.aip, rel), "Ai'(${fixture.x}) = ${v.aip}, want ${fixture.aip}"
		assert airy_rel_close(v.bip, fixture.bip, rel), "Bi'(${fixture.x}) = ${v.bip}, want ${fixture.bip}"
	}
}

fn test_airy_error_estimate_bounds_the_error() {
	for fixture in airy_fixtures {
		v := airy(fixture.x)
		for pair in [[v.ai, fixture.ai], [v.bi, fixture.bi], [v.aip, fixture.aip],
			[v.bip, fixture.bip]] {
			assert math.abs(pair[0] - pair[1]) <= v.err + 1e-300, 'error at x=${fixture.x}: ${math.abs(pair[0] - pair[1])} exceeds estimate ${v.err}'
		}
	}
}

// The Wronskian of Ai and Bi is 1/pi for every x. This holds on both sides of the
// method boundaries and does not depend on the reference constants.
fn test_airy_wronskian_is_one_over_pi() {
	inv_pi := 1 / math.pi
	for x in [-40.0, -20.0, -9.0, -8.0, -7.5, -3.0, -0.5, 0.0, 0.5, 3.0, 7.9, 8.0, 8.1, 12.0, 30.0,
		60.0, 100.0] {
		v := airy(x)
		w := v.ai * v.bip - v.aip * v.bi
		assert math.abs(w - inv_pi) <= 1e-12, 'Wronskian at x=${x} is ${w}, want ${inv_pi}'
	}
}

// Derivatives agree with central differences of the values across the method boundaries.
fn test_airy_derivatives_match_finite_differences() {
	h := 1e-5
	for x in [-10.0, -8.0, -3.0, 0.0, 2.5, 7.5, 9.0, 11.0] {
		plus := airy(x + h)
		minus := airy(x - h)
		ai_fd := (plus.ai - minus.ai) / (2 * h)
		bi_fd := (plus.bi - minus.bi) / (2 * h)
		here := airy(x)
		assert math.abs(here.aip - ai_fd) <= 1e-7 * math.max(1, math.abs(here.aip)), "Ai'(${x}): ${here.aip} vs ${ai_fd}"
		assert math.abs(here.bip - bi_fd) <= 1e-7 * math.max(1, math.abs(here.bip)), "Bi'(${x}): ${here.bip} vs ${bi_fd}"
	}
}

// Scaled values are the unscaled values times exp(zeta) for Ai and exp(-zeta) for Bi.
fn test_airy_scaled_matches_unscaled_for_nonnegative_x() {
	for x in [0.0, 0.5, 2.0, 5.0, 8.0, 8.5, 10.0, 20.0, 50.0] {
		zeta := 2.0 / 3.0 * x * math.sqrt(x)
		plain := airy(x)
		scaled := airy_scaled(x)
		assert airy_rel_close(scaled.ai, plain.ai * math.exp(zeta), 1e-12), 'scaled Ai at ${x}'
		assert airy_rel_close(scaled.aip, plain.aip * math.exp(zeta), 1e-12), "scaled Ai' at ${x}"
		assert airy_rel_close(scaled.bi, plain.bi * math.exp(-zeta), 1e-12), 'scaled Bi at ${x}'
		assert airy_rel_close(scaled.bip, plain.bip * math.exp(-zeta), 1e-12), "scaled Bi' at ${x}"
	}
}

fn test_airy_scaled_is_unscaled_for_negative_x() {
	for x in [-30.0, -8.5, -2.0, -0.5] {
		plain := airy(x)
		scaled := airy_scaled(x)
		assert scaled.ai == plain.ai
		assert scaled.bi == plain.bi
		assert scaled.aip == plain.aip
		assert scaled.bip == plain.bip
	}
}

fn test_airy_special_values() {
	nan_value := airy(math.nan())
	assert math.is_nan(nan_value.ai) && math.is_nan(nan_value.bip)
	neg_inf := airy(math.inf(-1))
	assert math.is_nan(neg_inf.ai) && math.is_nan(neg_inf.bi)
	pos_inf := airy(math.inf(1))
	assert pos_inf.ai == 0 && pos_inf.aip == 0
	assert math.is_inf(pos_inf.bi, 1) && math.is_inf(pos_inf.bip, 1)
	scaled_inf := airy_scaled(math.inf(1))
	assert scaled_inf.ai == 0 && scaled_inf.bi == 0
	assert math.is_inf(scaled_inf.aip, -1) && math.is_inf(scaled_inf.bip, 1)
}

// Overflow and underflow boundaries: unscaled Ai underflows to zero, and unscaled Bi
// overflows to +inf, well inside the tested range.
fn test_airy_overflow_and_underflow_boundaries() {
	far := airy(120)
	assert far.ai == 0
	assert far.aip == 0
	assert math.is_inf(far.bi, 1)
	assert math.is_inf(far.bip, 1)
	// The scaled forms stay finite where the unscaled ones overflow.
	scaled := airy_scaled(120)
	assert math.is_inf(scaled.bi, 0) == false
	assert scaled.bi > 0
	assert math.is_inf(scaled.ai, 0) == false
}

fn test_airy_convenience_functions_agree_with_airy() {
	x := -1.25
	v := airy(x)
	assert airy_ai(x) == v.ai
	assert airy_bi(x) == v.bi
	assert airy_aip(x) == v.aip
	assert airy_bip(x) == v.bip
}
