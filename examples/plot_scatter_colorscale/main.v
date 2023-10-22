module main

import vsl.plot
import vsl.util

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
	colorscale: 'smoker'
	marker: plot.Marker{
		size: []f64{len: x.len, init: 10.0}
	}
)
plt.layout(
	title: 'Scatter plot example'
)
plt.show()!
