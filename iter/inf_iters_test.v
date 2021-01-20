module iter

fn test_counter_1() {
	mut counter := new_count_iter(10, 1)
	assert counter.next() == 10
	assert counter.next() == 11
	assert counter.next() == 12
	assert counter.next() == 13
	assert counter.next() == 14
}

fn test_counter_2() {
	mut counter := new_count_iter(0, 3)
	assert counter.next() == 0
	assert counter.next() == 3
	assert counter.next() == 6
	assert counter.next() == 9
	assert counter.next() == 12
}

fn test_counter_3() {
	mut counter := new_count_iter(3, -1)
	assert counter.next() == 3
	assert counter.next() == 2
	assert counter.next() == 1
	assert counter.next() == 0
	assert counter.next() == -1
	assert counter.next() == -2
}

fn test_counter_4() {
	mut counter := new_count_iter(4, -3)
	assert counter.next() == 4
	assert counter.next() == 1
	assert counter.next() == -2
	assert counter.next() == -5
	assert counter.next() == -8
	assert counter.next() == -11
}

fn test_cycle_1() {
	mut cycler := new_cycle_iter([1., 2., 3.])
	assert cycler.next() == 1
	assert cycler.next() == 2
	assert cycler.next() == 3
	assert cycler.next() == 1
	assert cycler.next() == 2
}

fn test_cycle_2() {
	mut cycler := new_cycle_iter([10., 0., 42., 12.])
	assert cycler.next() == 10
	assert cycler.next() == 0
	assert cycler.next() == 42
	assert cycler.next() == 12
	assert cycler.next() == 10
	assert cycler.next() == 0
}

fn test_repeat() {
	r := new_repeat_iter(3)
	assert r.next() == 3
	assert r.next() == 3
	assert r.next() == 3
}
