module main

import vsl.ml
import vsl.plot
import vsl.util

xy := [
	[0.99, 90.01],
	[1.02, 89.05],
	[1.15, 91.43],
	[1.29, 93.74],
	[1.46, 96.73],
	[1.36, 94.45],
	[0.87, 87.59],
	[1.23, 91.77],
	[1.55, 99.42],
	[1.40, 93.65],
	[1.19, 93.54],
	[1.15, 92.52],
	[0.98, 90.56],
	[1.01, 89.54],
	[1.11, 89.85],
	[1.20, 90.39],
	[1.26, 93.25],
	[1.32, 93.41],
	[1.43, 94.98],
	[0.95, 87.33],
]
mut data := ml.data_from_raw_xy(xy)!
mut reg := ml.new_lin_reg(mut data, 'linear regression')

reg.train()

x := data.x.get_col(0)
y := data.y

lin_space := util.lin_space(0.8, 2.0, 21)
y_pred := lin_space.map(reg.predict([index]))

mut plt := plot.new_plot()
plt.set_layout(
	title: 'Linear Regression Example'
)

plt.add_trace(
	name: 'dataset'
	trace_type: .scatter
	x: x
	y: y
	mode: 'markers'
	colorscale: 'smoker'
	marker: plot.Marker{
		size: []f64{len: xy.len, init: 10.0}
	}
)
plt.add_trace(
	name: 'linear regression'
	trace_type: .scatter
	x: lin_space
	y: y_pred
	mode: 'lines'
	colorscale: 'smoker'
	line: plot.Line{
		color: 'red'
	}
)

plt.show()!
