# Quaternion Visualization

Learn how to visualize quaternion rotations and create compelling 3D visualizations.

## What You'll Learn

- Visualizing quaternion rotations in 3D
- Creating rotation animations
- Plotting quaternion paths
- Combining quaternions with other VSL modules

## Prerequisites

- [Quaternion Introduction](01-introduction.md)
- [Quaternion Rotations](02-rotations.md)
- [Quaternion Interpolation](03-interpolation.md)
- [2D Plotting Tutorial](../visualization/01-2d-plotting.md)
- [3D Visualization Tutorial](../visualization/02-3d-visualization.md)

## Theory

Visualizing quaternions helps understand:
- Rotation paths in 3D space
- Interpolation smoothness
- Rotation composition
- Orientation changes over time

We'll use VSL's plotting module to create interactive 3D visualizations.

## Visualizing a Single Rotation

### Rotating a Cube

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
	// Create rotation: 45 degrees around (1, 1, 1) axis
	axis := [1.0, 1.0, 1.0]
	axis_norm := math.sqrt(axis[0] * axis[0] + axis[1] * axis[1] + axis[2] * axis[2])
	axis_normalized := [axis[0] / axis_norm, axis[1] / axis_norm, axis[2] / axis_norm]

	q := quaternion.from_axis_anglef3(math.pi / 4.0, axis_normalized[0], axis_normalized[1],
		axis_normalized[2])

	// Unit cube vertices
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

	// Plot original and rotated cubes
	mut plt := plot.Plot.new()

	// Original cube (gray)
	x_orig := vertices.map(it[0])
	y_orig := vertices.map(it[1])
	z_orig := vertices.map(it[2])

	plt.scatter3d(
		x:      x_orig
		y:      y_orig
		z:      z_orig
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: x_orig.len, init: 8.0}
			color: []string{len: x_orig.len, init: '#888888'}
		}
		name:   'Original'
	)

	// Rotated cube (red)
	plt.scatter3d(
		x:      x_rotated
		y:      y_rotated
		z:      z_rotated
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: x_rotated.len, init: 10.0}
			color: []string{len: x_rotated.len, init: '#FF0000'}
		}
		name:   'Rotated'
	)

	plt.layout(title: 'Quaternion Rotation Visualization')
	plt.show()!
}
```

## Visualizing Rotation Paths

Show the path a point takes during rotation:

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
	q_start := quaternion.from_axis_anglef3(0.0, 0.0, 0.0, 1.0)
	q_end := quaternion.from_axis_anglef3(math.pi, 0.0, 0.0, 1.0)

	// Point to rotate
	px, py, pz := 1.0, 0.0, 0.0

	// Generate rotation path using SLERP
	steps := 50
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

	// Plot path
	mut plt := plot.Plot.new()
	plt.scatter3d(
		x:      x_path
		y:      y_path
		z:      z_path
		mode:   'lines+markers'
		marker: plot.Marker{
			size:  []f64{len: x_path.len, init: 5.0}
			color: []string{len: x_path.len, init: '#0066FF'}
		}
		line:   plot.Line{
			color: '#0066FF'
			width: 2.0
		}
		name:   'Rotation Path'
	)

	// Mark start and end points
	plt.scatter3d(
		x:      [px]
		y:      [py]
		z:      [pz]
		mode:   'markers'
		marker: plot.Marker{
			size:  [15.0]
			color: ['#00FF00']
		}
		name:   'Start'
	)

	x_end, y_end, z_end := rotate_point(q_end, px, py, pz)
	plt.scatter3d(
		x:      [x_end]
		y:      [y_end]
		z:      [z_end]
		mode:   'markers'
		marker: plot.Marker{
			size:  [15.0]
			color: ['#FF0000']
		}
		name:   'End'
	)

	plt.layout(title: 'Quaternion Rotation Path')
	plt.show()!
}
```

## Comparing Interpolation Methods

