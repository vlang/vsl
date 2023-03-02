module la

import vsl.float.float64

fn test_jacobi01() {
	mut a := matrix_deep2([
		[2.0, 0, 0],
		[0.0, 2, 0],
		[0.0, 0, 2],
	])

	mut q := new_matrix[f64](3, 3)
	mut v := []f64{len: 3}

	mut expected_q := matrix_deep2([
		[1.0, 0, 0],
		[0.0, 1, 0],
		[0.0, 0, 1],
	])

	mut expected_v := [2.0, 2.0, 2.0]

	jacobi(mut q, mut v, mut a)!

	assert float64.arrays_tolerance(q.data, expected_q.data, 1e-17)
	assert float64.arrays_tolerance(v, expected_v, 1e-17)
}
