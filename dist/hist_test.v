module dist

fn test_hist() {
	lims := [0.0, 1, 2, 3, 4, 5]
	mut hist := new_histogram(lims)

	mut idx := hist.find_bin(-3.3)!
	assert idx == -1

	idx = hist.find_bin(7.0)!
	assert idx == -1

	for i, x in lims {
		idx = hist.find_bin(x)!
		if i < lims.len - 1 {
			assert idx == i
		} else {
			assert idx == -1
		}
	}

	idx = hist.find_bin(0.5)!
	assert idx == 0

	idx = hist.find_bin(1.5)!
	assert idx == 1

	idx = hist.find_bin(2.5)!
	assert idx == 2

	idx = hist.find_bin(3.99999999999999)!
	assert idx == 3

	idx = hist.find_bin(4.999999)!
	assert idx == 4

	hist.count([
		0.0,
		0.1,
		0.2,
		0.3,
		0.9,
		1,
		1,
		1,
		1.2,
		1.3,
		1.4,
		1.5,
		1.99,
		2,
		2.5,
		3,
		3.5,
		4.1,
		4.5,
		4.9,
		-3,
		-2,
		-1,
		5,
		6,
		7,
		8,
	], true)!

	expected := [5, 8, 2, 2, 3]
	assert hist.counts == expected

	labels := hist.gen_labels('%g')!
}
