module ml

fn test_knn() {
	mut x := [
		[1.0, 0.0],
		[1.2, -0.3],
		[2.5, 0.0083],
		[9.45, 10.8],
		[10.0, 10],
		[9.03, 7.75],
	]
	mut y := [
		0.,
		0,
		0,
		1,
		1,
		1,
	]
	mut knn := new_knn(mut data_from_raw_xy_sep(x, y))
	assert knn.predict(1, [0.333333, 0.66666]) == 0.0
	assert knn.predict(1, [11., 9.3]) == 1.0
}
