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

fn test_data_rejects_ragged_raw_rows_and_mismatched_labels() {
	assert_invalid_raw_x()
	assert_invalid_raw_xy_sep([[1.0], [2.0]], [0.0])
	assert_invalid_raw_xy_sep([[1.0], [2.0, 3.0]], [0.0, 1.0])
	assert_invalid_raw_xy([[1.0, 0.0], [2.0]])
}

fn test_data_set_requires_exact_shapes() {
	mut data := Data.new[f64](2, 1, true, true)!
	assert_set_y_error(mut data, [0.0, 1.0, 2.0])
	assert_set_x_error(mut data, la.Matrix.new[f64](3, 1))
	assert_set_x_error(mut data, la.Matrix.new[f64](2, 2))
	data.set_x(la.Matrix.new[f64](2, 1))!
	data.set_y([0.0, 1.0])!
}

fn assert_invalid_raw_x() {
	_ := Data.from_raw_x([[1.0, 2.0], [3.0]]) or {
		return
	}
	assert false
}

fn assert_invalid_raw_xy_sep(x [][]f64, y []f64) {
	_ := Data.from_raw_xy_sep(x, y) or {
		return
	}
	assert false
}

fn assert_invalid_raw_xy(x [][]f64) {
	_ := Data.from_raw_xy(x) or {
		return
	}
	assert false
}

fn assert_set_y_error(mut data Data[f64], y []f64) {
	data.set_y(y) or {
		return
	}
	assert false
}

fn assert_set_x_error(mut data Data[f64], x &la.Matrix[f64]) {
	data.set_x(x) or {
		return
	}
	assert false
}
