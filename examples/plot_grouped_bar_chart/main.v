module main

import vsl.plot

fn main() {
	categories := ['A', 'B', 'C', 'D']
	values1 := [10.0, 15, 7, 12]
	values2 := [8.0, 14, 5, 10]

	mut plt := plot.Plot.new()
	plt.bar(
		x: categories
		y: values1
		name: 'Group 1'
	)
	plt.bar(
		x: categories
		y: values2
		name: 'Group 2'
	)
	plt.layout(
		title: 'Grouped Bar Chart'
	)
	plt.show()!
}
