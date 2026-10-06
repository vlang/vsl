module la

fn test_matrix_matrix_mul_f32() {
	a := [f32(1), 2, 3, 4]
	b := [f32(5), 6, 7, 8]
	mut c := []f32{len: 4}
	matrix_matrix_mul_f32(mut c, 2, 2, 2, 1, a, b)
	assert c == [f32(19), 22, 43, 50]
}

fn test_mat_vec_mul() {
	expected := [8.0, 45, -3, 3, 19]
	a := Matrix.deep2([
		[2.0, 3, 0, 0, 0],
		[3.0, 0, 4, 0, 6],
		[0.0, -1, -3, 2, 0],
		[0.0, 0, 1, 0, 0],
		[0.0, 4, 2, 0, 1],
	])
	x := [1.0, 2, 3, 4, 5]
	result := matrix_vector_mul(1.0, a, x)
	assert result == expected
}
