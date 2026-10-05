module quaternion

import math

fn assert_interpolation_quaternion_close(actual Quaternion, expected Quaternion, tolerance f64) {
	assert math.abs(actual.w - expected.w) < tolerance
	assert math.abs(actual.x - expected.x) < tolerance
	assert math.abs(actual.y - expected.y) < tolerance
	assert math.abs(actual.z - expected.z) < tolerance
}

fn test_lerp_nlerp_and_slerp_midpoints() {
	start := id()
	end := from_axis_anglef3(math.pi / 2.0, 0.0, 0.0, 1.0)
	want := from_axis_anglef3(math.pi / 4.0, 0.0, 0.0, 1.0)

	assert math.abs(start.lerp(end, 0.5).abs() - math.cos(math.pi / 8.0)) < 1e-12
	assert_interpolation_quaternion_close(start.nlerp(end, 0.5), want, 1e-12)
	assert_interpolation_quaternion_close(start.slerp(end, 0.5), want, 1e-12)
}

fn test_slerp_follows_shortest_rotation_path() {
	start := id()
	end := from_axis_anglef3(3.0 * math.pi / 2.0, 0.0, 0.0, 1.0)
	want := from_axis_anglef3(-math.pi / 4.0, 0.0, 0.0, 1.0)
	assert_interpolation_quaternion_close(start.slerp(end, 0.5), want, 1e-12)
}
