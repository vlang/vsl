module ml

import vsl.float.float64

fn sample_01_check_sat[T](o &Stat[T]) {
	assert float64.tolerance(o.min_x[0], 0.87, 1e-15)
	assert float64.tolerance(o.max_x[0], 1.55, 1e-15)
	assert float64.tolerance(o.mean_x[0], 1.1960, 1e-15)
	assert float64.tolerance(o.sig_x[0], 0.189303432281837, 1e-14)
	assert float64.tolerance(o.sum_x[0], 23.92, 1e-15)
	assert float64.tolerance(o.min_y, 87.33, 1e-15)
	assert float64.tolerance(o.max_y, 99.42, 1e-15)
	assert float64.tolerance(o.mean_y, 92.1605, 1e-15)
	assert float64.tolerance(o.sig_y, 3.020778001913102, 1e-15)
	assert float64.tolerance(o.sum_y, 1843.21, 1e-15)
}

fn test_stat_01() {
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
	mut data := data_from_raw_xy(xy)?

	// stat
	mut stat := stat_from_data(mut data, 'stat')

	// notify update
	data.notify_update()

	// check
	sample_01_check_sat(stat)

	s, t := stat.sum_vars()
	assert s == [23.92]
	assert float64.tolerance(t, 1843.21, 1e-15)
}
