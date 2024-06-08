module main

import math
import vsl.plot

fn main() {
	x := []f64{len: 100, init: f64(index) * 0.1}
	y1 := x.map(math.sin(it))
	y2 := x.map(math.cos(it))

	mut plt := plot.Plot.new()
	plt.scatter(
		x: x
		y: y1
		mode: 'lines'
		line: plot.Line{
			color: '#FF0000'
		}
		name: 'sin(x)'
	)
	plt.scatter(
		x: x
		y: y2
		mode: 'lines'
		line: plot.Line{
			color: '#0000FF'
		}
		name: 'cos(x)'
	)
	plt.layout(
		title: 'Line Plot with axis titles'
		xaxis: plot.Axis { 
			title: plot.AxisTitle { 'x' } 
		}
		yaxis: plot.Axis { 
			title: plot.AxisTitle { 'f(x)' } 
		}
	)
	plt.show()!
}
