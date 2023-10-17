module main

import vsl.plot

fn main() {
	mut plt := plot.new_plot()

	plt.bar(
		x: ['China', 'India', 'USA', 'Indonesia', 'Pakistan']
		y: [1411778724.0, 1379217184, 331989449, 271350000, 225200000]
	)
	plt.layout(
		title: 'Countries by population'
	)
	plt.show()!
}
