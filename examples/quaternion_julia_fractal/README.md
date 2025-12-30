# Quaternion Julia Set Fractal

This example generates and visualizes a quaternion Julia set fractal,
demonstrating the combination of quaternion mathematics with visualization.

## What You'll Learn

- Understanding quaternion Julia sets
- Iterating quaternion functions
- Visualizing 4D fractals in 3D space
- Color mapping based on iteration counts

## Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- Basic understanding of fractals (helpful but not required)

## Running the Example

```sh
# Navigate to this directory
cd examples/quaternion_julia_fractal

# Run the example
v run main.v
```

## Expected Output

The example generates an interactive 3D plot showing:

- **Fractal pattern**: Quaternion Julia set visualized as colored points
- **Color mapping**: Points colored by iteration count (darker = more iterations)
- **2D slice**: Shows a 2D slice through 4D quaternion space
- **Console output**: Progress and fractal parameters

## Code Walkthrough

### 1. Julia Set Iteration

```v ignore
import vsl.quaternion

fn julia_iterate(c quaternion.Quaternion, z quaternion.Quaternion, max_iter int) int {
    mut current := z.copy()
    for i in 0..max_iter {
        current = current.multiply(current).add(c)  // z = z² + c
        if current.abs() > 2.0 {
            return i  // Escaped
        }
    }
    return max_iter  // Didn't escape
}
```

This implements the Julia set iteration: **z = z² + c**. Points that escape
(magnitude > 2) are colored by iteration count.

### 2. Grid Generation

```v ignore
import vsl.quaternion

fn julia_iterate(c quaternion.Quaternion, z quaternion.Quaternion, max_iter int) int {
    mut current := z.copy()
    for i in 0..max_iter {
        current = current.multiply(current).add(c)
        if current.abs() > 2.0 {
            return i
        }
    }
    return max_iter
}

resolution := 30
range_val := 2.0
w_fixed := 0.0
z_fixed := 0.0
c := quaternion.quaternion(-0.123, 0.745, 0.0, 0.0)
max_iter := 50

// Sample 2D slice: fix w=0, z=0, vary x and y
for i in 0..resolution {
    for j in 0..resolution {
        x_val := -range_val + (2.0 * range_val * f64(i) / f64(resolution - 1))
        y_val := -range_val + (2.0 * range_val * f64(j) / f64(resolution - 1))
        z_init := quaternion.quaternion(w_fixed, x_val, y_val, z_fixed)
        iterations := julia_iterate(c, z_init, max_iter)
        // ... store results
    }
}
```

We sample a 2D slice through 4D quaternion space by fixing two components and varying the others.

### 3. Color Mapping

Points are colored based on how many iterations it took to escape, creating the fractal pattern.

## Mathematical Background

### Julia Sets

A Julia set is the set of points that don't escape to infinity under iteration
of a complex function. For quaternions, we use:

**zₙ₊₁ = zₙ² + c**

Where:
- `z` is a quaternion
- `c` is a constant quaternion
- Points that escape (|z| > 2) are colored by iteration count

### 4D Visualization

Quaternions are 4D, but we visualize them by:
- Taking 2D slices (fixing 2 components)
- Using color to represent additional information
- Creating multiple slices for full visualization

## Experiment Ideas

Try modifying the example to:

- **Change constant c**: Different values create different fractal patterns
- **Increase resolution**: Higher resolution = more detail (slower)
- **Change slice plane**: Fix different components (w, x, y, z)
- **Modify iteration function**: Try z³ + c or other functions
- **Create animation**: Generate multiple slices for animation

## Performance Notes

- Higher resolution increases computation time quadratically
- Max iterations affects both detail and computation time
- For interactive exploration, start with resolution=20-30

## Related Examples

- `quaternion_rotation_3d` - Basic quaternion operations
- `noise_fractal_2d` - Other fractal examples
- `plot_scatter3d_1` - 3D plotting basics

## Related Tutorials

- [Quaternion Introduction](../../docs/quaternions/01-introduction.md)
- [3D Visualization](../../docs/visualization/02-3d-visualization.md)

## Troubleshooting

**Slow generation**: Reduce resolution or max_iter

**Plot doesn't open**: Ensure web browser is installed

**No fractal pattern**: Try different constant c values

---

Explore more fractal and quaternion examples in the [examples directory](../).

