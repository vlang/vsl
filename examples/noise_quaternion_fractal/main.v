module main

import vsl.quaternion
import vsl.noise
import vsl.plot
import rand

// Generate quaternion fractal with noise
fn generate_fractal_point(c quaternion.Quaternion, z quaternion.Quaternion, max_iter int) int {
	mut current := z.copy()
	for i in 0 .. max_iter {
		current = current.multiply(current).add(c)
		if current.abs() > 2.0 {
			return i
		}
	}
	return max_iter
}

fn main() {
	// Fractal parameters
	resolution := 25
	max_iter := 30

	// Julia set constant with noise influence
	c_base := quaternion.quaternion(-0.123, 0.745, 0.0, 0.0)

	// Initialize noise generator
	rand.seed([u32(42), u32(42)])
	mut noise_gen := noise.Generator.new()
	noise_gen.randomize()

	println('Generating quaternion fractal with noise...')
	println('Resolution: ${resolution}x${resolution}')

	// Generate fractal
	mut x_coords := []f64{}
	mut y_coords := []f64{}
	mut z_coords := []f64{}
	mut colors := []f64{}

	range_val := 2.0
	w_fixed := 0.0
	z_fixed := 0.0

	for i in 0 .. resolution {
		for j in 0 .. resolution {
			x_val := -range_val + (2.0 * range_val * f64(i) / f64(resolution - 1))
			y_val := -range_val + (2.0 * range_val * f64(j) / f64(resolution - 1))

			// Add noise to constant
			noise_x := noise_gen.simplex_2d(x_val, y_val) * 0.1
			noise_y := noise_gen.simplex_2d(x_val * 2.0, y_val * 2.0) * 0.1

			c_noisy := quaternion.quaternion(c_base.w + noise_x * 0.1, c_base.x + noise_x,
				c_base.y + noise_y, c_base.z + noise_x * 0.05)

			z_init := quaternion.quaternion(w_fixed, x_val, y_val, z_fixed)
			iterations := generate_fractal_point(c_noisy, z_init, max_iter)

			x_coords << x_val
			y_coords << y_val
			z_coords << z_fixed
			colors << f64(iterations) / f64(max_iter)
		}

		if i % 5 == 0 {
			println('Progress: ${i * 100 / resolution}%')
		}
	}

	println('Generating plot...')

	// Create color scale
	mut color_values := []string{}
	for c_val in colors {
		// Map to color
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

	// Create plot
	mut plt := plot.Plot.new()
	plt.scatter3d(
		x:      x_coords
		y:      y_coords
		z:      z_coords
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: x_coords.len, init: 8.0}
			color: color_values
		}
		name:   'Noisy Quaternion Fractal'
	)

	plt.layout(
		title: 'Quaternion Julia Set with Noise Texture'
	)
	plt.show()!

	println('\nPlot displayed!')
	println('Noise adds texture variation to the fractal pattern.')
}
