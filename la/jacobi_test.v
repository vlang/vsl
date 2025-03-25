module la

import vsl.float.float64

fn test_jacobi01() {
	mut a := Matrix.deep2([
		[2.0, 0, 0],
		[0.0, 2, 0],
		[0.0, 0, 2],
	])

	mut q := Matrix.new[f64](3, 3)
	mut v := []f64{len: 3}

	mut expected_q := Matrix.deep2([
		[1.0, 0, 0],
		[0.0, 1, 0],
		[0.0, 0, 1],
	])

	mut expected_v := [2.0, 2.0, 2.0]
	mut expected_a := Matrix.deep2([
		[2.0, 0.0, 0.0],
		[0.0, 2.0, 0.0],
		[0.0, 0.0, 2.0],
	])

	jacobi(mut q, mut v, mut a)!

	assert float64.arrays_tolerance(q.data, expected_q.data, 1e-17)
	assert float64.arrays_tolerance(v, expected_v, 1e-17)
	assert float64.arrays_tolerance(a.data, expected_a.data, 1e-17)
}

fn test_jacobi_3x3_symmetric() {
	mut a := Matrix.deep2([
		[4.0, 1.0, 1.0],
		[1.0, 3.0, 0.0],
		[1.0, 0.0, 2.0],
	])

	mut q := Matrix.new[f64](3, 3)
	mut v := []f64{len: 3}

	mut expected_q := Matrix.deep2([
		[0.8440296287459851, -0.29312841385727223, -0.4490987851112868],
		[0.4490987851112867, 0.8440296287459852, 0.29312841385727234],
		[0.29312841385727223, -0.44909878511128676, 0.8440296287459852],
	])

	mut expected_v := [4.879385241571816, 2.652703644666139, 1.4679111137620442]
	mut expected_a := Matrix.deep2([
		[4.879385241571816, 0.0, 0.0],
		[0.0, 2.652703644666139, 0.0],
		[0.0, 0.0, 1.4679111137620442],
	])

	jacobi(mut q, mut v, mut a)!

	assert float64.arrays_tolerance(v, expected_v, 1e-17)
	assert float64.arrays_tolerance(q.data, expected_q.data, 1e-17)
	assert float64.arrays_tolerance(a.data, expected_a.data, 1e-17)
}
