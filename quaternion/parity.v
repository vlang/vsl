module quaternion

// parity_conjugate exposes this operation as part of the public API.
pub fn (q Quaternion) parity_conjugate() Quaternion {
	return quaternion(q.w, q.x, q.y, q.z)
}

// parity_symmetric_part exposes this operation as part of the public API.
pub fn (q Quaternion) parity_symmetric_part() Quaternion {
	return quaternion(q.w, q.x, q.y, q.z)
}

// parity_antisymmetric_part exposes this operation as part of the public API.
pub fn (q Quaternion) parity_antisymmetric_part() Quaternion {
	return quaternion(0.0, 0.0, 0.0, 0.0)
}

// x_parity_conjugate exposes this operation as part of the public API.
pub fn (q Quaternion) x_parity_conjugate() Quaternion {
	return quaternion(q.w, q.x, -q.y, -q.z)
}

// x_parity_symmetric_part exposes this operation as part of the public API.
pub fn (q Quaternion) x_parity_symmetric_part() Quaternion {
	return quaternion(q.w, q.x, 0.0, 0.0)
}

// x_parity_antisymmetric_part exposes this operation as part of the public API.
pub fn (q Quaternion) x_parity_antisymmetric_part() Quaternion {
	return quaternion(0.0, 0.0, q.y, q.z)
}

// y_parity_conjugate exposes this operation as part of the public API.
pub fn (q Quaternion) y_parity_conjugate() Quaternion {
	return quaternion(q.w, -q.x, q.y, -q.z)
}

// y_parity_symmetric_part exposes this operation as part of the public API.
pub fn (q Quaternion) y_parity_symmetric_part() Quaternion {
	return quaternion(q.w, 0.0, q.y, 0.0)
}

// y_parity_antisymmetric_part exposes this operation as part of the public API.
pub fn (q Quaternion) y_parity_antisymmetric_part() Quaternion {
	return quaternion(0.0, q.x, 0.0, q.z)
}

// z_parity_conjugate exposes this operation as part of the public API.
pub fn (q Quaternion) z_parity_conjugate() Quaternion {
	return quaternion(q.w, -q.x, -q.y, q.z)
}

// z_parity_symmetric_part exposes this operation as part of the public API.
pub fn (q Quaternion) z_parity_symmetric_part() Quaternion {
	return quaternion(q.w, 0.0, 0.0, q.z)
}

// z_parity_antisymmetric_part exposes this operation as part of the public API.
pub fn (q Quaternion) z_parity_antisymmetric_part() Quaternion {
	return quaternion(0.0, q.x, q.y, 0.0)
}
