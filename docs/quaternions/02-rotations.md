# Quaternion Rotations

Learn how to use quaternions to rotate 3D points and vectors efficiently.

## What You'll Learn

- Rotating 3D points with quaternions
- Composing multiple rotations
- Converting between quaternions and rotation matrices
- Understanding rotation distances

## Prerequisites

- [Quaternion Introduction](01-introduction.md)
- Basic 3D geometry concepts
- Understanding of matrix multiplication

## Theory

To rotate a 3D point **p** using quaternion **q**, we use:

**p' = q p q⁻¹**

Where:
- `p` is treated as a pure quaternion (0, px, py, pz)
- `q` is a unit quaternion representing the rotation
- `q⁻¹` is the inverse (conjugate for unit quaternions)

For unit quaternions, the inverse equals the conjugate: **q⁻¹ = q***

## Rotating a Point

### Manual Rotation

```v
import vsl.quaternion
import math

fn rotate_point(q quaternion.Quaternion, px f64, py f64, pz f64) (f64, f64, f64) {
	// Treat point as pure quaternion
	p := quaternion.quaternion(0.0, px, py, pz)

	// Get conjugate (inverse for unit quaternion)
	q_conj := q.conjugate()

	// Rotate: p' = q * p * q⁻¹
	rotated := q.multiply(p).multiply(q_conj)

	// Extract vector part
	return rotated.x, rotated.y, rotated.z
}

fn main() {
	// Rotate 90 degrees around z-axis
	q := quaternion.from_axis_anglef3(math.pi / 2.0, 0.0, 0.0, 1.0)

	// Rotate point (1, 0, 0)
	x, y, z := rotate_point(q, 1.0, 0.0, 0.0)
	println('Rotated point: (${x}, ${y}, ${z})') // Should be (0, 1, 0)
}
```

### Rotating Multiple Points

```v
import vsl.quaternion
import math

fn main() {
	// Create rotation: 45 degrees around y-axis
	q := quaternion.from_axis_anglef3(math.pi / 4.0, 0.0, 1.0, 0.0)
	q_conj := q.conjugate()

	// Points to rotate
	points := [
		[1.0, 0.0, 0.0],
		[0.0, 1.0, 0.0],
		[0.0, 0.0, 1.0],
	]

	println('Original -> Rotated:')
	for p in points {
		p_quat := quaternion.quaternion(0.0, p[0], p[1], p[2])
		rotated := q.multiply(p_quat).multiply(q_conj)
		println('(${p[0]}, ${p[1]}, ${p[2]}) -> (${rotated.x}, ${rotated.y}, ${rotated.z})')
	}
}
```

## Composing Rotations

Quaternion multiplication composes rotations:

```v
import vsl.quaternion
import math

fn main() {
	// First rotation: 90° around x-axis
	q1 := quaternion.from_axis_anglef3(math.pi / 2.0, 1.0, 0.0, 0.0)

	// Second rotation: 90° around y-axis
	q2 := quaternion.from_axis_anglef3(math.pi / 2.0, 0.0, 1.0, 0.0)

	// Combined rotation: q2 * q1 (apply q1 first, then q2)
	q_combined := q2.multiply(q1)

	println('Combined rotation: ${q_combined}')

	// Rotate a point through both rotations
	p := quaternion.quaternion(0.0, 1.0, 0.0, 0.0)
	p_conj := q_combined.conjugate()
	rotated := q_combined.multiply(p).multiply(p_conj)

	println('Final rotated point: (${rotated.x}, ${rotated.y}, ${rotated.z})')
}
```

**Important**: Order matters! `q2 * q1` means "apply q1 first, then q2".

## Rotation Distances

Measure the distance between two rotations:

```v
import vsl.quaternion
import math

fn main() {
	q1 := quaternion.from_axis_anglef3(math.pi / 4.0, 1.0, 0.0, 0.0)
	q2 := quaternion.from_axis_anglef3(math.pi / 2.0, 1.0, 0.0, 0.0)

	// Rotor chordal distance
	chordal := q1.rotor_chordal_distance(q2)
	println('Chordal distance: ${chordal}')

	// Rotor intrinsic distance (geodesic distance)
	intrinsic := q1.rotor_intrinsic_distance(q2)
	println('Intrinsic distance: ${intrinsic}')

	// Rotation chordal distance (accounts for q = -q equivalence)
	rot_chordal := q1.rotation_chordal_distance(q2)
	println('Rotation chordal distance: ${rot_chordal}')
}
```

## Converting to Rotation Matrix

Convert quaternion to 3x3 rotation matrix:

```v
import vsl.quaternion
import math

fn quaternion_to_matrix(q quaternion.Quaternion) [][]f64 {
	w := q.w
	x := q.x
	y := q.y
	z := q.z

	return [
		[1.0 - 2.0 * (y * y + z * z), 2.0 * (x * y - w * z), 2.0 * (x * z + w * y)],
		[2.0 * (x * y + w * z), 1.0 - 2.0 * (x * x + z * z), 2.0 * (y * z - w * x)],
		[2.0 * (x * z - w * y), 2.0 * (y * z + w * x), 1.0 - 2.0 * (x * x + y * y)],
	]
}

fn main() {
	q := quaternion.from_axis_anglef3(math.pi / 2.0, 0.0, 0.0, 1.0)
	matrix := quaternion_to_matrix(q)

	println('Rotation matrix:')
	for row in matrix {
		println(row)
	}
}
```

## Visualizing Rotations

Combine with plotting to visualize rotations:

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
	// Create rotation
	q := quaternion.from_axis_anglef3(math.pi / 4.0, 1.0, 1.0, 0.0).normalized()

	// Original cube vertices
	vertices := [
		[-1.0, -1.0, -1.0],
		[1.0, -1.0, -1.0],
		[1.0, 1.0, -1.0],
		[-1.0, 1.0, -1.0],
		[-1.0, -1.0, 1.0],
		[1.0, -1.0, 1.0],
		[1.0, 1.0, 1.0],
		[-1.0, 1.0, 1.0],
	]

	// Rotate vertices
	mut x_rotated := []f64{}
	mut y_rotated := []f64{}
	mut z_rotated := []f64{}

	for v in vertices {
		x, y, z := rotate_point(q, v[0], v[1], v[2])
		x_rotated << x
		y_rotated << y
		z_rotated << z
	}

	// Plot rotated cube
	mut plt := plot.Plot.new()
	plt.scatter3d(
		x:      x_rotated
		y:      y_rotated
		z:      z_rotated
		mode:   'markers'
		marker: plot.Marker{
			size: []f64{len: x_rotated.len, init: 10.0}
		}
	)
	plt.layout(title: 'Rotated Cube')
	plt.show()!
}
```

## Exercises

1. **Rotate a cube**: Create a unit cube and rotate it around different axes
2. **Compose rotations**: Apply multiple rotations and verify the result
3. **Compare methods**: Compare quaternion rotation with matrix rotation
4. **Visualize**: Plot rotation paths for animated rotations

## Next Steps

- [Interpolation](03-interpolation.md) - Smoothly interpolate between rotations
- [Visualization](04-visualization.md) - Advanced visualization techniques
- [Examples](../../examples/quaternion_rotation_3d/) - Working examples

## Related Examples

- `examples/quaternion_rotation_3d` - 3D rotation visualization
- `examples/quaternion_rotation_composition` - Composing rotations
- `examples/quaternion_orientation_tracking` - Tracking orientations
