module blas

fn test_dgemv_no_trans_1() {
	expected := [0.0, 0, 0, 0, 0]
	a := [
		[4.1, 6.2, 8.1],
		[9.6, 3.5, 9.1],
		[10.0, 7, 3],
		[1.0, 1, 2],
		[9.0, 2, 5],
	]
	m := a.len
	n := a[0].len
	alpha := 0.0
	beta := 0.0
	incx := 1
	incy := 1
	x := [1.0, 2, 3]
	mut y := [7.0, 8, 9, 10, 11]
	dgemv(.no_trans, m, n, 0.0, flatten(a), a[0].len, x, incx, beta, mut y, incy)
	assert expected == y
}

fn test_dgemv_no_trans_2() {
	expected := [7.0, 8, 9, 10, 11]
	a := [
		[4.1, 6.2, 8.1],
		[9.6, 3.5, 9.1],
		[10.0, 7, 3],
		[1.0, 1, 2],
		[9.0, 2, 5],
	]
	m := a.len
	n := a[0].len
	alpha := 0.0
	beta := 1.0
	incx := 1
	incy := 1
	x := [1.0, 2, 3]
	mut y := [7.0, 8, 9, 10, 11]
	dgemv(.no_trans, m, n, 0.0, flatten(a), a[0].len, x, incx, beta, mut y, incy)
	assert expected == y
}

fn test_dgemv_no_trans_3() {
	expected := [40.8, 43.9, 33, 9, 28]
	a := [
		[4.1, 6.2, 8.1],
		[9.6, 3.5, 9.1],
		[10.0, 7, 3],
		[1.0, 1, 2],
		[9.0, 2, 5],
	]
	m := a.len
	n := a[0].len
	alpha := 1.0
	beta := 0.0
	incx := 1
	incy := 1
	x := [1.0, 2, 3]
	mut y := [7.0, 8, 9, 10, 11]
	dgemv(.no_trans, m, n, 1.0, flatten(a), a[0].len, x, incx, beta, mut y, incy)
	assert expected == y
}

fn test_dgemv_no_trans_4() {
	expected := [284.4, 303.2, 210, 12, 158]
	a := [
		[4.1, 6.2, 8.1],
		[9.6, 3.5, 9.1],
		[10.0, 7, 3],
		[1.0, 1, 2],
		[9.0, 2, 5],
	]
	m := a.len
	n := a[0].len
	alpha := 8.0
	beta := -6.0
	incx := 1
	incy := 1
	x := [1.0, 2, 3]
	mut y := [7.0, 8, 9, 10, 11]
	dgemv(.no_trans, m, n, 8.0, flatten(a), a[0].len, x, incx, beta, mut y, incy)
	assert expected == y
}

fn test_dgemv_trans_1() {
	expected := [0.0, 0, 0]
	a := [
		[4.1, 6.2, 8.1],
		[9.6, 3.5, 9.1],
		[10.0, 7, 3],
		[1.0, 1, 2],
		[9.0, 2, 5],
	]
	m := a.len
	n := a[0].len
	alpha := 0.0
	beta := 0.0
	incx := 1
	incy := 1
	x := [1.0, 2, 3, -4, 5]
	mut y := [7.0, 8, 9]
	dgemv(.trans, m, n, 0.0, flatten(a), a[0].len, x, incx, beta, mut y, incy)
	assert expected == y
}

fn test_dgemv_trans_2() {
	expected := [7.0, 8, 9]
	a := [
		[4.1, 6.2, 8.1],
		[9.6, 3.5, 9.1],
		[10.0, 7, 3],
		[1.0, 1, 2],
		[9.0, 2, 5],
	]
	m := a.len
	n := a[0].len
	alpha := 0.0
	beta := 1.0
	incx := 1
	incy := 1
	x := [1.0, 2, 3, -4, 5]
	mut y := [7.0, 8, 9]
	dgemv(.trans, m, n, 0.0, flatten(a), a[0].len, x, incx, beta, mut y, incy)
	assert expected == y
}

fn test_dgemv_trans_3() {
	expected := [94.3, 40.2, 52.3]
	a := [
		[4.1, 6.2, 8.1],
		[9.6, 3.5, 9.1],
		[10.0, 7, 3],
		[1.0, 1, 2],
		[9.0, 2, 5],
	]
	m := a.len
	n := a[0].len
	alpha := 1.0
	beta := 0.0
	incx := 1
	incy := 1
	x := [1.0, 2, 3, -4, 5]
	mut y := [7.0, 8, 9]
	dgemv(.trans, m, n, 1.0, flatten(a), a[0].len, x, incx, beta, mut y, incy)
	assert expected == y
}

fn test_dgemv_trans_4() {
	expected := [712.4, 273.6, 364.4]
	a := [
		[4.1, 6.2, 8.1],
		[9.6, 3.5, 9.1],
		[10.0, 7, 3],
		[1.0, 1, 2],
		[9.0, 2, 5],
	]
	m := a.len
	n := a[0].len
	alpha := 8.0
	beta := -6.0
	incx := 1
	incy := 1
	x := [1.0, 2, 3, -4, 5]
	mut y := [7.0, 8, 9]
	dgemv(.trans, m, n, 8.0, flatten(a), a[0].len, x, incx, beta, mut y, incy)
	assert expected == y
}
