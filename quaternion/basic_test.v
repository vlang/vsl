module quaternion

import math

fn assert_quaternion_close(actual Quaternion, expected Quaternion, tolerance f64) {
	assert math.abs(actual.w - expected.w) < tolerance
	assert math.abs(actual.x - expected.x) < tolerance
	assert math.abs(actual.y - expected.y) < tolerance
	assert math.abs(actual.z - expected.z) < tolerance
}

fn test_identity_arithmetic_and_inverse() {
	q := quaternion(1.0, 2.0, -3.0, 4.0)
	assert_quaternion_close(q.multiply(id()), q, 1e-12)
	assert_quaternion_close(q.add(q.opposite()), quaternion(0.0, 0.0, 0.0, 0.0), 1e-12)
	assert_quaternion_close(q.multiply(q.inverse()), id(), 1e-12)
	assert math.abs(q.norm() - 30.0) < 1e-12
	assert math.abs(q.abs() - math.sqrt(30.0)) < 1e-12
}

fn test_normalize_and_conjugate() {
	q := quaternion(1.0, 2.0, 2.0, 0.0)
	normalized := q.normalized()
	assert math.abs(normalized.abs() - 1.0) < 1e-12
	assert_quaternion_close(q.multiply(q.conjugate()), quaternion(q.norm(), 0.0, 0.0, 0.0), 1e-12)
}