Visualize the difference between interpolation methods:

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
	q_start := quaternion.from_axis_anglef3(0.0, 1.0, 0.0, 0.0)
	q_end := quaternion.from_axis_anglef3(math.pi / 2.0, 0.0, 1.0, 0.0)
	px, py, pz := 1.0, 0.0, 0.0

	steps := 30
	mut plt := plot.Plot.new()

	// LERP path
	mut x_lerp := []f64{}
	mut y_lerp := []f64{}
	mut z_lerp := []f64{}

	for i in 0 .. steps {
		t := f64(i) / f64(steps - 1)
		q_interp := q_start.lerp(q_end, t).normalized()
		x, y, z := rotate_point(q_interp, px, py, pz)
		x_lerp << x
		y_lerp << y
		z_lerp << z
	}

	plt.scatter3d(
		x:    x_lerp
		y:    y_lerp
		z:    z_lerp
		mode: 'lines'
		name: 'LERP'
		line: plot.Line{
			color: '#FF0000'
		}
	)

	// SLERP path
	mut x_slerp := []f64{}
	mut y_slerp := []f64{}
	mut z_slerp := []f64{}

	for i in 0 .. steps {
		t := f64(i) / f64(steps - 1)
		q_interp := q_start.slerp(q_end, t)
		x, y, z := rotate_point(q_interp, px, py, pz)
		x_slerp << x
		y_slerp << y
		z_slerp << z
	}

	plt.scatter3d(
		x:    x_slerp
		y:    y_slerp
		z:    z_slerp
		mode: 'lines'
		name: 'SLERP'
		line: plot.Line{
			color: '#0000FF'
		}
	)

	plt.layout(title: 'LERP vs SLERP Comparison')
	plt.show()!
}
```

## Visualizing Quaternion Components

Plot quaternion components over time:

```v
import vsl.quaternion
import vsl.plot
import math

fn main() {
	// Animate rotation
	steps := 100
	mut w_vals := []f64{}
	mut x_vals := []f64{}
	mut y_vals := []f64{}
	mut z_vals := []f64{}
	mut t_vals := []f64{}

	q_start := quaternion.from_axis_anglef3(0.0, 1.0, 0.0, 0.0)
	q_end := quaternion.from_axis_anglef3(math.pi, 1.0, 0.0, 0.0)

	for i in 0 .. steps {
		t := f64(i) / f64(steps - 1)
		q := q_start.slerp(q_end, t)

		t_vals << t
		w_vals << q.w
		x_vals << q.x
		y_vals << q.y
		z_vals << q.z
	}

	// Plot components
	mut plt := plot.Plot.new()
	plt.scatter(x: t_vals, y: w_vals, mode: 'lines', name: 'w (scalar)')
	plt.scatter(x: t_vals, y: x_vals, mode: 'lines', name: 'x')
	plt.scatter(x: t_vals, y: y_vals, mode: 'lines', name: 'y')
	plt.scatter(x: t_vals, y: z_vals, mode: 'lines', name: 'z')

	plt.layout(
		title: 'Quaternion Components During SLERP'
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Interpolation Parameter t'
			}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Component Value'
			}
		}
	)
	plt.show()!
}
```

## Exercises

1. **Animate rotation**: Create a smooth rotation animation
2. **Compare methods**: Visualize LERP vs NLERP vs SLERP
3. **Multiple rotations**: Show composition of multiple rotations
4. **Quaternion Julia sets**: Generate and visualize quaternion fractals

## Next Steps

- [Examples](../../examples/quaternion_rotation_3d/) - Working visualization examples
- [Library Integration](../advanced/04-library-integration.md) - Combine with other modules
- [Machine Learning](../machine-learning/) - Use quaternions in ML

## Related Examples

- `examples/quaternion_rotation_3d` - 3D rotation visualization
- `examples/quaternion_interpolation_animation` - Animated interpolation
- `examples/quaternion_julia_fractal` - Quaternion Julia sets
- `examples/quaternion_orientation_tracking` - Orientation tracking
