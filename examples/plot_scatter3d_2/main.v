module main

import math
import vsl.plot

fn main() {
	mut x := []f64{cap: 100}
	mut y := []f64{cap: 100}
	mut z := []f64{cap: 100}

	for i in 0 .. 100 {
		val := f64(i) * 0.1
		x << math.cos(val)
		y << math.sin(val)
		z << val
	}

	mut plt := plot.Plot.new()
	plt.scatter3d(
		x:      x
		y:      y
		z:      z
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: x.len, init: 15.0}
			color: []string{len: x.len, init: '#0000FF'}
		}
	)
	plt.layout(
		title: 'Scatter plot example'
	)
	plt.show()!
}
