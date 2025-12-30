# FFT Quaternion Signal Processing

This example demonstrates processing quaternion-valued signals and visualizing
them, combining quaternion and plotting modules.

## What You'll Learn

- Generating quaternion signals
- Processing quaternion data over time
- Visualizing quaternion signals in multiple ways
- Understanding quaternion signal representation

## Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- No additional system dependencies required

## Running the Example

```sh
# Navigate to this directory
cd examples/fft_quaternion_signal

# Run the example
v run main.v
```

## Expected Output

The example generates three interactive plots:

1. **Time Domain Plot**: Quaternion components (w, x, y, z) over time
2. **Magnitude Plot**: Signal magnitude |q| over time
3. **3D Path Plot**: 3D visualization of quaternion vector components

## Code Walkthrough

### 1. Generating Quaternion Signal

```v ignore
import vsl.quaternion
import math

n_samples := 100
mut quaternion_signal := []quaternion.Quaternion{}

// Create time-varying rotations
for i in 0..n_samples {
    t := f64(i) / f64(n_samples)
    angle_x := 2.0 * math.pi * 2.0 * t  // 2 Hz rotation
    q_x := quaternion.from_axis_anglef3(angle_x, 1.0, 0.0, 0.0)
    
    angle_y := 2.0 * math.pi * 5.0 * t * 0.1  // 0.5 Hz rotation
    q_y := quaternion.from_axis_anglef3(angle_y, 0.0, 1.0, 0.0)
    
    q_total := q_y.multiply(q_x)  // Compose rotations
    quaternion_signal << q_total
}
```

We generate a quaternion signal representing time-varying orientations.

### 2. Signal Processing

```v ignore
import vsl.quaternion

quaternion_signal := []quaternion.Quaternion{}  // Assume populated

// Extract magnitude
mut magnitudes := []f64{}
for q in quaternion_signal {
    magnitudes << q.abs()
}

// Extract components
mut w_vals := []f64{}
mut x_vals := []f64{}
mut y_vals := []f64{}
mut z_vals := []f64{}
for q in quaternion_signal {
    w_vals << q.w
    x_vals << q.x
    y_vals << q.y
    z_vals << q.z
}
```

We process the quaternion signal to extract useful information.

### 3. Visualization

Multiple plots show different aspects of the quaternion signal.

## Use Cases

- **Motion Analysis**: Analyze object rotation over time
- **Sensor Data**: Process IMU/orientation sensor signals
- **Animation**: Analyze animation sequences
- **Control Systems**: Monitor system orientation

## FFT Integration

For actual FFT processing:

```v ignore
import vsl.fft

w_vals := []f64{}  // Assume populated
x_vals := []f64{}  // Assume populated
y_vals := []f64{}  // Assume populated
z_vals := []f64{}  // Assume populated

// Apply FFT to each component separately
// Note: Check vsl.fft module API for actual FFT function names
// w_fft := fft.fft(w_vals)
// x_fft := fft.fft(x_vals)
// y_fft := fft.fft(y_vals)
// z_fft := fft.fft(z_vals)
```

## Experiment Ideas

Try modifying the example to:

- **Add FFT**: Use vsl.fft to analyze frequency components
- **Different signals**: Generate different rotation patterns
- **Noise**: Add noise to simulate sensor data
- **Filtering**: Apply filters to quaternion signals
- **Real data**: Import actual sensor data

## Related Examples

- `fft_plot_example` - FFT signal processing
- `quaternion_orientation_tracking` - Orientation tracking
- `quaternion_interpolation_animation` - Quaternion interpolation

## Related Tutorials

- [FFT Signal Processing](../../docs/scientific-computing/01-fft-signal-processing.md)
- [Quaternion Introduction](../../docs/quaternions/01-introduction.md)
- [3D Visualization](../../docs/visualization/02-3d-visualization.md)

## Troubleshooting

**Plot doesn't open**: Ensure web browser is installed

**Signal looks wrong**: Verify quaternion generation logic

**Performance issues**: Reduce n_samples for faster rendering

---

Explore more signal processing and quaternion examples in the [examples directory](../).

