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
	y_data := [
		0., 1, 3, 1, 0, -1, -3, -1, 0, 1, 3, 1, 0
	]
	mut x_data := []f64{}
	for i in 0..y_data.len {
		x_data << f64(i)
	}

	// Expected output:
	//	  .       .
	//  -' '-   -' '_
	//       '.'

	mut plt := plot.Plot{}
	plt.add_trace(
		trace_type: .scatter,
		x: x_data,
		y: y_data,
		mode: 'lines+markers',
		marker: {
			size: []f64{len: x_data.len, init: 10},
			color: []string{len: x_data.len, init: '#FF0000'},
		}
		line: {
			color: '#FF0000',
		}
	)
	plt.set_layout(
		title: 'Scatter plot example'
	)
	plt.show()
}
