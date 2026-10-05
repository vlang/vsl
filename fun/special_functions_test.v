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
