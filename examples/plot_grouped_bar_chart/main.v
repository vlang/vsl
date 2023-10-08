module main

import vsl.plot

fn main() {
	categories := ['A', 'B', 'C', 'D']
	values1 := [10.0, 15, 7, 12]
	values2 := [8.0, 14, 5, 10]

	mut plt := plot.new_plot()
	plt.add_trace(
		trace_type: .bar
		x_str: categories
		y: values1
		name: 'Group 1'
	)
	plt.add_trace(
		trace_type: .bar
		x_str: categories
		y: values2
		name: 'Group 2'
	)
	plt.set_layout(
		title: 'Grouped Bar Chart'
	)
	plt.show()!
}
