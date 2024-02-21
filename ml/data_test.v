module ml

import vsl.la

fn check_xy_01(x &la.Matrix[f64], y []f64) {
	expected := [
		[-1.0, 0, -3],
		[-2.0, 3, 3],
		[3.0, 1, 4],
		[-4.0, 5, 0],
		[1.0, -8, 5],
	]
	xm := x.get_deep2()
	for i, r in xm {
		assert r == expected[i]
	}
	assert y == [0.0, 1, 1, 0, 1]
}

fn test_data_01() {
	data := Data.from_raw_xy([
		[-1.0, 0, -3, 0],
		[-2.0, 3, 3, 1],
		[3.0, 1, 4, 1],
		[-4.0, 5, 0, 0],
		[1.0, -8, 5, 1],
	])!
	check_xy_01(data.x, data.y)
	data_backup := data.clone()!
	check_xy_01(data_backup.x, data_backup.y)
	assert data_backup.nb_features == 3
	assert data_backup.nb_samples == 5
}

fn test_split() {
	data := Data.from_raw_xy([
		[-1.0, 0, -3, 0],
		[-2.0, 3, 3, 1],
		[3.0, 1, 4, 1],
		[-4.0, 5, 0, 0],
		[1.0, -8, 5, 1],
		[-1.0, 0, -3, 1],
	])!
	data1, data2 := data.split(0.2)!
	assert data1.nb_samples == 1
	assert data2.nb_samples == 5
	assert data1.nb_features == 3
	assert data2.nb_features == 3
}
