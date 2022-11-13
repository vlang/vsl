module util

import vsl.float.float64

fn test_arange() {
	assert arange(3) == [0, 1, 2]
}

fn test_range() {
	assert range(2, 5) == [2, 3, 4]
	assert range(0, 3) == [0, 1, 2]
	assert range(3, 2) == []int{}
	assert range(1, 1) == []int{}
}

fn test_get_many() {
	assert get_many([1, 2, 3], [0, 2]) == [1, 3]
	assert get_many([1, 2, 3], []int{}) == []int{}
	assert get_many([1, 2, 3], [0, 0, 0]) == [1, 1, 1]
}

fn test_stepped_range() {
	assert stepped_range(0, 30, 5) == [0, 5, 10, 15, 20, 25]
	assert stepped_range(0, 10, 3) == [0, 3, 6, 9]
	assert stepped_range(0, -10, -1) == [0, -1, -2, -3, -4, -5, -6, -7, -8, -9]
	assert stepped_range(0, 10, 0) == []int{}
}

fn test_lin_space() {
	assert float64.arrays_tolerance(lin_space(0, 1, 5), [0.0, 0.25, 0.5, 0.75, 1], 1e-14)
	assert float64.arrays_tolerance(lin_space(0, 1, 6), [0.0, 0.2, 0.4, 0.6, 0.8, 1],
		1e-14)
	assert float64.arrays_tolerance(lin_space(0, 1, 7), [0.0, 0.16666666666666666, 0.3333333333333333,
		0.5, 0.6666666666666666, 0.8333333333333334, 1], 1e-14)
	assert float64.arrays_tolerance(lin_space(0, 1, 8), [0.0, 0.14285714285714285, 0.2857142857142857,
		0.42857142857142855, 0.5714285714285714, 0.7142857142857143, 0.8571428571428571, 1],
		1e-14)
	assert float64.arrays_tolerance(lin_space(0, 1, 9), [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75,
		0.875, 1], 1e-14)
	assert float64.arrays_tolerance(lin_space(0, 1, 10), [0.0, 0.1111111111111111, 0.2222222222222222,
		0.3333333333333333, 0.4444444444444444, 0.5555555555555556, 0.6666666666666666,
		0.7777777777777778, 0.8888888888888888, 1], 1e-14)
	assert float64.arrays_tolerance(lin_space(0, 1, 11), [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7,
		0.8, 0.9, 1], 1e-14)
	assert float64.arrays_tolerance(lin_space(0, 1, 12), [0.0, 0.09090909090909091,
		0.18181818181818182, 0.2727272727272727, 0.36363636363636365, 0.45454545454545453,
		0.5454545454545454, 0.6363636363636364, 0.7272727272727273, 0.8181818181818182,
		0.9090909090909091, 1], 1e-14)
}

fn test_move_ith_to_end() {
	mut a := [1, 2, 3, 4, 5]
	move_ith_to_end(mut a, 2)
	assert a == [1, 2, 4, 5, 3]
	move_ith_to_end(mut a, 0)
	assert a == [2, 4, 5, 3, 1]
	move_ith_to_end(mut a, 4)
	assert a == [2, 4, 5, 3, 1]
}
