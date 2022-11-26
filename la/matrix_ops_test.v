module la

import math

const (
	tol = 1e-12
)

fn tolerance_equal[T](data1 []T, data2 []T) bool {
	if data1.len != data2.len {
		return false
	}
	for i := 0; i < data1.len; i++ {
		if f64(math.abs(f64(data1[i] - data2[i]))) > la.tol {
			return false
		}
	}
	return true
}

fn test_det() {
	mat_a := matrix_deep2([
		[3.0, 8.0],
		[4.0, 6.0],
	])
	assert matrix_det(mat_a) == -14
	mat_b := matrix_deep2([
		[6.0, 1.0, 1.0],
		[4.0, -2.0, 5.0],
		[2.0, 8.0, 7.0],
	])
	assert matrix_det(mat_b) == -306
}

fn test_matrix_inv_small() {
	// case 1
	mat1 := matrix_deep2([
		[1.0, 0.0],
		[0.0, 1.0],
	])
	mut inv1 := new_matrix[f64](2, 2)
	det1 := matrix_inv_small(mut inv1, mat1, la.tol)
	assert tolerance_equal(mat1.data, inv1.data)
	assert math.abs(det1 - 1.0) <= la.tol
	// case 2
	mat2 := matrix_deep2([
		[2.0, 3.0],
		[3.0, 4.0],
	])
	ex2 := matrix_deep2([
		[-4.0, 3.0],
		[3.0, -2.0],
	])
	mut inv2 := new_matrix[f64](2, 2)
	det2 := matrix_inv_small(mut inv2, mat2, la.tol)
	assert tolerance_equal(inv2.data, ex2.data)
	assert math.abs(det2 + 1.0) <= la.tol
	// case 3
	mat3 := matrix_deep2([
		[-2.0, 2.0, 0.0],
		[2.0, 1.0, 3.0],
		[-2.0, 4.0, -2.0],
	])
	ex3 := matrix_deep2([
		[-7.0 / 12, 1.0 / 6, 1.0 / 4],
		[-1.0 / 12, 1.0 / 6, 1.0 / 4],
		[5.0 / 12, 1.0 / 6, -1.0 / 4],
	])
	mut inv3 := new_matrix[f64](3, 3)
	det3 := matrix_inv_small(mut inv3, mat3, la.tol)
	assert tolerance_equal(inv3.data, ex3.data)
	assert math.abs(det3 - 24.0) <= la.tol
	// case 4
	mat4 := matrix_deep2([[14.0]])
	ex4 := matrix_deep2([[1.0 / 14]])
	mut inv4 := new_matrix[f64](1, 1)
	det4 := matrix_inv_small(mut inv4, mat4, la.tol)
	assert tolerance_equal(inv4.data, ex4.data)
	assert math.abs(det4 - 14.0) <= la.tol
}
