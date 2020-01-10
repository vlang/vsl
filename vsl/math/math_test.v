// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module math

fn test_gcd() {
	assert gcd(6, 9) == 3
	assert gcd(6, -9) == 3
	assert gcd(-6, -9) == 3
	assert gcd(0, 0) == 0
}

fn test_lcm() {
	assert lcm(2, 3) == 6
	assert lcm(-2, 3) == 6
	assert lcm(-2, -3) == 6
	assert lcm(0, 0) == 0
}

fn test_digits() {
	digits_in_10th_base := digits(125, 10)
	assert digits_in_10th_base[0] == 5
	assert digits_in_10th_base[1] == 2
	assert digits_in_10th_base[2] == 1

	digits_in_16th_base := digits(15, 16)
	assert digits_in_16th_base[0] == 15

	negative_digits := digits(-4, 2)
	assert negative_digits[2] == -1
}

fn test_erf() {
	assert erf(0) == 0
	assert erf(1.5) + erf(-1.5) == 0
	assert erfc(0) == 1
	assert erf(2.5) + erfc(2.5) == 1
	assert erfc(3.6) + erfc(-3.6) == 2
}

fn test_gamma() {
	assert gamma(1) == 1
	assert gamma(5) == 24
	sval := '2.453737'
	assert log_gamma(4.5).str() == sval
	assert log(gamma(4.5)).str() == sval
	assert abs( log_gamma(4.5) - log(gamma(4.5)) ) < 0.000001
	// assert log_gamma(4.5) == log(gamma(4.5)) /* <-- fails on alpine/musl
}

fn test_mod() {
	assert 4 % 2 == 0
	x := 2
	assert u64(5) % x == 1
	mut a := 10
	a %= 2
	assert a == 0
}

fn test_trig() {
        assert compare(sin(0.0), 0.0)
        assert compare(sin(pi_2), 1.0)
        assert compare(sin(pi), 0.0)
        assert compare(sin(3.0 * pi_2), -1.0)
        assert compare(sin(-pi_2), -1.0)

        assert compare(cos(0.0), 1.0)
        assert compare(cos(pi_2), 0.0)
        assert compare(cos(pi), -1.0)
        assert compare(cos(3.0 * pi_2), 0.0)
        assert compare(cos(-pi), -1.0)

        assert compare(tan(0.0), 0.0)
        assert compare(tan(pi_4), 1.0)
        assert compare(tan(3.0 * pi_4), -1.0)
        assert compare(tan(pi), 0.0)
        assert compare(tan(-pi_4), -1.0)

        assert compare(atan(0.0), 0.0)
        assert compare(atan(1.0), pi_4)
        assert compare(atan(-1.0), -pi_4)
}

fn test_pow() {
        assert compare(pow(2.0, 0), 1.0)
        assert compare(pow(2.0, 4), 16.0)
        assert compare(pow(2.0, -2), 0.25)
        assert compare(pow(2.0, -2.5), 0.17677669529)
        assert compare(pow(2.0, 4.1), 17.1483754006)
}

// Helper methods for comparing floats
[inline]
fn compare(x, y f64) bool {
	return compare_near(x, y, 1e-6)
}

fn compare_near(x, y, tolerance f64) bool {
	// Special case for zeroes
	if x < tolerance && x > (-1.0 * tolerance) && y < tolerance && y > (-1.0 * tolerance) {
		return true
	}
	diff := math.abs(x - y)
	mean := math.abs(x + y) / 2.0
	return if math.is_nan(diff / mean) { true } else { ((diff / mean) < tolerance) }
}
