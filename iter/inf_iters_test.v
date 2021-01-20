module iter

fn test_counter_1() {
	mut counter := new_counter_iter(10, 1)
	assert counter.next() == 10
	assert counter.next() == 11
	assert counter.next() == 12
	assert counter.next() == 13
	assert counter.next() == 14
}

fn test_counter_2() {
	mut counter := new_counter_iter(0, 3)
	assert counter.next() == 0
	assert counter.next() == 3
	assert counter.next() == 6
	assert counter.next() == 9
	assert counter.next() == 12
}

fn test_counter_3() {
	mut counter := new_counter_iter(3, -1)
	assert counter.next() == 3
	assert counter.next() == 2
	assert counter.next() == 1
	assert counter.next() == 0
	assert counter.next() == -1
	assert counter.next() == -2
}

fn test_counter_4() {
	mut counter := new_counter_iter(4, -3)
	assert counter.next() == 4
	assert counter.next() == 1
	assert counter.next() == -2
	assert counter.next() == -5
	assert counter.next() == -8
	assert counter.next() == -11
}
