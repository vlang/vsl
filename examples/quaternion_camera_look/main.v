module main

import math
import vsl.quaternion

struct Vec3 {
	x f64
	y f64
	z f64
}

fn main() {
	println('== quaternion camera look pipeline ==')

	// Game-dev style setup:
	// - camera starts looking forward (+Z)
	// - apply yaw then pitch through axis-angle quaternions
	// - rotate a basis vector to get final look direction
	forward := Vec3{0.0, 0.0, 1.0}
	yaw := math.pi / 4.0 // 45° around world up axis
	pitch := -math.pi / 9.0 // -20° around camera local right axis

	q_yaw := quaternion.from_axis_anglef3(yaw, 0.0, 1.0, 0.0)
	q_pitch := quaternion.from_axis_anglef3(pitch, 1.0, 0.0, 0.0)

	// Compose yaw then pitch (order matters)
	orientation := q_pitch.multiply(q_yaw).normalized()
	look_dir := rotate_vector(orientation, forward)

	println('yaw(deg)=${rad2deg(yaw):7.3f} pitch(deg)=${rad2deg(pitch):7.3f}')
	println('orientation quaternion: ${orientation}')
	println('look direction: (${look_dir.x:7.4f}, ${look_dir.y:7.4f}, ${look_dir.z:7.4f})')

	// Sanity checks relevant for runtime usage
	println('orientation_norm=${orientation.abs():7.5f}')
	println('look_dir_norm=${norm3(look_dir):7.5f}')

	// Simulate toggling target orientation (for aim assist / lock-on)
	lock_target := quaternion.from_axis_anglef3(math.pi / 2.0, 0.0, 1.0, 0.0) // 90° yaw
	blend := 0.35
	blended := safe_blend(orientation, lock_target, blend)
	blended_look := rotate_vector(blended, forward)

	println('')
	println('lock-on blend tau=${blend:4.2f}')
	println('blended look direction: (${blended_look.x:7.4f}, ${blended_look.y:7.4f}, ${blended_look.z:7.4f})')
}

fn safe_blend(start quaternion.Quaternion, target quaternion.Quaternion, tau f64) quaternion.Quaternion {
	t := aligned_target(start, target)
	s := start.slerp(t, tau).normalized()
	if s.is_finite() && !s.is_zero() {
		return s
	}
	// Robust fallback often used in gameplay code paths.
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

fn norm3(v Vec3) f64 {
	return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
}

fn rad2deg(rad f64) f64 {
	return rad * 180.0 / math.pi
}
