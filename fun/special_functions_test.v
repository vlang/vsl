module fun

import math
import math.complex as cmplx

fn assert_close(actual f64, expected f64, tolerance f64) {
	assert math.abs(actual - expected) <= tolerance, 'got ${actual}, expected ${expected}'
}

fn test_chebyshev_series_evaluation() {
	series := ChebSeries{
		c:     [0.0, 1.0]
		order: 1
		a:     -1.0
		b:     1.0
	}
	value, estimate := series.eval_e(0.5)
	assert_close(value, 0.5, 1e-14)
	assert estimate >= 0.0
}

fn test_trigonometric_approximations() {
	s, s_err := sin_e(math.pi / 6.0)
	c, c_err := cos_e(math.pi / 3.0)
	assert_close(sin(math.pi / 6.0), 0.5, 1e-14)
	assert_close(cos(math.pi / 3.0), 0.5, 1e-14)
	assert_close(s, 0.5, 1e-14)
	assert_close(c, 0.5, 1e-14)
	assert s_err >= 0.0
	assert c_err >= 0.0
}

fn test_error_functions() {
	assert_close(erf(0.5), 0.5204998778130465, 1e-14)
	assert_close(erfc(0.5), 0.4795001221869535, 1e-14)
	assert_close(erf(0.5) + erfc(0.5), 1.0, 1e-15)
}

fn test_fibonacci_function() {
	assert fib(0) == 0
	assert fib(1) == 1
	assert fib(10) == 55
	assert fib(20) == 6765
}

fn test_gamma_and_log_gamma_functions() {
	assert_close(gamma(0.5), math.sqrt(math.pi), 1e-14)
	assert_close(gamma(5.0), 24.0, 1e-13)
	assert_close(log_gamma(5.0), math.log(24.0), 1e-14)
	log_abs, sign := log_gamma_sign(-0.5)
	assert_close(log_abs, math.log(2.0 * math.sqrt(math.pi)), 1e-14)
	assert sign == -1
}

fn test_digamma_and_psi_functions() {
	known := -0.5772156649015329
	assert_close(digamma(1.0), known, 1e-14)
	assert_close(psi(1.0), known, 1e-14)
	assert_close(digamma(0.5), -1.9635100260214235, 2e-6)
}

fn test_hypot_functions() {
	assert_close(hypot(3.0, 4.0), 5.0, 1e-15)
	value, estimate := hypot_e(3.0, 4.0)
	assert_close(value, 5.0, 1e-15)
	assert estimate >= 0.0
}

fn test_modified_bessel_functions() {
	assert_close(bessel_i0(0.0), 1.0, 1e-14)
	assert_close(bessel_i1(1.0), 0.565159103992485, 1e-14)
	assert_close(bessel_in(2, 1.0), 0.1357476697670383, 1e-13)
	assert_close(bessel_k0(1.0), 0.4210244382407083, 1e-14)
	assert_close(bessel_k1(1.0), 0.6019072301972346, 1e-14)
	assert_close(bessel_kn(2, 1.0), 1.6248388986351774, 1e-13)
}

fn test_complex_gamma_and_log_gamma() {
	z := cmplx.complex(1.0, 0.0)
	g := cgamma(z)
	lg := clog_gamma(z)
	assert_close(g.re, 1.0, 1e-14)
	assert_close(g.im, 0.0, 1e-14)
	assert_close(lg.re, 0.0, 1e-14)
	assert_close(lg.im, 0.0, 1e-14)
}

fn test_inverse_error_functions_reference_values() {
	assert_close(erf_inv(0.5), 0.4769362762044699, 2e-15)
	assert_close(erf_inv(0.9), 1.163087153676674, 2e-15)
	assert_close(erf_inv(-0.9), -1.163087153676674, 2e-15)
	assert_close(erfc_inv(0.1), 1.163087153676674, 2e-15)
	assert_close(erfc_inv(1e-10), 4.572824967389485, 2e-14)
	assert_close(erfc_inv(1e-100), 15.065574702592645, 2e-14)
	assert_close(erfc_inv(1e-300), 26.209469960516124, 2e-14)
	assert_close(erfc_inv(5e-324), 27.213293210812946, 2e-14)
	assert_close(erfc_inv(0.9999999999999998), 1.967819075360828e-16, 1e-30)
}

fn test_inverse_error_functions_round_trip() {
	for target in [1e-12, 0.01, 0.1, 0.5, 0.9, 0.99, 0.9999999999999998] {
		actual := erf(erf_inv(target))
		assert_close(actual, target, 3e-16)
	}
	for target in [5e-324, 1e-300, 1e-100, 1e-10, 0.1, 0.5, 1.5, 1.9, 2.0 - 1e-15] {
		actual := erfc(erfc_inv(target))
		tolerance := if target < 1e-200 { target * 2e-13 } else { math.max(target * 2e-14, 1e-16) }
		assert math.abs(actual - target) <= tolerance, 'erfc round trip ${target}: ${actual}'
	}
}

fn test_inverse_error_functions_domains_and_endpoints() {
	assert math.is_inf(erf_inv(-1.0), -1)
	assert math.is_inf(erf_inv(1.0), 1)
	assert math.is_inf(erfc_inv(0.0), 1)
	assert math.is_inf(erfc_inv(2.0), -1)
	assert erfc_inv(1.0) == 0.0
	assert math.is_nan(erf_inv(-1.0001))
	assert math.is_nan(erf_inv(1.0001))
	assert math.is_nan(erfc_inv(-1e-10))
	assert math.is_nan(erfc_inv(2.0001))
	assert math.is_nan(erf_inv(math.nan()))
	assert math.is_nan(erfc_inv(math.nan()))
	assert math.is_nan(erf_inv(math.inf(1)))
	assert math.is_nan(erfc_inv(math.inf(-1)))
}

fn test_scaled_complementary_error_function_reference_values() {
	assert_close(erfcx(0.0), 1.0, 1e-15)
	assert_close(erfcx(1.0), 0.427583576155807, 2e-15)
	assert_close(erfcx(-1.0), 5.008980080762283, 2e-14)
	assert_close(erfcx(5.0), 0.11070463773306863, 2e-15)
	assert_close(erfcx(10.0), 0.05614099274382259, 2e-15)
	assert_close(erfcx(100.0), 0.005641613782989433, 2e-16)
}

fn test_scaled_complementary_error_function_extremes() {
	assert erfcx(26.0) > erfcx(27.0)
	assert erfcx(27.0) > erfcx(100.0)
	assert erfcx(1e308) > 0.0
	assert_close(erfcx(1e308) / 1e-308, 0.5641895835477563, 1e-15)
	assert !math.is_inf(erfcx(-26.6), 0)
	assert math.is_inf(erfcx(-27.0), 1)
	assert erfcx(math.inf(1)) == 0.0
	assert math.is_inf(erfcx(math.inf(-1)), 1)
	assert math.is_nan(erfcx(math.nan()))
}
