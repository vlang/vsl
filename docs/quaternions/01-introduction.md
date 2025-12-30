# Quaternion Introduction

Learn the fundamentals of quaternions and how to use them in VSL for 3D rotations and orientations.

## What You'll Learn

- What quaternions are and why they're useful
- Creating quaternions in VSL
- Basic quaternion operations
- Converting between representations

## Prerequisites

- VSL installed
- Basic understanding of 3D rotations
- Familiarity with complex numbers (helpful but not required)

## Theory

Quaternions are a number system that extends complex numbers to four dimensions.
They're represented as:

**q = w + xi + yj + zk**

Where:
- `w` is the scalar (real) part
- `x, y, z` are the vector (imaginary) parts
- `i, j, k` are fundamental quaternion units with special multiplication rules

### Why Quaternions?

Quaternions excel at representing 3D rotations because they:
- Avoid gimbal lock (unlike Euler angles)
- Are more efficient than rotation matrices
- Provide smooth interpolation
- Are compact (4 numbers vs 9 for matrices)

## Creating Quaternions

### Identity Quaternion

The identity quaternion represents no rotation:

```v
import vsl.quaternion

fn main() {
	q := quaternion.id() // (1, 0, 0, 0)
	println(q) // 1.0+0.0i+0.0j+0.0k
}
```

### From Components

Create a quaternion directly:

```v
import vsl.quaternion

fn main() {
	// q = 1 + 2i + 3j + 4k
	q := quaternion.quaternion(1.0, 2.0, 3.0, 4.0)
	println(q)
}
```

### From Axis-Angle

Most common way to create rotation quaternions:

```v
import vsl.quaternion
import math

fn main() {
	// Rotate 90 degrees around x-axis
	angle := math.pi / 2.0
	q := quaternion.from_axis_anglef3(angle, 1.0, 0.0, 0.0)
	println(q)
}
```

The formula is: **q = cos(θ/2) + sin(θ/2)(xi + yj + zk)**

### From Euler Angles

Convert Euler angles (roll, pitch, yaw) to quaternion:

```v
import vsl.quaternion
import math

fn main() {
	// Roll: 30°, Pitch: 45°, Yaw: 60°
	alpha := math.pi / 6.0 // roll
	beta := math.pi / 4.0 // pitch
	gamma := math.pi / 3.0 // yaw

	q := quaternion.from_euler_angles(alpha, beta, gamma)
	println(q)
}
```

### From Spherical Coordinates

```v
import vsl.quaternion
import math

fn main() {
	theta := math.pi / 4.0 // polar angle
	phi := math.pi / 3.0 // azimuthal angle

	q := quaternion.from_spherical_coords(theta, phi)
	println(q)
}
```

## Basic Operations

### Arithmetic

```v
import vsl.quaternion

fn main() {
	q1 := quaternion.quaternion(1.0, 2.0, 3.0, 4.0)
	q2 := quaternion.quaternion(5.0, 6.0, 7.0, 8.0)

	// Addition
	sum := q1 + q2
	println('Sum: ${sum}')

	// Subtraction
	diff := q1 - q2
	println('Difference: ${diff}')

	// Multiplication (non-commutative!)
	product := q1 * q2
	println('Product: ${product}')

	// Division
	quotient := q1 / q2
	println('Quotient: ${quotient}')
}
```

### Important Properties

```v
import vsl.quaternion

fn main() {
	q := quaternion.quaternion(1.0, 2.0, 3.0, 4.0)

	// Conjugate: q* = w - xi - yj - zk
	conj := q.conjugate()
	println('Conjugate: ${conj}')

	// Norm squared: ||q||² = w² + x² + y² + z²
	norm_sq := q.norm()
	println('Norm squared: ${norm_sq}')

	// Magnitude: ||q|| = √(w² + x² + y² + z²)
	magnitude := q.abs()
	println('Magnitude: ${magnitude}')

	// Normalized (unit quaternion)
	unit := q.normalized()
	println('Normalized: ${unit}')
	println('Normalized magnitude: ${unit.abs()}') // Should be ~1.0
}
```

### Scalar Operations

```v
import vsl.quaternion

fn main() {
	q := quaternion.quaternion(1.0, 2.0, 3.0, 4.0)
	s := 2.0

	// Scalar multiplication
	scaled := q.scalar_multiply(s)
	println('Scaled: ${scaled}')

	// Scalar addition
	added := q.scalar_add(s)
	println('Added: ${added}')
}
```

## Exercises

1. **Create rotations**: Make quaternions for 90° rotations around x, y, and z axes
2. **Verify properties**: Check that normalized quaternions have magnitude 1.0
3. **Test non-commutativity**: Show that q1 * q2 ≠ q2 * q1
4. **Convert representations**: Convert between axis-angle and Euler angles

## Next Steps

- [Rotations](02-rotations.md) - Apply quaternions to rotate 3D points
- [Interpolation](03-interpolation.md) - Smoothly interpolate between rotations
- [Visualization](04-visualization.md) - Visualize quaternion rotations

## Related Examples

- `examples/quaternion_rotation_3d` - 3D rotation visualization
- `examples/quaternion_orientation_tracking` - Orientation tracking
- `examples/quaternion_rotation_composition` - Composing rotations
