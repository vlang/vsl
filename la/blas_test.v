module la

fn test_mat_vec_mul() {
	expected := [8.0, 45, -3, 3, 19]
	a := matrix_deep2([
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
