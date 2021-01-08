module la

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
	assert mat.data ==
		[11.0, 21.0, 31.0, 12.0, 22.0, 32.0, 13.0, 23.0, 33.0, 14.0, 24.0, 34.0]
}

fn test_set_from_deep2() {
	original_array := [
		[1.0, 1.0, 2.0],
		[5.0, 4.0, 2.0],
	]
	mut mat := new_matrix(2, 3)
	mat.set_from_deep2(original_array)
	assert mat.data == [1.0, 5, 1, 4, 2, 2]
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

fn test_copy_into() {
	mat_a := matrix_raw(3, 4, []f64{len: 12, init: 42})
	mut mat_b := new_matrix(3, 4)
	mat_a.copy_into(mut mat_b, 0.5)
	assert mat_b.data == []f64{len: 12, init: 21}
}
