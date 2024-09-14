module main

import rand
import vsl.plot

fn main() {
	rand.seed([u32(1), 42])

	x := []f64{len: 1000, init: (0 * index) + rand.f64n(100) or { 0 }}

	mut plt := plot.Plot.new()
	plt.histogram(
		x:     x
		xbins: plot.Bins{
			start: 0.0
			end:   100.0
			size:  2
		}
	)
	plt.layout(
		title:  'Histogram Example'
		width:  750
		height: 750
	)
	plt.show()!
}
