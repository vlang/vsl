module main

import math
import vsl.plot
import vsl.util

fn main() {
	x := util.lin_space(0.0, 10.0, 100)
	y := util.lin_space(0.0, 10.0, 100)

	mut z := [][]f64{cap: y.len}
	for y_val in y {
		mut row := []f64{cap: x.len}
		for x_val in x {
			r := math.sqrt(math.pow(x_val - 5.0, 2.0) + math.pow(y_val - 5.0, 2.0))
			row << math.sin(r) / r
		}
		z << row
	}

	mut plt := plot.Plot.new()
	plt.surface(
		x: x
		y: y
		z: z
		colorscale: 'Viridis'
	)
	plt.layout(
		title: 'Ripple Effect Surface'
	)
	plt.show()!
}
