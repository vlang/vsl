module main

import vsl.plot

fn main() {
	z := [[1.0, 0, 30, 50, 1], [20.0, 1, 60, 80, 30], [30.0, 60, 1, -10, 20]]
	x := ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
	y := ['Morning', 'Afternoon', 'Evening']

	mut plt := plot.Plot.new()

	plt.heatmap(
		x: x
		y: y
		z: z
	)
	plt.layout(
		title:  'Heatmap Basic Implementation'
		width:  750
		height: 750
	)

	plt.show()!
}
