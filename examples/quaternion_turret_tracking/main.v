module main

import math
import vsl.quaternion

struct Vec3 {
	x f64
	y f64
	z f64
}

fn main() {
	println('== quaternion turret tracking ==')

	// Game-dev style scenario:
	// turret rotates from current orientation to target orientation smoothly,
	// while we monitor angular error over time.

	current := quaternion.id()
	target := quaternion.from_euler_angles(0.0, math.pi / 3.0, math.pi / 6.0).normalized()
	forward := Vec3{0.0, 0.0, 1.0}

	println('step  angle_error_deg  forward_dir(x,y,z)')
	for step := 0; step <= 8; step++ {
		tau := f64(step) / 8.0
		q := safe_blend(current, target, tau)
		err := q.rotation_intrinsic_distance(target)
		dir := rotate_vector(q, forward)
		println('${step:4d}  ${rad2deg(err):14.6f}  (${dir.x:7.4f}, ${dir.y:7.4f}, ${dir.z:7.4f})')
	}

	println('')
	println('method comparison at tau=0.5')
	tau_mid := 0.5
	q_lerp := current.lerp(target, tau_mid).normalized()
	q_nlerp := current.nlerp(target, tau_mid).normalized()
	q_slerp := safe_blend(current, target, tau_mid)

	err_lerp := rad2deg(q_lerp.rotation_intrinsic_distance(target))
	err_nlerp := rad2deg(q_nlerp.rotation_intrinsic_distance(target))
	err_slerp := rad2deg(q_slerp.rotation_intrinsic_distance(target))

	println('  lerp  error_deg=${err_lerp:8.4f}')
	println('  nlerp error_deg=${err_nlerp:8.4f}')
	println('  slerp error_deg=${err_slerp:8.4f}')
}

fn safe_blend(start quaternion.Quaternion, target quaternion.Quaternion, tau f64) quaternion.Quaternion {
	t := aligned_target(start, target)
	s := start.slerp(t, tau).normalized()
	if s.is_finite() && !s.is_zero() {
		return s
	}
	return start.nlerp(t, tau).normalized()
}

fn aligned_target(start quaternion.Quaternion, target quaternion.Quaternion) quaternion.Quaternion {
	return if start.rotor_chordal_distance(target) <= math.sqrt2 {
		target
	} else {
		target.opposite()
	}
}

fn rotate_vector(q quaternion.Quaternion, v Vec3) Vec3 {
	vq := quaternion.quaternion(0.0, v.x, v.y, v.z)
	rot := q.multiply(vq).multiply(q.conjugate())
	return Vec3{rot.x, rot.y, rot.z}
}

fn rad2deg(rad f64) f64 {
	return rad * 180.0 / math.pi
}
