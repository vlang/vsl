# Quaternion Rotation Composition

This example demonstrates how to compose multiple quaternion rotations and
visualize the intermediate steps.

## What You'll Learn

- Composing multiple quaternion rotations
- Understanding rotation order (q2 * q1 means apply q1 first)
- Visualizing rotation composition paths
- Comparing individual vs composed rotations

## Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- No additional system dependencies required

## Running the Example

```sh
# Navigate to this directory
cd examples/quaternion_rotation_composition

# Run the example
v run main.v
```

## Expected Output

The example generates:

- **Console output**: Shows original point, individual rotations, and composed rotations
- **3D Plot**: Visualizes the rotation path with key points marked
- **Color-coded points**: Green (start) → Yellow → Orange → Red (final)

## Code Walkthrough

### 1. Creating Multiple Rotations

```v
import vsl.quaternion
import math

q1 := quaternion.from_axis_anglef3(math.pi / 2.0, 1.0, 0.0, 0.0) // 90° around x
q2 := quaternion.from_axis_anglef3(math.pi / 2.0, 0.0, 1.0, 0.0) // 90° around y
q3 := quaternion.from_axis_anglef3(math.pi / 2.0, 0.0, 0.0, 1.0) // 90° around z
```

We create three rotations around different axes.

### 2. Composing Rotations

```v
import vsl.quaternion
import math

q1 := quaternion.from_axis_anglef3(math.pi / 2.0, 1.0, 0.0, 0.0)
q2 := quaternion.from_axis_anglef3(math.pi / 2.0, 0.0, 1.0, 0.0)
q3 := quaternion.from_axis_anglef3(math.pi / 2.0, 0.0, 0.0, 1.0)

q_composed_12 := q2.multiply(q1) // q2 * q1 (apply q1 first, then q2)
q_composed_all := q3.multiply(q2).multiply(q1) // q3 * q2 * q1
```

**Important**: Order matters! `q2 * q1` means "apply q1 first, then q2".

### 3. Visualizing the Path

We use SLERP to create smooth paths between rotation states, showing how the
point moves through space.

## Mathematical Background

### Rotation Composition

When composing rotations:
- **q2 * q1**: Apply q1 first, then q2
- Order matters because quaternion multiplication is non-commutative
- The composed quaternion represents the combined rotation

### Why Order Matters

Rotating around x-axis then y-axis gives a different result than rotating
around y-axis then x-axis. This is why quaternion multiplication order is
important.

## Experiment Ideas

Try modifying the example to:

- **Change rotation order**: Try q1 * q2 instead of q2 * q1
- **Different angles**: Use 45°, 180°, or other angles
- **Different axes**: Rotate around arbitrary axes
- **More rotations**: Add a fourth or fifth rotation
- **Compare with matrices**: Convert to rotation matrices and compare

## Related Examples

- `quaternion_rotation_3d` - Basic quaternion rotation
- `quaternion_interpolation_animation` - Smooth interpolation
- `quaternion_orientation_tracking` - Tracking over time

## Related Tutorials

- [Quaternion Rotations](../../docs/quaternions/02-rotations.md)
- [Quaternion Interpolation](../../docs/quaternions/03-interpolation.md)
- [3D Visualization](../../docs/visualization/02-3d-visualization.md)

## Troubleshooting

**Rotation looks wrong**: Check rotation order - remember q2 * q1 applies q1 first

**Plot doesn't open**: Ensure web browser is installed

**Unexpected results**: Verify quaternions are normalized

---

Explore more quaternion examples in the [examples directory](../).
