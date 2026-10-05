module quaternion

import math

fn test_axis_angle_rotation_of_basis_vector() {
	q := from_axis_anglef3(math.pi / 2.0, 0.0, 0.0, 1.0)
	point := quaternion(0.0, 1.0, 0.0, 0.0)
	rotated := q.multiply(point).multiply(q.conjugate())
	assert math.abs(rotated.x) < 1e-12
	assert math.abs(rotated.y - 1.0) < 1e-12
	assert math.abs(rotated.z) < 1e-12
	assert math.abs(q.angle() - math.pi / 2.0) < 1e-12
}

fn test_rotation_distances_account_for_quaternion_sign() {
	q := from_axis_anglef3(math.pi / 3.0, 0.0, 1.0, 0.0)
	assert math.abs(q.rotation_chordal_distance(q.opposite())) < 1e-12
	assert math.abs(q.rotation_intrinsic_distance(q.opposite())) < 1e-12
}
