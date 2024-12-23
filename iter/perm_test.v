module iter

fn test_permutations_simple_1() {
	data := [1.0, 2.0]
	expected := [[1.0, 2.0], [2.0, 1.0]]
	result := permutations(data, 2)
	assert assert_permutation(expected, result)
}

fn test_permutations_simple_2() {
	data := [1.0, 2.0, 3.0]
	expected := [[1.0, 2.0], [1.0, 3.0], [2.0, 1.0], [2.0, 3.0],
		[3.0, 1.0], [3.0, 2.0]]
	result := permutations(data, 2)
	assert assert_permutation(expected, result)
}

fn test_permutations_simple_3() {
	data := [1.0, 2.0, 3.0, 4.0]
	expected := [[1.0, 2.0], [1.0, 3.0], [1.0, 4.0], [2.0, 1.0],
		[2.0, 3.0], [2.0, 4.0], [3.0, 1.0], [3.0, 2.0], [3.0, 4.0],
		[4.0, 1.0], [4.0, 2.0], [4.0, 3.0]]
	result := permutations(data, 2)
	assert assert_permutation(expected, result)
}

fn test_permutations_simple_4() {
	data := [1.0, 2.0, 3.0, 4.0]
	expected := [
		[1.0, 2.0, 3.0],
		[1.0, 2.0, 4.0],
		[1.0, 3.0, 2.0],
		[1.0, 3.0, 4.0],
		[1.0, 4.0, 2.0],
		[1.0, 4.0, 3.0],
		[2.0, 1.0, 3.0],
		[2.0, 1.0, 4.0],
		[2.0, 3.0, 1.0],
		[2.0, 3.0, 4.0],
		[2.0, 4.0, 1.0],
		[2.0, 4.0, 3.0],
		[3.0, 1.0, 2.0],
		[3.0, 1.0, 4.0],
		[3.0, 2.0, 1.0],
		[3.0, 2.0, 4.0],
		[3.0, 4.0, 1.0],
		[3.0, 4.0, 2.0],
		[4.0, 1.0, 2.0],
		[4.0, 1.0, 3.0],
		[4.0, 2.0, 1.0],
		[4.0, 2.0, 3.0],
		[4.0, 3.0, 1.0],
		[4.0, 3.0, 2.0],
	]
	result := permutations(data, 3)
	assert assert_permutation(expected, result)
}

fn test_permutations_simple_5() {
	data := [5.0, 6.0, 7.0]
	expected := [[5.0, 6.0, 7.0], [5.0, 7.0, 6.0], [6.0, 5.0, 7.0],
		[6.0, 7.0, 5.0], [7.0, 5.0, 6.0], [7.0, 6.0, 5.0]]
	result := permutations(data, 3)
	assert assert_permutation(expected, result)
}

fn test_permutations_generic_type_string() {
	data := ['a', 'b', 'c']
	expected := [['a', 'b'], ['a', 'c'], ['b', 'a'], ['b', 'c'],
		['c', 'a'], ['c', 'b']]
	result := permutations(data, 2)
	assert assert_permutation(expected, result)
}

fn test_permutations_generic_type_int() {
	data := [1, 2, 3]
	expected := [[1, 2], [1, 3], [2, 1], [2, 3], [3, 1], [3, 2]]
	result := permutations(data, 2)
	assert assert_permutation(expected, result)
}

fn assert_permutation[T](a [][]T, b [][]T) bool {
	if a.len != b.len {
		return false
	}

	for i, perm in a {
		assert perm == b[i]
	}

	return true
}
