module quaternion

import math

fn assert_exponentiation_quaternion_close(actual Quaternion, expected Quaternion, tolerance f64) {
	assert math.abs(actual.w - expected.w) < tolerance
	assert math.abs(actual.x - expected.x) < tolerance
	assert math.abs(actual.y - expected.y) < tolerance
	assert math.abs(actual.z - expected.z) < tolerance
}

fn test_scalar_pow_positive_and_zero_bases() {
	exponent := quaternion(0.5, 0.0, 0.0, 0.0)
	assert_exponentiation_quaternion_close(exponent.scalar_pow(4.0), quaternion(2.0, 0.0, 0.0, 0.0),
		1e-12)
	assert_exponentiation_quaternion_close(quaternion(0.0, 0.0, 0.0, 0.0).scalar_pow(0.0), id(), 1e-12)
	assert_exponentiation_quaternion_close(exponent.scalar_pow(0.0), quaternion(0.0, 0.0, 0.0, 0.0),
		1e-12)
}

fn test_scalar_pow_negative_base() {
	exponent := quaternion(0.5, 0.0, 0.0, 0.0)
	assert_exponentiation_quaternion_close(exponent.scalar_pow(-4.0), quaternion(0.0, 2.0, 0.0, 0.0),
		1e-12)
}
