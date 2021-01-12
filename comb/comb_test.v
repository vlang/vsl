module itertools

fn test_combinations_choose_1() {
	data := [1., 2., 3.]
	expected := [[1.], [2.], [3.]]
	result := combinations(data, 1)
	assert expected == result
}

fn test_combinations_choose_len_data() {
	data := [1., 2., 3.]
	expected := [[1., 2., 3.]]
	result := combinations(data, data.len)
	assert expected == result
}

fn test_combinations_simple_1() {
	data := [1., 2., 3.]
	expected := [[1., 2.], [1., 3.],
		[2., 3.],
	]
	result := combinations(data, 2)
	assert expected == result
}

fn test_combinations_simple_2() {
	data := [4., 5., 6.]
	expected := [[4., 5.], [4., 6.],
		[5., 6.],
	]
	result := combinations(data, 2)
	assert expected == result
}

fn test_combinations_simple_3() {
	data := [1., 0., -1.]
	expected := [[1., 0.], [1., -1.],
		[0., -1.],
	]
	result := combinations(data, 2)
	assert expected == result
}

fn test_combinations_longer() {
	data := [1., 2., 3., 4., 5.]
	expected := [[1., 2.], [1., 3.],
		[1., 4.], [1., 5.], [2., 3.], [2., 4.],
		[2., 5.], [3., 4.], [3., 5.], [4., 5.]]
	result := combinations(data, 2)
	assert expected == result
}

fn test_combinations_with_replacement_choose_1() {
	data := [1., 2., 3.]
	expected := [[1.], [2.], [3.]]
	result := combinations_with_replacement(data, 1)
	assert expected == result
}

fn test_combinations_with_replacement_simple_1() {
	data := [1., 2., 3.]
	expected := [[1., 1.], [1., 2.],
		[1., 3.], [2., 2.], [2., 3.], [3., 3.]]
	result := combinations_with_replacement(data, 2)
	assert expected == result
}

fn test_combinations_with_replacement_longer() {
	data := [1., 2., 3., 4.]
	// This `expected` array made with python's itertools.combinations_with_replacement
	expected := [[1.0, 1.0, 1.0], [1.0, 1.0, 2.0],
		[1.0, 1.0, 3.0], [1.0, 1.0, 4.0], [1.0, 2.0, 2.0],
		[1.0, 2.0, 3.0], [1.0, 2.0, 4.0], [1.0, 3.0, 3.0],
		[1.0, 3.0, 4.0], [1.0, 4.0, 4.0], [2.0, 2.0, 2.0],
		[2.0, 2.0, 3.0], [2.0, 2.0, 4.0], [2.0, 3.0, 3.0],
		[2.0, 3.0, 4.0], [2.0, 4.0, 4.0], [3.0, 3.0, 3.0],
		[3.0, 3.0, 4.0], [3.0, 4.0, 4.0], [4.0, 4.0, 4.0]]
	result := combinations_with_replacement(data, 3)
	assert expected == result
}
