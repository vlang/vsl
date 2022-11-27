module main

import vsl.float.float64
import vsl.ml

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
mut data := ml.data_from_raw_xy(xy)?
mut reg := ml.new_lin_reg(mut data, 'linear regression')

// set regularization parameter
reg.params.set_lambda(1e12) // very high bias => constant line

reg.train()

for x0 in [0.8, 1.2, 2.0] {
	pred := reg.predict([x0])
	assert float64.tolerance(pred, reg.stat.mean_y, 1e-3)
	println('x0: ${x0}, pred: ${pred}')
}
