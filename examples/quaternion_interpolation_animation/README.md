# Quaternion Interpolation Animation

This example demonstrates different quaternion interpolation methods (SLERP,
NLERP, LERP) and visualizes their differences in 3D space.

## What You'll Learn

- Understanding SLERP (Spherical Linear Interpolation)
- Comparing SLERP, NLERP, and LERP methods
- Visualizing interpolation paths in 3D
- When to use each interpolation method

## Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- No additional system dependencies required

## Running the Example

```sh
# Navigate to this directory
cd examples/quaternion_interpolation_animation

# Run the example
v run main.v
```

## Expected Output

The example generates an interactive 3D plot showing:

- **SLERP path** (blue, solid): Smooth spherical interpolation - follows shortest path
- **NLERP path** (green, dashed): Normalized linear interpolation
- **LERP path** (red, dotted): Simple linear interpolation
- **Start/End points**: Marked in green and red respectively
- **Console output**: Sample interpolation values at different t parameters

## Code Walkthrough

### 1. Interpolation Setup

```v
import vsl.quaternion
import math

q_start := quaternion.from_axis_anglef3(0.0, 1.0, 0.0, 0.0) // Start rotation
q_end := quaternion.from_axis_anglef3(math.pi, 1.0, 0.0, 0.0) // End rotation
```

We define start and end rotations around the x-axis.

### 2. SLERP Interpolation

```v
import vsl.quaternion
import math

steps := 50
px, py, pz := 1.0, 0.0, 0.0
q_start := quaternion.from_axis_anglef3(0.0, 1.0, 0.0, 0.0)
q_end := quaternion.from_axis_anglef3(math.pi, 1.0, 0.0, 0.0)

for i in 0 .. steps {
	t := f64(i) / f64(steps - 1)
	q_interp := q_start.slerp(q_end, t) // Spherical interpolation
	// ... store path points
}
```

SLERP provides the smoothest interpolation, following the geodesic (shortest path) on the 4D sphere.

### 3. Comparison Methods

The example also generates NLERP and LERP paths for comparison, showing how
each method affects the rotation path.

## Mathematical Background

### SLERP (Spherical Linear Interpolation)

SLERP interpolates along the shortest path on the 4D unit sphere:

**q(t) = (sin((1-t)θ)/sin(θ))q₁ + (sin(tθ)/sin(θ))q₂**

Where θ is the angle between q₁ and q₂.

### NLERP (Normalized Linear Interpolation)

NLERP is LERP followed by normalization:

**q(t) = normalize((1-t)q₁ + tq₂)**

### LERP (Linear Interpolation)

Simple linear interpolation:

**q(t) = (1-t)q₁ + tq₂**

## Interpolation Comparison

| Method | Speed | Smoothness | Accuracy | Use Case |
|--------|-------|------------|----------|----------|
| LERP | Fastest | Low | Low | Quick approximations |
| NLERP | Fast | Medium | Medium | Real-time with unit quaternions |
| SLERP | Slower | Highest | Highest | Smooth animations, accurate rotations |

## Experiment Ideas

Try modifying the example to:

- **Change rotation angles**: Try different start/end rotations
- **Change rotation axes**: Rotate around different axes
- **Adjust interpolation steps**: More steps = smoother path
- **Compare speeds**: Measure performance difference between methods
- **Animate**: Create frame-by-frame animation

## Related Examples

- `quaternion_rotation_3d` - Basic quaternion rotation
- `quaternion_orientation_tracking` - Orientation tracking over time
- `quaternion_rotation_composition` - Composing rotations

## Related Tutorials

- [Quaternion Interpolation](../../docs/quaternions/03-interpolation.md)
- [Quaternion Rotations](../../docs/quaternions/02-rotations.md)
- [3D Visualization](../../docs/visualization/02-3d-visualization.md)

## Troubleshooting

**Plot doesn't open**: Ensure you have a web browser installed

**Interpolation looks wrong**: Verify quaternions are normalized

**Performance issues**: Reduce number of steps for faster rendering

---

Explore more quaternion examples in the [examples directory](../).
