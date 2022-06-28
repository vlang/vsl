module la

import vsl.float.float64

const (
	tol = 1e-12
)

fn test_den_solve() {
	// case 1
	mat1 := matrix_deep2([
		[1.0, 0],
		[0.0, 2],
	])
	b1 := [1.0, 1]
	mut x1 := []f64{len: mat1.m}
	den_solve(mut x1, mat1, b1, false)
	assert float64.arrays_tolerance(x1, [1.0, 0.5], la.tol)
	// case 2
	mat2 := matrix_deep2([
		[2.0, 0, 0, -5.6],
		[0.0, 3, 0, 1.2],
		[0.0, 0, 4, 4.5],
		[2.0, -5, 1.3, 0.2],
	])
	b2 := [1.0, 2.0, 3.0, 4.0]
	mut x2 := []f64{len: mat2.m}
	den_solve(mut x2, mat2, b2, false)
	assert float64.arrays_tolerance(x2, [
		2.867389875082183,
		0.32846811308349777,
		-0.20118343195266275,
		0.8454963839579225,
	], la.tol)
}
