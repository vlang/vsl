module dist

import math

fn assert_histogram_edges(actual []f64, expected []f64) {
	assert actual.len == expected.len, 'edge count ${actual.len} != ${expected.len}'
	for i, edge in actual {
		assert math.abs(edge - expected[i]) < 1e-12, 'edge ${i}: ${edge} != ${expected[i]}'
	}
}

fn test_histogram_bin_rules_match_numpy_reference_fixtures() {
	values := [1.0, 2, 3, 4]
	rules := [HistogramBinRule.auto, .fd, .doane, .scott, .stone, .rice, .sturges, .sqrt]
	expected := [
		[1.0, 2, 3, 4],
		[1.0, 2.5, 4],
		[1.0, 2, 3, 4],
		[1.0, 2.5, 4],
		[1.0, 4],
		[1.0, 1.75, 2.5, 3.25, 4],
		[1.0, 2, 3, 4],
		[1.0, 2.5, 4],
	]
	for i, rule in rules {
		assert_histogram_edges(histogram_bin_edges(values, rule)!, expected[i])
	}
}

fn test_histogram_bin_rules_match_numpy_for_skewed_samples() {
	values := [0.0, 0, 0, 1, 2, 8, 20]
	rules := [HistogramBinRule.auto, .fd, .doane, .scott, .stone, .rice, .sturges, .sqrt]
	expected := [
		[0.0, 5, 10, 15, 20],
		[0.0, 5, 10, 15, 20],
		[0.0, 3.3333333333333335, 6.666666666666667, 10, 13.333333333333334, 16.666666666666668,
			20],
		[0.0, 10, 20],
		[0.0, 2.2222222222222223, 4.444444444444445, 6.666666666666667, 8.88888888888889,
			11.11111111111111, 13.333333333333334, 15.555555555555557, 17.77777777777778, 20],
		[0.0, 5, 10, 15, 20],
		[0.0, 5, 10, 15, 20],
		[0.0, 6.666666666666667, 13.333333333333334, 20],
	]
	for i, rule in rules {
		edges := histogram_bin_edges(values, rule)!
		assert_histogram_edges(edges, expected[i])
	}
}

fn test_histogram_bin_edges_handle_constants_and_explicit_ranges() {
	rules := [HistogramBinRule.auto, .fd, .doane, .scott, .stone, .rice, .sturges, .sqrt]
	for rule in rules {
		assert_histogram_edges(histogram_bin_edges([5.0, 5, 5], rule)!, [4.5, 5.5])
	}
	assert_histogram_edges(histogram_bin_edges_in_range([0.0, 1, 2, 3, 10], .sturges, 0, 8)!,
		[0.0, 1, 2, 3, 4, 5, 6, 7, 8])
	assert_histogram_edges(histogram_bin_edges_in_range([0.0, 1, 2, 3, 10], .sturges, -2, 8)!,
		[-2.0, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8])
	expected_range_bins := [8, 5, 8, 4, 3, 9, 8, 6]
	for i, rule in rules {
		edges := histogram_bin_edges_in_range([1.0, 2, 3, 4], rule, 0, 8)!
		expected_bins := expected_range_bins[i]
		assert edges.len == expected_bins + 1, '${rule}: expected ${expected_bins} bins for explicit range'
		assert edges[0] == 0.0
		assert edges[edges.len - 1] == 8.0
	}
}

fn test_histogram_bin_edges_non_finite_policy() {
	edges := histogram_bin_edges_with_policy([0.0, 1, 2, math.nan(), math.inf(1), math.inf(-1)], .sturges,
		.omit)!
	assert edges.len == 4
	ranged := histogram_bin_edges_in_range_with_policy([0.0, 1, 2, math.inf(1)], .sturges, 0, 3,
		.omit)!
	assert ranged[0] == 0.0
	assert ranged[ranged.len - 1] == 3.0
	if _ := histogram_bin_edges_with_policy([0.0, math.nan()], .sturges, .propagate) {
		assert false, 'bin-edge selection cannot propagate NaN'
	}
	if _ := histogram_bin_edges_in_range_with_policy([0.0, math.inf(1)], .sturges, 0, 3, .reject) {
		assert false, 'reject policy must reject infinity'
	}
}

fn test_histogram_bin_edges_reject_invalid_samples_and_ranges() {
	if _ := histogram_bin_edges([], .auto) {
		assert false, 'empty samples must be rejected'
	}
	if _ := histogram_bin_edges([1.0, math.nan()], .fd) {
		assert false, 'non-finite samples must be rejected'
	}
	for range in [[1.0, 1.0], [2.0, 1.0], [math.nan(), 2.0], [0.0, math.inf(1)]] {
		if _ := histogram_bin_edges_in_range([0.0, 1], .auto, range[0], range[1]) {
			assert false, 'invalid ranges must be rejected'
		}
	}
	if _ := histogram_bin_edges_in_range([10.0, 20], .auto, 0, 1) {
		assert false, 'ranges without sample values must be rejected'
	}
}
