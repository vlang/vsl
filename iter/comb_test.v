module iter

fn test_combinations_choose_1() {
	data := [1.0, 2.0, 3.0]
	expected := [[1.0], [2.0], [3.0]]
	result := combinations(data, 1)
	assert expected == result
}

fn test_combinations_choose_len_data() {
	data := [1.0, 2.0, 3.0]
	expected := [[1.0, 2.0, 3.0]]
	result := combinations(data, data.len)
	assert expected == result
}

fn test_combinations_simple_1() {
	data := [1.0, 2.0, 3.0]
	expected := [[1.0, 2.0], [1.0, 3.0], [2.0, 3.0]]
	result := combinations(data, 2)
	assert expected == result
}

fn test_combinations_simple_2() {
	data := [4.0, 5.0, 6.0]
	expected := [[4.0, 5.0], [4.0, 6.0], [5.0, 6.0]]
	result := combinations(data, 2)
	assert expected == result
}

fn test_combinations_simple_3() {
	data := [1.0, 0.0, -1.0]
	expected := [[1.0, 0.0], [1.0, -1.0], [0.0, -1.0]]
	result := combinations(data, 2)
	assert expected == result
}

fn test_combinations_longer() {
	data := [1.0, 2.0, 3.0, 4.0, 5.0]
	expected := [[1.0, 2.0], [1.0, 3.0], [1.0, 4.0], [1.0, 5.0],
		[2.0, 3.0], [2.0, 4.0], [2.0, 5.0], [3.0, 4.0], [3.0, 5.0],
		[4.0, 5.0]]
	result := combinations(data, 2)
	assert expected == result
}

fn test_combinations_with_replacement_choose_1() {
	data := [1.0, 2.0, 3.0]
	expected := [[1.0], [2.0], [3.0]]
	result := combinations_with_replacement(data, 1)
	assert expected == result
}

fn test_combinations_with_replacement_simple_1() {
	data := [1.0, 2.0, 3.0]
	expected := [[1.0, 1.0], [1.0, 2.0], [1.0, 3.0], [2.0, 2.0],
		[2.0, 3.0], [3.0, 3.0]]
	result := combinations_with_replacement(data, 2)
	assert expected == result
}

fn test_combinations_with_replacement_longer() {
	data := [1.0, 2.0, 3.0, 4.0]
	// This `expected` array made with python's itertools.combinations_with_replacement
	expected := [[1.0, 1.0, 1.0], [1.0, 1.0, 2.0], [1.0, 1.0, 3.0],
		[1.0, 1.0, 4.0], [1.0, 2.0, 2.0], [1.0, 2.0, 3.0], [1.0, 2.0, 4.0],
		[1.0, 3.0, 3.0], [1.0, 3.0, 4.0], [1.0, 4.0, 4.0], [2.0, 2.0, 2.0],
		[2.0, 2.0, 3.0], [2.0, 2.0, 4.0], [2.0, 3.0, 3.0], [2.0, 3.0, 4.0],
		[2.0, 4.0, 4.0], [3.0, 3.0, 3.0], [3.0, 3.0, 4.0], [3.0, 4.0, 4.0],
		[4.0, 4.0, 4.0]]
	result := combinations_with_replacement(data, 3)
	assert expected == result
}
