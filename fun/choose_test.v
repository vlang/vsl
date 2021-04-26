module fun

fn test_n_choose_k() {
	assert choose(4, 2) == 6
	assert choose(3, 3) == 1
	assert choose(5, 2) == 10
	assert choose(10, 6) == 210
	assert choose(0, 3) == 0
}
