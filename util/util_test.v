module util

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
