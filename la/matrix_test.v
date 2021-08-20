module la

import vsl.vmath

fn test_new_matrix() {
	mat := new_matrix(3, 2)
	expected_data := []f64{len: 6, init: 0.0}
	assert mat.m == 3
	assert mat.n == 2
	assert mat.data == expected_data
}

fn test_matrix_deep2() {
	original_array := [
		[11.0, 12.0, 13.0, 14.0],
		[21.0, 22.0, 23.0, 24.0],
		[31.0, 32.0, 33.0, 34.0],
	]
	mat := matrix_deep2(original_array)
	assert mat.m == 3
	assert mat.n == 4
	// The data is stored in column-major format
	assert mat.data == [11., 12, 13, 14, 21, 22, 23, 24, 31, 32, 33, 34]
}

fn test_set_from_deep2() {
	original_array := [
		[1.0, 1.0, 2.0],
		[5.0, 4.0, 2.0],
	]
	mut mat := new_matrix(2, 3)
	mat.set_from_deep2(original_array)
	assert mat.data == [1., 1, 2, 5, 4, 2]
}

fn test_set_diag() {
	mut mat := new_matrix(4, 4)
	mat.set_diag(36)
	assert mat.data == [36.0, 0, 0, 0, 0, 36.0, 0, 0, 0, 0, 36.0, 0, 0, 0, 0, 36.0]
}

fn test_set_and_get() {
	mut mat := matrix_deep2([
		[10.0, 11.0, 12.0, 13.0],
		[20.0, 21.0, 22.0, 23.0],
		[30.0, 31.0, 32.0, 33.0],
	])
	assert mat.get(1, 1) == 21.0
	mat.set(1, 1, 39.0)
	assert mat.get(1, 1) == 39.0
	assert mat.get(2, 1) == 31.0
}

fn test_get_deep2() {
	original_array := [
		[45.0, 62.6, 36.1, 0.63],
		[3.62, 0.15, -0.5, 35.5],
		[-4.1, 0.62, -984, 45.1],
	]
	mat := matrix_deep2(original_array)
	assert mat.get_deep2() == original_array
}

fn test_matrix_clone() {
	mat1 := matrix_deep2([
		[0.1, 0.2, 0.3],
		[1.1, 1.2, 1.3],
	])
	mat2 := mat1.clone()
	assert mat1.m == mat2.m
	assert mat1.n == mat2.n
	assert mat1.data == mat2.data
}

fn test_transpose() {
	mat1 := matrix_deep2([
		[1.0, 2.0, 3.0],
		[4.0, 5.0, 6.0],
	])
	mat2 := matrix_deep2([
		[1.0, 4.0],
		[2.0, 5.0],
		[3.0, 6.0],
	])
	mat3 := mat2.transpose()
	mat4 := mat1.transpose()
	// Test one way
	assert mat1.m == mat3.m
	assert mat1.n == mat3.n
	assert mat1.data == mat3.data
	// Test other way
	assert mat2.m == mat4.m
	assert mat2.n == mat4.n
	assert mat2.data == mat4.data
	// Test double transpose
	assert mat1.data == mat4.transpose().data
}

fn test_copy_into_and_matrix_raw() {
	mat_a := matrix_raw(3, 4, []f64{len: 12, init: 42})
	mut mat_b := new_matrix(3, 4)
	mat_a.copy_into(mut mat_b, 0.5)
	assert mat_b.data == []f64{len: 12, init: 21}
}

fn test_add() {
	mut mat := matrix_raw(1, 2, [0.1, 0.2])
	mat.add(0, 1, 1)
	assert mat.get(0, 1) == 1.2
}

fn test_fill() {
	mat_a := matrix_raw(3, 4, []f64{len: 12, init: 54.3})
	mut mat_b := new_matrix(3, 4)
	mat_b.fill(54.3)
	assert mat_a.data == mat_b.data
}

fn test_clear_rc() {
	mut mat_a := matrix_deep2([
		[1.0, 2.0, 3.0, 4.0],
		[5.0, 6.0, 7.0, 8.0],
		[4.0, 3.0, 2.0, 1.0],
	])
	mat_b := matrix_deep2([
		[1.0, 2.0, 3.0, 4.0],
		[0.0, 1.0, 0.0, 0.0],
		[0.0, 0.0, 1.0, 0.0],
	])
	mat_a.clear_rc([1, 2], [], 1.0)
	assert mat_a.data == mat_b.data
}

