// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module quaternion

pub fn (q Quaternion) parity_conj() Quaternion {
	return quaternion(q.w, q.x, q.y, q.z)
}

pub fn (q Quaternion) parity_symmetric_part() Quaternion {
	return quaternion(q.w, q.x, q.y, q.z)
}

pub fn (q Quaternion) parity_antisymmetric_part() Quaternion {
	return quaternion(0.0, 0.0, 0.0, 0.0)
}

pub fn (q Quaternion) x_parity_conj() Quaternion {
	return quaternion(q.w, q.x, -q.y, -q.z)
}

pub fn (q Quaternion) x_parity_symmetric_part() Quaternion {
	return quaternion(q.w, q.x, 0.0, 0.0)
}

pub fn (q Quaternion) x_parity_antisymmetric_part() Quaternion {
	return quaternion(0.0, 0.0, q.y, q.z)
}

pub fn (q Quaternion) y_parity_conj() Quaternion {
	return quaternion(q.w, -q.x, q.y, -q.z)
}

pub fn (q Quaternion) y_parity_symmetric_part() Quaternion {
	return quaternion(q.w, 0.0, q.y, 0.0)
}

pub fn (q Quaternion) y_parity_antisymmetric_part() Quaternion {
	return quaternion(0.0, q.x, 0.0, q.z)
}

pub fn (q Quaternion) z_parity_conj() Quaternion {
	return quaternion(q.w, -q.x, -q.y, q.z)
}

pub fn (q Quaternion) z_parity_symmetric_part() Quaternion {
	return quaternion(q.w, 0.0, 0.0, q.z)
}

pub fn (q Quaternion) z_parity_antisymmetric_part() Quaternion {
	return quaternion(0.0, q.x, q.y, 0.0)
}
