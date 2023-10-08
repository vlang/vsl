module main

import math
import vsl.plot
import vsl.util

fn main() {
	x := util.lin_space(0.0, 5.0, 50)
	y := util.lin_space(0.0, 5.0, 50)

	mut z := [][]f64{cap: y.len}
	for y_val in y {
		mut row := []f64{cap: x.len}
		for x_val in x {
			row << math.sin(x_val) + math.cos(y_val)
		}
		z << row
	}

	mut plt := plot.new_plot()
	plt.add_trace(
		trace_type: .surface
		x: x
		y: y
		z: z
		colorscale: 'Viridis'
	)
	plt.set_layout(
		title: 'Surface Plot Example'
	)
	plt.show()!
}
