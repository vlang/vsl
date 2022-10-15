module main

import vsl.plot
import rand
rand.seed([u32(1), 42])
mut x1 := []f64{}
for _ in 1..1000{
	x1 << rand.f64n(100) or { 0 }
}
mut plt := plot.new_plot()
plt.add_trace(
	trace_type: .histogram
	x: x1
	xbins: {
		'start': f32(0),
		'end': f32(100),
		'size': 2
	}
)
plt.set_layout(
	title: 'Histogram Example'
	width: 750
	height: 750
)
plt.show()?