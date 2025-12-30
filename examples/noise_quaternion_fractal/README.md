# Noise Quaternion Fractal

This example combines quaternions and noise functions to create textured fractal patterns.

## What You'll Learn

- Combining quaternion fractals with noise
- Adding texture to fractal patterns
- Using noise functions for variation
- Visualizing complex patterns

## Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- No additional system dependencies required

## Running the Example

```sh
# Navigate to this directory
cd examples/noise_quaternion_fractal

# Run the example
v run main.v
```

## Expected Output

The example generates an interactive 3D plot showing:

- **Fractal pattern**: Quaternion Julia set with noise texture
- **Color mapping**: Points colored by iteration count
- **Noise variation**: Texture added through noise functions

## Code Walkthrough

### 1. Fractal Generation

```v
import vsl.quaternion

fn generate_fractal_point(c quaternion.Quaternion, z quaternion.Quaternion, max_iter int) int {
	mut current := z.copy()
	for i in 0 .. max_iter {
		current = current.multiply(current).add(c) // z = z² + c
		if current.abs() > 2.0 {
			return i
		}
	}
	return max_iter
}
```

Standard quaternion Julia set iteration.

### 2. Adding Noise

```v
import vsl.quaternion
import vsl.noise
import rand

rand.seed([u32(42), u32(42)])
mut noise_gen := noise.Generator.new()
noise_gen.randomize()

c_base := quaternion.quaternion(-0.123, 0.745, 0.0, 0.0)
x_val, y_val := 0.5, 0.5

// Add noise to constant
noise_x := noise_gen.simplex_2d(x_val, y_val) * 0.1
noise_y := noise_gen.simplex_2d(x_val * 2.0, y_val * 2.0) * 0.1
c_noisy := quaternion.quaternion(c_base.w + noise_x * 0.1, c_base.x + noise_x, c_base.y + noise_y,
	c_base.z + noise_x * 0.05)
```

Noise is added to the Julia set constant to create texture variation.

### 3. Visualization

Points are colored based on iteration count, creating the fractal pattern.

## Use Cases

- **Procedural Generation**: Generate textured patterns
- **Artistic Visualization**: Create abstract art
- **Pattern Analysis**: Study fractal properties with noise
- **Texture Synthesis**: Generate textures for graphics

## Experiment Ideas

Try modifying the example to:

- **Adjust noise amount**: Change noise scaling factors
- **Different noise types**: Try different noise functions
- **Higher resolution**: Increase resolution for more detail
- **Animate**: Create animation by varying noise over time
- **Combine with other modules**: Add more effects

## Related Examples

- `quaternion_julia_fractal` - Basic quaternion Julia set
- `noise_fractal_2d` - 2D fractal with noise
- `noise_simplex_2d` - Simplex noise examples

## Related Tutorials

- [Quaternion Introduction](../../docs/quaternions/01-introduction.md)
- [3D Visualization](../../docs/visualization/02-3d-visualization.md)

## Troubleshooting

**Slow generation**: Reduce resolution or max_iter

**Plot doesn't open**: Ensure web browser is installed

**Pattern looks wrong**: Adjust noise scaling factors

---

Explore more fractal and noise examples in the [examples directory](../).
