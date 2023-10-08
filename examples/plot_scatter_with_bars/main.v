module main

import vsl.plot
import vsl.util

fn main() {
	x := util.lin_space(1.0, 10.0, 10)
	y := x.map(it * it)

	mut plt := plot.new_plot()
	plt.add_trace(
		trace_type: .scatter
		x: x
		y: y
		mode: 'markers'
		marker: plot.Marker{
			size: []f64{len: x.len, init: 10.0}
			color: []string{len: x.len, init: '#FF0000'}
		}
	)
	plt.add_trace(
		trace_type: .bar
		x_str: x.map(it.str())
		y: y
		marker: plot.Marker{
			color: []string{len: x.len, init: '#0000FF'}
		}
	)
	plt.set_layout(
		title: 'Scatter with Bars'
	)
	plt.show()!
}
