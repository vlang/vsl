module main

import vsl.plot
import vsl.util

fn main() {
	y := [
		0.0,
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
	x := util.arange(y.len)
	mut plt := plot.Plot.new()
	plt.scatter(
		x: x
		y: y
		mode: 'lines+markers'
		marker: plot.Marker{
			size: []f64{len: x.len, init: 10.0}
			color: []string{len: x.len, init: '#FF0000'}
		}
		line: plot.Line{
			color: '#FF0000'
		}
	)
	plt.layout(
		title: 'Scatter plot example'
		annotations: [plot.Annotation{
			text: 'test annotation'
		}]
	)
	plt.show()!
}
