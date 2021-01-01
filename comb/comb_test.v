module comb

import vsl.fun

fn test_n_choose_k() {
	assert fun.choose(4, 2) == 6
	assert fun.choose(3, 3) == 1
	assert fun.choose(5, 2) == 10
	assert fun.choose(10, 6) == 210
	assert fun.choose(0, 3) == 0
}

fn test_arange() {
	assert arange(3) == [0, 1, 2]
}

fn test_arange_start_stop() {
	assert arange_start_stop(2, 5) == [2, 3, 4]
	assert arange_start_stop(0, 3) == [0, 1, 2]
	assert arange_start_stop(3, 2) == []int{}
	assert arange_start_stop(1, 1) == []int{}
}

fn test_get_many() {
	assert get_many([1, 2, 3], [0, 2]) == [1, 3]
	assert get_many([1, 2, 3], []int{}) == []int{}
	assert get_many([1, 2, 3], [0, 0, 0]) == [1, 1, 1]
}

// fn test_combinations_str() {
// 	data := 'hi you'.split(' ')
// 	expected := [['hi'], ['you']]
// 	result := combinations(data, 1)
// 	assert expected == result
// }
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
