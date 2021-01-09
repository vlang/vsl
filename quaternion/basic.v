
module quaternion

import vsl.vmath

pub fn (q1 Quaternion) + (q2 Quaternion) Quaternion {
	return quaternion(q1.w + q2.w, q1.x + q2.x, q1.y + q2.y, q1.z + q2.z)
}

pub fn (q1 Quaternion) - (q2 Quaternion) Quaternion {
	return quaternion(q1.w - q2.w, q1.x - q2.x, q1.y - q2.y, q1.z - q2.z)
}

pub fn (q1 Quaternion) * (q2 Quaternion) Quaternion {
	return quaternion(q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z, q1.w * q2.x +
		q1.x * q2.w + q1.y * q2.z - q1.z * q2.y, q1.w * q2.y - q1.x * q2.z + q1.y * q2.w + q1.z * q2.x,
		q1.w * q2.z + q1.x * q2.y - q1.y * q2.x + q1.z * q2.w)
}

pub fn (q1 Quaternion) / (q2 Quaternion) Quaternion {
	q2norm := q2.norm()
	return quaternion((q1.w * q2.w + q1.x * q2.x + q1.y * q2.y + q1.z * q2.z) / q2norm,
		(-q1.w * q2.x + q1.x * q2.w - q1.y * q2.z + q1.z * q2.y) / q2norm, (-q1.w * q2.y +
		q1.x * q2.z + q1.y * q2.w - q1.z * q2.x) /
		q2norm, (-q1.w * q2.z - q1.x * q2.y + q1.y * q2.x + q1.z * q2.w) / q2norm)
}

pub fn (q1 Quaternion) add(q2 Quaternion) Quaternion {
	return quaternion(q1.w + q2.w, q1.x + q2.x, q1.y + q2.y, q1.z + q2.z)
}

pub fn (q1 Quaternion) subtract(q2 Quaternion) Quaternion {
	return quaternion(q1.w - q2.w, q1.x - q2.x, q1.y - q2.y, q1.z - q2.z)
}

pub fn (q1 Quaternion) multiply(q2 Quaternion) Quaternion {
	return quaternion(q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z, q1.w * q2.x +
		q1.x * q2.w + q1.y * q2.z - q1.z * q2.y, q1.w * q2.y - q1.x * q2.z + q1.y * q2.w + q1.z * q2.x,
		q1.w * q2.z + q1.x * q2.y - q1.y * q2.x + q1.z * q2.w)
}

pub fn (q1 Quaternion) divide(q2 Quaternion) Quaternion {
	q2norm := q2.norm()
	return quaternion((q1.w * q2.w + q1.x * q2.x + q1.y * q2.y + q1.z * q2.z) / q2norm,
		(-q1.w * q2.x + q1.x * q2.w - q1.y * q2.z + q1.z * q2.y) / q2norm, (-q1.w * q2.y +
		q1.x * q2.z + q1.y * q2.w - q1.z * q2.x) /
		q2norm, (-q1.w * q2.z - q1.x * q2.y + q1.y * q2.x + q1.z * q2.w) / q2norm)
}

pub fn (q Quaternion) scalar_add(s f64) Quaternion {
	return quaternion(s + q.w, q.x, q.y, q.z)
}

pub fn (q Quaternion) scalar_subtract(s f64) Quaternion {
	return quaternion(s - q.w, q.x, q.y, q.z)
}

pub fn (q Quaternion) scalar_multiply(s f64) Quaternion {
	return quaternion(s * q.w, s * q.x, s * q.y, s * q.z)
}

pub fn (q Quaternion) scalar_divide(s f64) Quaternion {
	qnorm := q.norm()
	return quaternion((s * q.w) / qnorm, (-s * q.x) / qnorm, (-s * q.y) / qnorm, (-s * q.z) / qnorm)
}

pub fn (q Quaternion) opposite() Quaternion {
	return quaternion(-q.w, -q.x, -q.y, -q.z)
}

pub fn (q Quaternion) conjugate() Quaternion {
	return quaternion(q.w, -q.x, -q.y, -q.z)
}

pub fn (q Quaternion) inverse() Quaternion {
	qnorm := q.norm()
	return quaternion(q.w / qnorm, -q.x / qnorm, -q.y / qnorm, -q.z / qnorm)
}

pub fn (q Quaternion) norm() f64 {
	return q.w * q.w + q.x * q.x + q.y * q.y + q.z * q.z
}

pub fn (q Quaternion) abs() f64 {
	return vmath.sqrt(q.norm())
}

pub fn (q Quaternion) angle() f64 {
	return 2.0 * q.log().abs()
}

pub fn (q Quaternion) normalized() Quaternion {
	qabs := q.abs()
	return if qabs == 0.0 {
		q
	} else {
		quaternion(q.w / qabs, q.x / qabs, q.y / qabs, q.z / qabs)
	}
}
