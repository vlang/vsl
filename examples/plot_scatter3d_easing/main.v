module main

import easings
import vsl.plot
import vsl.util

fn main() {
	// Define the time range
	frames := 100
	time := util.arange(frames).map(int_to_hex_color)

	// Apply easing to x, y, and z data
	x_values := easings.animate(easings.quadratic_ease_in_out, 0.0, 1.0, frames)
	y_values := easings.animate(easings.elastic_ease_out, 0.0, 1.0, frames)
	z_values := easings.animate(easings.bounce_ease_in_out, 0.0, 1.0, frames)

	// Create the Scatter3D plot
	mut plt := plot.new_plot()
	plt.add_trace(
		name: 'Easing Scatter3D'
		trace_type: .scatter3d
		x: x_values
		y: y_values
		z: [][]f64{len: z_values.len, init: z_values}
		mode: 'markers'
		marker: plot.Marker{
			size: []f64{len: x_values.len, init: 10.0}
			color: time // Color based on time
			colorscale: 'viridis'
		}
	)

	plt.set_layout(title: '3D Scatter Plot with Easing')
	plt.show()!
}

// int_to_hex_color converts an integer to a hexadecimal color code
fn int_to_hex_color(value int) string {
	// Ensure the value is within a valid range
	next := value % 16777216 // 16777216 is the maximum decimal value representable by a 6-digit hexadecimal number

	// Convert the integer to hexadecimal and pad with zeros
	hex_color := next.hex_full()
	return '#' + hex_color[hex_color.len - 6..]
}
