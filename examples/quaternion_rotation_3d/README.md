# Quaternion 3D Rotation Visualization

This example demonstrates how to use quaternions to rotate 3D objects and
visualize the results using VSL's plotting module.

## What You'll Learn

- Creating quaternions from axis-angle representation
- Rotating 3D points using quaternion multiplication
- Visualizing rotations in 3D space
- Understanding quaternion rotation formula: **p' = q p q⁻¹**

## Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- No additional system dependencies required

## Running the Example

```sh
# Navigate to this directory
cd examples/quaternion_rotation_3d

# Run the example
v run main.v
```

## Expected Output

The example generates an interactive 3D plot showing:

- **Original Cube** (gray): Unit cube before rotation
- **Rotated Cube** (red): Same cube after 45° rotation around axis (1, 1, 1)
- **Cube Edges**: Wireframe visualization for better understanding
- **Console Output**: Original and rotated vertex coordinates

## Code Walkthrough

### 1. Rotation Function

```v
import vsl.quaternion

fn rotate_point(q quaternion.Quaternion, px f64, py f64, pz f64) (f64, f64, f64) {
	p := quaternion.quaternion(0.0, px, py, pz) // Pure quaternion
	q_conj := q.conjugate() // Inverse for unit quaternion
	rotated := q.multiply(p).multiply(q_conj) // p' = q * p * q⁻¹
	return rotated.x, rotated.y, rotated.z
}
```

This implements the standard quaternion rotation formula. The point is treated
as a pure quaternion (scalar part = 0).

### 2. Creating the Rotation

```v
import vsl.quaternion
import math

axis := [1.0, 1.0, 1.0]
axis_norm := math.sqrt(axis[0] * axis[0] + axis[1] * axis[1] + axis[2] * axis[2])
axis_normalized := [axis[0] / axis_norm, axis[1] / axis_norm, axis[2] / axis_norm]

angle := math.pi / 4.0 // 45 degrees
q := quaternion.from_axis_anglef3(angle, axis_normalized[0], axis_normalized[1], axis_normalized[2])
```

We normalize the rotation axis and create a quaternion representing a 45°
rotation around that axis.

### 3. Rotating Vertices

```v ignore
import vsl.quaternion
import math

fn rotate_point(q quaternion.Quaternion, px f64, py f64, pz f64) (f64, f64, f64) {
    p := quaternion.quaternion(0.0, px, py, pz)
    q_conj := q.conjugate()
    rotated := q.multiply(p).multiply(q_conj)
    return rotated.x, rotated.y, rotated.z
}

vertices := [
    [-1.0, -1.0, -1.0], [1.0, -1.0, -1.0], [1.0, 1.0, -1.0], [-1.0, 1.0, -1.0],
    [-1.0, -1.0, 1.0], [1.0, -1.0, 1.0], [1.0, 1.0, 1.0], [-1.0, 1.0, 1.0],
]
q := quaternion.from_axis_anglef3(math.pi / 4.0, 1.0, 1.0, 0.0).normalized()

mut x_rotated := []f64{}
mut y_rotated := []f64{}
mut z_rotated := []f64{}

for v in vertices {
    x, y, z := rotate_point(q, v[0], v[1], v[2])
    x_rotated << x
    y_rotated << y
    z_rotated << z
}
```

Each vertex of the cube is rotated using the quaternion.

### 4. Visualization

The plot shows both original and rotated cubes with different colors and
marker styles, making it easy to see the rotation effect.

## Mathematical Background

### Quaternion Rotation Formula

To rotate a 3D point **p** using quaternion **q**:

**p' = q p q⁻¹**

Where:
- `p` is a pure quaternion: (0, px, py, pz)
- `q` is a unit quaternion: (w, x, y, z) where ||q|| = 1
- `q⁻¹ = q*` (conjugate) for unit quaternions

### Axis-Angle to Quaternion

A rotation of angle θ around axis **n** (normalized) is:

**q = cos(θ/2) + sin(θ/2)(nxi + nyj + nzk)**

## Experiment Ideas

Try modifying the example to:

- **Change rotation angle**: Try 90°, 180°, or other angles
- **Change rotation axis**: Rotate around x-axis (1, 0, 0), y-axis (0, 1, 0), or z-axis (0, 0, 1)
- **Rotate different shapes**: Try a sphere, pyramid, or custom shape
- **Multiple rotations**: Compose multiple rotations
- **Animate rotation**: Create a series of rotations for animation

## Related Examples

- `quaternion_interpolation_animation` - Animated quaternion interpolation
- `quaternion_rotation_composition` - Composing multiple rotations
- `quaternion_orientation_tracking` - Tracking orientations over time
- `plot_scatter3d_1` - Basic 3D scatter plotting

## Related Tutorials

- [Quaternion Introduction](../../docs/quaternions/01-introduction.md)
- [Quaternion Rotations](../../docs/quaternions/02-rotations.md)
- [3D Visualization](../../docs/visualization/02-3d-visualization.md)

## Troubleshooting

**Plot doesn't open**: Ensure you have a web browser installed and set as default

**Rotation looks wrong**: Verify the quaternion is normalized (magnitude ≈ 1.0)

**Module errors**: Verify VSL installation with `v list` command

**Build failures**: Check V compiler version compatibility

---

Happy rotating! Explore more quaternion examples in the [examples directory](../).
