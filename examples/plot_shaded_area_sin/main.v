module main

import math
import vsl.plot

fn main() {
	x := []f64{len: 100, init: f64(index) * 0.1}
	y := x.map(math.sin(it))

	mut plt := plot.Plot.new()
	plt.scatter(
		x:    x
		y:    y
		mode: 'lines'
		line: plot.Line{
			color: '#0000FF'
		}
		name: 'sin(x)'
	)
	plt.scatter(
		x:         x
		y:         []f64{len: x.len}
		mode:      'lines'
		fill:      'tozeroy'
		fillcolor: 'rgba(0, 0, 255, 0.2)'
		line:      plot.Line{
			color: 'rgba(0, 0, 255, 0)'
		}
		name: 'Shaded Area'
	)
	plt.layout(
		title: 'Shaded Area under sin(x)'
	)
	plt.show()!
}
