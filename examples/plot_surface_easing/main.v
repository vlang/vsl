module main

import vsl.easings
import vsl.plot

fn main() {
	// Define the time range
	frames := 100

	// Apply easing to x, y, and z data
	x_values := easings.animate(easings.quadratic_ease_in_out, 0.0, 1.0, frames)
	y_values := easings.animate(easings.elastic_ease_out, 0.0, 1.0, frames)
	z_values := easings.animate(easings.bounce_ease_in_out, 0.0, 1.0, frames)

	// Create the Surface plot
	mut plt := plot.Plot.new()
	plt.surface(
		name: 'Easing Surface'
		x: x_values
		y: y_values
		z: [][]f64{len: z_values.len, init: z_values}
		colorscale: 'viridis'
	)

	plt.layout(title: 'Surface Plot with Easing')
	plt.show()!
}