fn test_clear_bry() {
	mut mat_a := matrix_deep2([
		[1.0, 2.0, 3.0],
		[4.0, 5.0, 6.0],
		[7.0, 8.0, 9.0],
	])
	mat_b := matrix_deep2([
		[1.0, 0.0, 0.0],
		[0.0, 5.0, 0.0],
		[0.0, 0.0, 1.0],
	])
	mat_a.clear_bry(1.0)
	assert mat_a.data == mat_b.data
}

fn test_max_diff() {
	mat_a := matrix_raw(3, 2, [1.0, 5, 3, 6, 7, 3])
	mat_b := matrix_raw(3, 2, [4.0, 19, 42, 3, -31, 5])
	assert mat_a.max_diff(mat_b) == 39
}

fn test_largest() {
	mat := matrix_raw(3, 3, [1.0, 5, 3, 6, -74, 3, 24, 62, -39])
	assert mat.largest(74) == 1
}

fn test_col_get_row_get_col() {
	mat := matrix_deep2([
		[11.0, 12.0, 13.0],
		[21.0, 22.0, 23.0],
		[31.0, 32.0, 33.0],
	])
	assert mat.col(1) == [12.0, 22.0, 32.0]
	assert mat.get_row(2) == [31.0, 32.0, 33.0]
	assert mat.get_col(0) == [11.0, 21.0, 31.0]
}

fn test_extract_cols_and_set_col() {
	mut mat := matrix_deep2([
		[11.0, 12.0, 13.0],
		[21.0, 22.0, 23.0],
		[31.0, 32.0, 33.0],
	])
	println(mat.data)
	mat_e := mat.extract_cols(1, 3)
	assert mat_e.m == 3
	assert mat_e.n == 2
	assert mat_e.data == [12.0, 13, 22, 23, 32, 33]
	mat.set_col(0, -3)
	assert mat.col(0) == [-3.0, -3.0, -3.0]
}

fn test_frobenius_norm() {
	mat_a := matrix_deep2([
		[1.0, 2.0],
		[3.0, 4.0],
	])
	assert mat_a.norm_frob() == vmath.sqrt(30)
	mat_b := matrix_deep2([
		[1.0, 4.0, 6.0],
		[7.0, 9.0, 10.],
	])
	assert mat_b.norm_frob() == vmath.sqrt(283)
}

fn test_infinite_norm() {
	mat_a := matrix_deep2([
		[1.0, -7.],
		[-2., -3.],
	])
	assert mat_a.norm_inf() == 8
	mat_b := matrix_deep2([
		[5.0, -4., 2.0],
		[-1., 2.0, 3.0],
		[-2., 1.0, 0.0],
	])
	assert mat_b.norm_inf() == 11
}

fn test_apply() {
	mat_a := matrix_raw(1, 4, [0.0, 2.0, 4.0, 6.0])
	mut mat_b := new_matrix(1, 4)
	mat_b.apply(3.0 / 2.0, mat_a)
	assert mat_b.data == [0.0, 3.0, 6.0, 9.0]
}

fn test_det() {
	mat_a := matrix_deep2([
		[3.0, 8.0],
		[4.0, 6.0],
	])
	assert mat_a.det() == -14
	mat_b := matrix_deep2([
		[6.0, 1.0, 1.0],
		[4.0, -2., 5.0],
		[2.0, 8.0, 7.0],
	])
	assert mat_b.det() == -306
}

fn test_str_and_print_functions() {
	mat := matrix_raw(2, 2, [1.0, 2.0, 3.0, 4.0])
	assert mat.str() == '1 2 \n3 4 '
	assert mat.print('%g ') == '1 2 \n3 4 '
	assert mat.print_v('%g') == '[][]f64{\n    {1,2},\n    {3,4},\n}'
	assert mat.print_py('%g') == 'np.matrix([\n    [1,2],\n    [3,4],\n], dtype=float)'
}
