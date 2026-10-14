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

fn test_weighted_histogram_counts_and_density_support_non_uniform_bins() {
	mut hist := WeightedHistogram.new([0.0, 1, 3])
	total_weight := hist.count([0, 0.5, 1, 2.5, 3, -1, 4], [2, 4, 1, 3, 5, 9, 1], true)!
	assert total_weight == 25.0
	assert hist.counts == [6.0, 9.0]
	densities := hist.density(total_weight)!
	assert math.abs(densities[0] - 6.0 / 25.0) < 1e-12
	assert math.abs(densities[1] - 9.0 / 50.0) < 1e-12
	assert math.abs(hist.density_area(total_weight)! - 15.0 / 25.0) < 1e-12

	additional_weight := hist.count([0.5], [2.0], false)!
	assert additional_weight == 2.0
	assert hist.counts == [8.0, 9.0]
}

fn test_weighted_histogram_rejects_invalid_inputs_without_partial_update() {
	mut hist := WeightedHistogram.new([0.0, 1, 2])
	hist.count([0.5], [2.0], true)!
	for weights in [[1.0, -1.0], [1.0, math.nan()], [1.0, math.inf(1)]] {
		if _ := hist.count([0.5, 1.5], weights, false) {
			assert false, 'invalid weights must be rejected'
		}
		assert hist.counts == [2.0, 0.0]
	}
	for values in [[math.nan(), 1.5], [math.inf(1), 1.5], [math.inf(-1), 1.5]] {
		if _ := hist.count(values, [1.0, 1.0], false) {
			assert false, 'non-finite values must be rejected'
		}
		assert hist.counts == [2.0, 0.0]
	}
	if _ := hist.count([0.5], [1.0, 2.0], true) {
		assert false, 'weight length mismatch must be rejected'
	}
	if _ := hist.density(0.0) {
		assert false, 'non-positive total weight must be rejected'
	}
}

fn test_histogram_non_finite_policies_preserve_state_on_error() {
	mut hist := Histogram.new([0.0, 1, 2])
	finite_count := hist.count_with_policy([0.5, math.nan(), math.inf(1), 1.5, 4.0], true, .omit)!
	assert finite_count == 3
	assert hist.counts == [1, 1]
	densities := hist.density(finite_count)!
	assert math.abs(densities[0] - 1.0 / 3.0) < 1e-12
	assert math.abs(densities[1] - 1.0 / 3.0) < 1e-12
	if _ := hist.count_with_policy([0.5, math.inf(-1)], false, .reject) {
		assert false, 'reject must fail on infinities'
	}
	assert hist.counts == [1, 1]
	if _ := hist.count_with_policy([0.5, math.nan()], false, .propagate) {
		assert false, 'integer counts cannot propagate NaN'
	}
	assert hist.counts == [1, 1]
}

fn test_weighted_histogram_non_finite_policies() {
	for invalid in [math.nan(), math.inf(1), math.inf(-1)] {
		mut hist := WeightedHistogram.new([0.0, 1, 2])
		total := hist.count_with_policy([0.5, invalid, 1.5], [2.0, 10, 3], true, .omit)!
		assert total == 5.0
		assert hist.counts == [2.0, 3.0]
		if _ := hist.count_with_policy([0.5, invalid], [1.0, 2], false, .reject) {
			assert false, 'reject policy must reject non-finite observations'
		}
		if _ := hist.count_with_policy([0.5, invalid], [1.0, 2], false, .propagate) {
			assert false, 'weighted counts cannot propagate non-finite observations'
		}
		assert hist.counts == [2.0, 3.0]
	}
	for invalid_weight in [math.nan(), math.inf(1), math.inf(-1)] {
		mut hist := WeightedHistogram.new([0.0, 1, 2])
		total := hist.count_with_policy([0.5, 1.5], [2.0, invalid_weight], true, .omit)!
		assert total == 2.0
		assert hist.counts == [2.0, 0.0]
		if _ := hist.count_with_policy([0.5], [invalid_weight], false, .reject) {
			assert false, 'reject policy must reject non-finite weights'
		}
		if _ := hist.count_with_policy([0.5], [invalid_weight], false, .propagate) {
			assert false, 'weighted counts cannot propagate non-finite weights'
		}
	}
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
