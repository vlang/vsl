module main

import rand
import vsl.plot

rand.seed([u32(1), 42])

mut x1 := []f64{cap: 1000}
for _ in 1 .. 1000 {
	x1 << rand.f64n(100) or { 0 }
}
mut plt := plot.new_plot()
plt.histogram(
	x: x1
	xbins: {
		'start': f32(0)
		'end':   f32(100)
		'size':  2
	}
)
plt.layout(
	title: 'Histogram Example'
	width: 750
	height: 750
)
plt.show()!
