module main

import vsl.quaternion
import vsl.plot

// Quaternion Julia set iteration
fn julia_iterate(c quaternion.Quaternion, z quaternion.Quaternion, max_iter int) int {
	mut current := z.copy()
	for i in 0 .. max_iter {
		// z = z² + c
		current = current.multiply(current).add(c)

		// Check if escaped (magnitude > 2)
		if current.abs() > 2.0 {
			return i
		}
	}
	return max_iter
}

fn main() {
	// Julia set constant (can be modified for different fractals)
	c := quaternion.quaternion(-0.123, 0.745, 0.0, 0.0)

	// Grid resolution
	resolution := 30
	max_iter := 50

	// Generate 3D grid (we'll use 2D slice through 4D space)
	mut x_coords := []f64{}
	mut y_coords := []f64{}
	mut z_coords := []f64{}
	mut colors := []f64{}

	println('Generating quaternion Julia set...')
	println('Resolution: ${resolution}x${resolution}')
	println('Max iterations: ${max_iter}')
	println('Constant c: ${c}')

	// Sample 2D slice: fix w=0, z=0, vary x and y
	w_fixed := 0.0
	z_fixed := 0.0
	range_val := 2.0

	for i in 0 .. resolution {
		for j in 0 .. resolution {
			x_val := -range_val + (2.0 * range_val * f64(i) / f64(resolution - 1))
			y_val := -range_val + (2.0 * range_val * f64(j) / f64(resolution - 1))

			// Initial quaternion z = (w_fixed, x_val, y_val, z_fixed)
			z_init := quaternion.quaternion(w_fixed, x_val, y_val, z_fixed)

			// Iterate
			iterations := julia_iterate(c, z_init, max_iter)

			// Store point
			x_coords << x_val
			y_coords << y_val
			z_coords << z_fixed

			// Color based on iteration count
			colors << f64(iterations) / f64(max_iter)
		}

		if i % 5 == 0 {
			println('Progress: ${i * 100 / resolution}%')
		}
	}

	println('Generating plot...')

	// Create plot
	mut plt := plot.Plot.new()

	// Create color scale based on iteration count
	mut color_values := []string{}
	for c_val in colors {
		// Map to color: blue (low) -> green -> yellow -> red (high)
		r := if c_val < 0.33 {
			0.0
		} else if c_val < 0.66 {
			(c_val - 0.33) * 3.0
		} else {
			1.0
		}
		g := if c_val < 0.33 {
			c_val * 3.0
		} else if c_val < 0.66 {
			1.0
		} else {
			(1.0 - c_val) * 3.0
		}
		b := if c_val < 0.33 {
			1.0
		} else if c_val < 0.66 {
			(0.66 - c_val) * 3.0
		} else {
			0.0
		}

		r_int := int(r * 255)
		g_int := int(g * 255)
		b_int := int(b * 255)
		color_values << '#${r_int:02X}${g_int:02X}${b_int:02X}'
	}

	plt.scatter3d(
		x:      x_coords
		y:      y_coords
		z:      z_coords
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: x_coords.len, init: 8.0}
			color: color_values
		}
		name:   'Julia Set'
	)

	plt.layout(
		title: 'Quaternion Julia Set Fractal (2D slice: w=0, z=0)'
	)

	plt.show()!

	println('\nPlot displayed!')
	println('Color indicates iteration count before escape (darker = more iterations).')
	println('Try modifying the constant c for different fractal patterns!')
}
