# Quaternion Orientation Tracking

This example demonstrates how to track object orientation over time using
quaternions and visualize the results.

## What You'll Learn

- Tracking object orientation with quaternions
- Composing multiple rotations over time
- Visualizing orientation changes
- Plotting quaternion components

## Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- No additional system dependencies required

## Running the Example

```sh
# Navigate to this directory
cd examples/quaternion_orientation_tracking

# Run the example
v run main.v
```

## Expected Output

The example generates two interactive plots:

1. **3D Trajectory Plot**: Shows the path of a tracked point as the object rotates
2. **Component Plot**: Shows how quaternion components (w, x, y, z) change over time

## Code Walkthrough

### 1. Generating Orientation Sequence

```v ignore
import vsl.quaternion
import math

time_steps := 100
mut orientations := []quaternion.Quaternion{}

for t in 0..time_steps {
    time_val := f64(t) / f64(time_steps - 1)
    
    // Create time-varying rotations
    angle_x := 2.0 * math.pi * time_val
    q_x := quaternion.from_axis_anglef3(angle_x, 1.0, 0.0, 0.0)
    
    angle_y := math.pi * time_val
    q_y := quaternion.from_axis_anglef3(angle_y, 0.0, 1.0, 0.0)
    
    // Compose rotations
    q_total := q_y.multiply(q_x)
    orientations << q_total
}
```

We create a sequence of rotations by composing rotations around different axes
with different frequencies.

### 2. Tracking a Point

```v ignore
import vsl.quaternion

fn rotate_point(q quaternion.Quaternion, px f64, py f64, pz f64) (f64, f64, f64) {
    p := quaternion.quaternion(0.0, px, py, pz)
    q_conj := q.conjugate()
    rotated := q.multiply(p).multiply(q_conj)
    return rotated.x, rotated.y, rotated.z
}

point_x, point_y, point_z := 0.0, 0.0, 1.0  // Unit vector pointing forward
orientations := []quaternion.Quaternion{}  // Assume populated

mut x_tracked := []f64{}
mut y_tracked := []f64{}
mut z_tracked := []f64{}

for q in orientations {
    x, y, z := rotate_point(q, point_x, point_y, point_z)
    x_tracked << x
    y_tracked << y
    z_tracked << z
}
```

We track how a fixed point on the object moves through space as the object rotates.

### 3. Visualizing Components

The quaternion components are extracted and plotted over time to show how the
orientation representation changes.

## Use Cases

- **Robotics**: Track robot arm orientation
- **Animation**: Animate object rotations
- **Physics Simulation**: Track rotating objects
- **Sensor Data**: Visualize IMU/orientation sensor data

## Experiment Ideas

Try modifying the example to:

- **Change rotation frequencies**: Different frequencies create different patterns
- **Add more rotations**: Compose rotations around z-axis or arbitrary axes
- **Track multiple points**: Track several points on the object
- **Use real data**: Import orientation data from sensors
- **Add noise**: Simulate sensor noise and filtering

## Related Examples

- `quaternion_rotation_3d` - Basic quaternion rotation
- `quaternion_interpolation_animation` - Smooth interpolation
- `quaternion_rotation_composition` - Composing rotations

## Related Tutorials

- [Quaternion Rotations](../../docs/quaternions/02-rotations.md)
- [Quaternion Interpolation](../../docs/quaternions/03-interpolation.md)
- [3D Visualization](../../docs/visualization/02-3d-visualization.md)

## Troubleshooting

**Plots don't open**: Ensure web browser is installed

**Trajectory looks wrong**: Verify rotation composition order

**Performance issues**: Reduce time_steps for faster rendering

---

Explore more quaternion examples in the [examples directory](../).

