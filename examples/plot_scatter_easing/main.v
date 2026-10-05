module main

import vsl.easings
import vsl.plot
import time as timeutil

fn main() {
	// Define the time range
	frames := 100
	mut time := []string{len: frames}
	for frame in 0 .. frames {
		time[frame] = int_to_hex_color(frame)
	}

	// Apply easing to x, y, and z data
	x_values := easings.animate(easings.quadratic_ease_in_out, 0.0, 1.0, frames)
	y_values := easings.animate(easings.elastic_ease_out, 0.0, 1.0, frames)

	// Create the Scatter plot
	mut plt := plot.Plot.new()
	plt.scatter(
		name:       'Easing Scatter'
		x:          x_values
		y:          y_values
		mode:       'markers'
		colorscale: 'viridis'
		marker:     plot.Marker{
			size:       []f64{len: x_values.len, init: 10.0}
			color:      time // Color based on time
			colorscale: 'viridis'
		}
	)

	plt.layout(title: 'Scatter Plot with Easing')
	// Pass the listener defaults explicitly: this avoids a V3 compiler panic
	// while expanding the default arguments for Plot.show.
	plt.show(timeout: 1 * timeutil.second, use_cdn: true, dualstack: true, backlog: 128)!
}

// int_to_hex_color converts an integer to a hexadecimal color code
fn int_to_hex_color(value int) string {
	// Ensure the value is within a valid range
	next := value % 16777216 // 16777216 is the maximum decimal value representable by a 6-digit hexadecimal number

	// Convert the integer to hexadecimal and pad with zeros
	hex_color := next.hex_full()
	return '#' + hex_color[hex_color.len - 6..]
}
