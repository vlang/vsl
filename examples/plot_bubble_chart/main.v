module main

import vsl.plot

fn main() {
	x := []f64{len: 100, init: f64(index) * 0.1}
	y := []f64{len: 100, init: f64(index) * 0.1}
	size := []f64{len: 10, init: f64(index) * 10.0}

	mut plt := plot.Plot.new()
	plt.scatter(
		x:      x
		y:      y
		mode:   'markers'
		marker: plot.Marker{
			size:  size
			color: []string{len: x.len * y.len, init: '#FF0000'}
		}
		name:   'Bubble Chart'
	)
	plt.layout(
		title: 'Bubble Chart'
	)
	plt.show()!
}
