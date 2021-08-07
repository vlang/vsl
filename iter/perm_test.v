module iter

fn test_permutations_simple_1() {
	data := [1., 2.]
	expected := [[1., 2.], [2., 1.]]
	result := permutations(data, 2)
	assert assert_permutation(expected, result)
}

fn test_permutations_simple_2() {
	data := [1., 2., 3.]
	expected := [[1., 2.], [1., 3.], [2., 1.], [2., 3.], [3., 1.],
		[3., 2.],
	]
	result := permutations(data, 2)
	assert assert_permutation(expected, result)
}

fn test_permutations_simple_3() {
	data := [1., 2., 3., 4.]
	expected := [[1.0, 2.0], [1.0, 3.0], [1.0, 4.0], [2.0, 1.0],
		[2.0, 3.0], [2.0, 4.0], [3.0, 1.0], [3.0, 2.0], [3.0, 4.0],
		[4.0, 1.0], [4.0, 2.0], [4.0, 3.0]]
	result := permutations(data, 2)
	assert assert_permutation(expected, result)
}

// fn test_permutations_simple_4() {
// 	data := [1., 2., 3., 4.]
// 	expected := [
// 		[1.0, 2.0, 3.0],
// 		[1.0, 2.0, 4.0],
// 		[1.0, 3.0, 2.0],
// 		[1.0, 3.0, 4.0],
// 		[1.0, 4.0, 2.0],
// 		[1.0, 4.0, 3.0],
// 		[2.0, 1.0, 3.0],
// 		[2.0, 1.0, 4.0],
// 		[2.0, 3.0, 1.0],
// 		[2.0, 3.0, 4.0],
// 		[2.0, 4.0, 1.0],
// 		[2.0, 4.0, 3.0],
// 		[3.0, 1.0, 2.0],
// 		[3.0, 1.0, 4.0],
// 		[3.0, 2.0, 1.0],
// 		[3.0, 2.0, 4.0],
// 		[3.0, 4.0, 1.0],
// 		[3.0, 4.0, 2.0],
// 		[4.0, 1.0, 2.0],
// 		[4.0, 1.0, 3.0],
// 		[4.0, 2.0, 1.0],
// 		[4.0, 2.0, 3.0],
// 		[4.0, 3.0, 1.0],
// 		[4.0, 3.0, 2.0],
// 	]
// 	result := permutations(data, 3)
// 	assert assert_permutation(expected, result)
// }

fn assert_permutation(a [][]f64, b [][]f64) bool {
	if a.len != b.len {
		return false
	}

	for i, perm in a {
		assert perm == b[i]
	}
	
	return true
}
