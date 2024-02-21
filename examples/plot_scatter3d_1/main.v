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
	z := util.arange(y.len).map(util.arange(y.len).map(f64(it * it)))

	mut plt := plot.Plot.new()
	plt.scatter3d(
		x: x
		y: y
		z: z
		mode: 'lines+markers'
		marker: plot.Marker{
			size: []f64{len: x.len, init: 10.0}
			color: []string{len: x.len, init: '#0000FF'}
		}
		line: plot.Line{
			color: '#0000FF'
		}
	)
	plt.layout(
		title: 'Scatter plot example'
	)
	plt.show()!
}
