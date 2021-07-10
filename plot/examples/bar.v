/*

	Author: @lucasrdrgs
	No license, do whatever you want with the code below.

	IMPORTANT:
	vsl.plot tries its best to be 100% compatible with
	Plotly's documentation (at https://plotly.com/python/)
	EVERYTHING RELIES ON GRAPH_OBJECTS, DO NOT USE PLOTLYEXPRESS SYNTAX.

*/

import vsl
import vsl.plot

fn main() {
	mut plt := plot.Plot{}
	// Here we have a dirty workaround for the bar graph.
	// Plotly expects the `x` attribute to be a list of strings,
	// but all the others expect it as a list of numbers.
	// Therefore, we added `x_str` which is handled by the
	// Python code, and it will be used as `x`.
	plt.add_trace(
		trace_type: .bar,
		x_str: ['China', 'India', 'USA', 'Indonesia', 'Pakistan'],
		y: [1411778724., 1379217184., 331989449., 271350000., 225200000.] // Everything must be f64
	)
	plt.set_layout(
		title: 'Countries by population'
	)
	plt.show()
}
