module main

import vsl.plot
import vsl.util

fn main() {
	x := util.lin_space(-5.0, 5.0, 100)
	y := util.lin_space(-5.0, 5.0, 100)

	mut z := [][]f64{cap: y.len}
	for y_val in y {
		mut row := []f64{cap: x.len}
		for x_val in x {
			z_val := x_val * x_val - y_val * y_val
			row << z_val
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
		title: 'Saddle Surface'
	)
	plt.show()!
}
