module dist

import math

fn test_hist() {
	lims := [0.0, 1, 2, 3, 4, 5]
	mut hist := Histogram.new(lims)

	mut idx := hist.find_bin(-3.3)!
	assert idx == -1

	idx = hist.find_bin(7.0)!
	assert idx == -1

	for i, x in lims {
		idx = hist.find_bin(x)!
		if i < lims.len - 1 {
			assert idx == i
		} else {
			assert idx == i - 1
		}
	}
	assert hist.find_bin(5.1)! == -1

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

	expected := [5, 8, 2, 2, 4]
	assert hist.counts == expected

	labels := hist.gen_labels('%g')!
	assert labels[0] == '[0,1)'
	assert labels[4] == '[4,5]'
}

fn test_histogram_density_supports_non_uniform_bins() {
	mut hist := Histogram.new([0.0, 1, 3])
	hist.count([0, 0.5, 1, 2.5, 3, -1, 4], true)!

	densities := hist.density(7)!
	assert math.abs(densities[0] - 2.0 / 7.0) < 1e-12
	assert math.abs(densities[1] - 3.0 / 14.0) < 1e-12
	assert math.abs(hist.density_area(7)! - 5.0 / 7.0) < 1e-12
}

fn test_histogram_rejects_invalid_edges_and_nan_samples() {
	mut repeated := Histogram.new([0.0, 1, 1])
	if _ := repeated.find_bin(0.5) {
		assert false
	}
	mut non_finite := Histogram.new([0.0, math.inf(1)])
	if _ := non_finite.find_bin(0.5) {
		assert false
	}
	mut hist := Histogram.new([0.0, 1])
	if _ := hist.find_bin(math.nan()) {
		assert false
	}
	if _ := hist.count([0.5, math.nan()], true) {
		assert false
	}
	assert hist.counts.len == 0
}
