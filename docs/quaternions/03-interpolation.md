# Quaternion Interpolation

Learn how to smoothly interpolate between quaternion rotations for animations
and smooth transitions.

## What You'll Learn

- Linear interpolation (LERP)
- Normalized linear interpolation (NLERP)
- Spherical linear interpolation (SLERP)
- Choosing the right interpolation method

## Prerequisites

- [Quaternion Introduction](01-introduction.md)
- [Quaternion Rotations](02-rotations.md)
- Understanding of interpolation concepts

## Theory

Interpolating between rotations requires special care. Simple linear
interpolation doesn't work well because:
- Quaternions represent points on a 4D sphere
- Linear interpolation doesn't follow the sphere's surface
- Results may not be unit quaternions

VSL provides three interpolation methods with different trade-offs.

## Linear Interpolation (LERP)

Simplest but least accurate:

```v
import vsl.quaternion
import math

fn main() {
	// Start rotation: 0° around x-axis
	q1 := quaternion.from_axis_anglef3(0.0, 1.0, 0.0, 0.0)

	// End rotation: 180° around x-axis
	q2 := quaternion.from_axis_anglef3(math.pi, 1.0, 0.0, 0.0)

	// Interpolate at t = 0.5 (halfway)
	t := 0.5
	q_interp := q1.lerp(q2, t)

	println('Interpolated quaternion: ${q_interp}')
	println('Magnitude: ${q_interp.abs()}') // May not be 1.0!
}
```

**Use when**: Speed is critical and accuracy isn't important.

## Normalized Linear Interpolation (NLERP)

LERP followed by normalization:

```v
import vsl.quaternion
import math

fn main() {
	q1 := quaternion.from_axis_anglef3(0.0, 1.0, 0.0, 0.0)
	q2 := quaternion.from_axis_anglef3(math.pi, 1.0, 0.0, 0.0)

	t := 0.5
	q_interp := q1.nlerp(q2, t)

	println('NLERP quaternion: ${q_interp}')
	println('Magnitude: ${q_interp.abs()}') // Should be ~1.0
}
```

**Use when**: You need unit quaternions but can accept slight speed variation.

## Spherical Linear Interpolation (SLERP)

Most accurate, follows the shortest path on the 4D sphere:

```v
import vsl.quaternion
import math

fn main() {
	q1 := quaternion.from_axis_anglef3(0.0, 1.0, 0.0, 0.0)
	q2 := quaternion.from_axis_anglef3(math.pi, 1.0, 0.0, 0.0)

	t := 0.5
	q_interp := q1.slerp(q2, t)

	println('SLERP quaternion: ${q_interp}')
	println('Magnitude: ${q_interp.abs()}') // Should be 1.0
}
```

**Use when**: You need smooth, accurate rotation interpolation (most common case).

## Comparing Methods

```v
import vsl.quaternion
import math

fn main() {
	q1 := quaternion.from_axis_anglef3(0.0, 1.0, 0.0, 0.0)
	q2 := quaternion.from_axis_anglef3(math.pi / 2.0, 0.0, 1.0, 0.0)

	t := 0.5

	q_lerp := q1.lerp(q2, t)
	q_nlerp := q1.nlerp(q2, t)
	q_slerp := q1.slerp(q2, t)

	println('LERP:  ${q_lerp}, magnitude: ${q_lerp.abs()}')
	println('NLERP: ${q_nlerp}, magnitude: ${q_nlerp.abs()}')
	println('SLERP: ${q_slerp}, magnitude: ${q_slerp.abs()}')
}
```

## Animating Rotations

Create smooth rotation animations:

```v
import vsl.quaternion
import vsl.plot
import math

fn rotate_point(q quaternion.Quaternion, px f64, py f64, pz f64) (f64, f64, f64) {
	p := quaternion.quaternion(0.0, px, py, pz)
	q_conj := q.conjugate()
	rotated := q.multiply(p).multiply(q_conj)
	return rotated.x, rotated.y, rotated.z
}

fn main() {
	// Start and end rotations
	q_start := quaternion.from_axis_anglef3(0.0, 1.0, 0.0, 0.0)
	q_end := quaternion.from_axis_anglef3(math.pi, 1.0, 0.0, 0.0)

	// Original point
	px, py, pz := 1.0, 0.0, 0.0

	// Interpolate over 20 steps
	steps := 20
	mut x_path := []f64{}
	mut y_path := []f64{}
	mut z_path := []f64{}

	for i in 0 .. steps {
		t := f64(i) / f64(steps - 1)
		q_interp := q_start.slerp(q_end, t)
		x, y, z := rotate_point(q_interp, px, py, pz)
		x_path << x
		y_path << y
		z_path << z
	}

	// Plot rotation path
	mut plt := plot.Plot.new()
	plt.scatter3d(
		x:    x_path
		y:    y_path
		z:    z_path
		mode: 'lines+markers'
		name: 'Rotation Path'
	)
	plt.layout(title: 'SLERP Rotation Animation')
	plt.show()!
}
```

## SQUAD (Spherical Quadrangle Interpolation)

For smooth interpolation through multiple keyframes:

```v
import vsl.quaternion
import math

fn main() {
	// Keyframe quaternions
	q0 := quaternion.from_axis_anglef3(0.0, 1.0, 0.0, 0.0)
	q1 := quaternion.from_axis_anglef3(math.pi / 4.0, 0.0, 1.0, 0.0)
	q2 := quaternion.from_axis_anglef3(math.pi / 2.0, 0.0, 0.0, 1.0)
	q3 := quaternion.from_axis_anglef3(math.pi, 1.0, 0.0, 0.0)

	// Compute intermediate quaternions (simplified - in practice use proper tangent computation)
	a1 := q1 // Tangent at q1
	b2 := q2 // Tangent at q2

	// Interpolate between q1 and q2 using SQUAD
	t := 0.5
	q_squad := q1.squad(t, a1, b2, q2)

	println('SQUAD interpolated: ${q_squad}')
}
```

## Choosing the Right Method

| Method | Speed | Accuracy | Use Case |
|--------|-------|----------|----------|
| LERP | Fastest | Low | Quick approximations |
| NLERP | Fast | Medium | Real-time with unit quaternions |
| SLERP | Slower | Highest | Smooth animations, accurate rotations |
| SQUAD | Slowest | Highest | Multi-keyframe animations |

## Exercises

1. **Compare methods**: Visualize the difference between LERP, NLERP, and SLERP
2. **Animate rotation**: Create a smooth rotation animation using SLERP
3. **Keyframe animation**: Use SQUAD to interpolate through multiple rotations
4. **Performance test**: Measure the performance difference between methods

## Next Steps

- [Visualization](04-visualization.md) - Advanced visualization techniques
- [Examples](../../examples/quaternion_interpolation_animation/) - Animation examples
- [Rotations](02-rotations.md) - Review rotation basics

## Related Examples

- `examples/quaternion_interpolation_animation` - Animated interpolation
- `examples/quaternion_rotation_3d` - 3D rotation visualization
- `examples/quaternion_orientation_tracking` - Orientation tracking
