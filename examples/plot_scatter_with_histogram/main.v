module main

import rand
import vsl.plot

fn main() {
	rand.seed([u32(1), 42])

	x := []f64{len: 100, init: (0 * index) + rand.f64n(100) or { 0 }}

	mut plt := plot.Plot.new()
	plt.scatter(
		x: x
		y: x
		mode: 'markers'
		marker: plot.Marker{
			size: []f64{len: x.len, init: 10.0}
			color: []string{len: x.len, init: '#FF0000'}
		}
	)
	plt.histogram(
		x: x
	)
	plt.layout(
		title: 'Scatter with Histogram'
	)
	plt.show()!
}
