module quaternion

import math

// is_nan exposes this operation as part of the public API.
pub fn (q Quaternion) is_nan() bool {
	return math.is_nan(q.w) || math.is_nan(q.x) || math.is_nan(q.y) || math.is_nan(q.z)
}

// is_zero exposes this operation as part of the public API.
pub fn (q Quaternion) is_zero() bool {
	return if q.is_nan() { true } else { q.w == 0.0 && q.x == 0.0 && q.y == 0.0 && q.z == 0.0 }
}

// is_inf exposes this operation as part of the public API.
pub fn (q Quaternion) is_inf() bool {
	return math.is_inf(q.w, 0) || math.is_inf(q.x, 0) || math.is_inf(q.y, 0) || math.is_inf(q.z, 0)
}

fn is_finite(a f64) bool {
	return !math.is_nan(a) && !math.is_inf(a, 0)
}

// is_finite exposes this operation as part of the public API.
pub fn (q Quaternion) is_finite() bool {
	return is_finite(q.w) && is_finite(q.x) && is_finite(q.y) && is_finite(q.z)
}

// equal exposes this operation as part of the public API.
pub fn (q1 Quaternion) equal(q2 Quaternion) bool {
	return !q1.is_nan() && !q2.is_nan() && q1.w == q2.w && q1.x == q2.x && q1.y == q2.y
		&& q1.z == q2.z
}

fn choose(c bool, a bool, b bool) bool {
	return if c { a } else { b }
}

// is_less exposes this operation as part of the public API.
pub fn (q1 Quaternion) is_less(q2 Quaternion) bool {
	return (!q1.is_nan() && !q2.is_nan())
		&& choose(q1.w != q2.w, q1.w < q2.w, choose(q1.x != q2.x, q1.x < q2.x, choose(q1.y != q2.y, q1.y < q2.y, choose(q1.z != q2.z, q1.z < q2.z, false))))
}

// is_greater exposes this operation as part of the public API.
pub fn (q1 Quaternion) is_greater(q2 Quaternion) bool {
	return (!q1.is_nan() && !q2.is_nan())
		&& choose(q1.w != q2.w, q1.w > q2.w, choose(q1.x != q2.x, q1.x > q2.x, choose(q1.y != q2.y, q1.y > q2.y, choose(q1.z != q2.z, q1.z > q2.z, false))))
}

// is_lessequal exposes this operation as part of the public API.
pub fn (q1 Quaternion) is_lessequal(q2 Quaternion) bool {
	return (!q1.is_nan() && !q2.is_nan())
		&& choose(q1.w != q2.w, q1.w < q2.w, choose(q1.x != q2.x, q1.x < q2.x, choose(q1.y != q2.y, q1.y < q2.y, choose(q1.z != q2.z, q1.z < q2.z, true))))
	// Note that the final possibility __is 1, whereas in
	// `is_less` it was 0.  This distinction correctly
	// accounts for equality.
}

// is_greaterequal exposes this operation as part of the public API.
pub fn (q1 Quaternion) is_greaterequal(q2 Quaternion) bool {
	return (!q1.is_nan() && !q2.is_nan())
		&& choose(q1.w != q2.w, q1.w > q2.w, choose(q1.x != q2.x, q1.x > q2.x, choose(q1.y != q2.y, q1.y > q2.y, choose(q1.z != q2.z, q1.z > q2.z, true))))
	// Note that the final possibility __is 1, whereas in
	// `is_greater` it was 0.  This distinction correctly
	// accounts for equality.
}
