module main

import vsl.plot

fn main() {
	// Here we have a dirty workaround for the bar graph.
	// Plotly expects the `x` attribute to be a list of strings,
	// but all the others expect it as a list of numbers.
	// Therefore, we added `x_str` which is handled by the
	// Python code, and it will be used as `x`.

	plot.new_plot().add_trace(
		trace_type: .bar
		x_str: ['China', 'India', 'USA', 'Indonesia', 'Pakistan']
		y: [1411778724., 1379217184, 331989449, 271350000, 225200000]
	).set_layout(
		title: 'Countries by population'
	).show() or { panic(err) }
}
