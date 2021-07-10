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
	plt.add_trace(
		trace_type: .pie,
		labels: ['Nitrogen', 'Oxygen', 'Argon', 'Other'],
		values: [78.0, 21.0, 0.9, 0.1],
		pull: [0.0, 0.1, 0.0, 0.0],
		hole: 0.25
	)
	plt.set_layout(
		title: 'Gases in the atmosphere',
		width: 750,
		height: 750
	)
	plt.show()
}
