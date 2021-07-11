module main

import vsl.plot
import vsl.util

fn main() {
	y := [
		0.,
		1,
		3,
		1,
		0,
		-1,
		-3,
		-1,
		0,
		1,
		3,
		1,
		0,
	]
	x := util.arange(y.len).map(f64(it))

	mut plt := plot.new_plot()
	plt.add_trace(
		trace_type: .scatter
		x: x
		y: y
		mode: 'lines+markers'
		marker: {
			size: []f64{len: x.len, init: 10.}
			color: []string{len: x.len, init: '#FF0000'}
		}
		line: {
			color: '#FF0000'
		}
	)
	plt.set_layout(
		title: 'Scatter plot example'
	)
	plt.show() or { panic(err) }
}
