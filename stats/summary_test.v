module stats

import math

fn test_summarize_population_statistics() {
	summary := summarize([1.0, 2.0, 3.0, 4.0], 0) or { panic(err) }
	assert summary.count == 4
	assert summary.mean == 2.5
	assert summary.variance == 1.25
	assert summary.stddev == math.sqrt(1.25)
	assert summary.min == 1.0
	assert summary.max == 4.0
}

fn test_summarize_sample_variance_and_large_offset() {
	summary := summarize([1e12 + 1.0, 1e12 + 2.0, 1e12 + 3.0], 1) or { panic(err) }
	assert summary.count == 3
	assert math.abs(summary.mean - (1e12 + 2.0)) < 1e-4
	assert math.abs(summary.variance - 1.0) < 1e-6
	assert math.abs(summary.stddev - 1.0) < 1e-6
}

fn test_summarize_constant_and_single_value_samples() {
	constant := summarize([7.0, 7.0, 7.0], 1) or { panic(err) }
	assert constant.variance == 0.0
	assert constant.stddev == 0.0
	single := summarize([4.5], 0) or { panic(err) }
	assert single.mean == 4.5
	assert single.variance == 0.0
}

fn test_summarize_rejects_empty_invalid_ddof_and_non_finite_values() {
	summarize([]f64{}, 0) or {
		assert err.msg().contains('empty')
		return
	}
	assert false, 'expected empty input to be rejected'
}

fn test_summarize_rejects_bad_ddof() {
	summarize([1.0], 1) or {
		assert err.msg().contains('ddof')
		return
	}
	assert false, 'expected invalid ddof to be rejected'
}

fn test_summarize_rejects_non_finite_values() {
	for values in [[math.nan()], [math.inf(1)], [math.inf(-1)]] {
		summarize(values, 0) or {
			assert err.msg().contains('finite')
			continue
		}
		assert false, 'expected non-finite input to be rejected'
	}
}

fn test_quantile_linear_interpolation_and_endpoints() {
	values := [1.0, 2.0, 3.0, 4.0]
	assert quantile(values, 0.0)! == 1.0
	assert quantile(values, 0.25)! == 1.75
	assert quantile(values, 0.5)! == 2.5
	assert quantile(values, 0.75)! == 3.25
	assert quantile(values, 1.0)! == 4.0
	assert percentile(values, 50.0)! == 2.5
	assert percentile(values, 25.0)! == 1.75
}

fn test_quantile_sorts_a_copy_and_handles_ties() {
	values := [3.0, 1.0, 1.0, 5.0]
	assert quantile(values, 0.5)! == 2.0
	assert values == [3.0, 1.0, 1.0, 5.0]
	assert quantile([7.0], 0.9)! == 7.0
}

fn test_quantile_methods_match_numpy_estimators() {
	values := [1.0, 2.0, 3.0, 4.0]
	methods := [QuantileMethod.inverted_cdf, .averaged_inverted_cdf, .closest_observation,
		.interpolated_inverted_cdf, .hazen, .weibull, .linear, .median_unbiased, .normal_unbiased,
		.lower, .higher, .midpoint, .nearest]
	expected := [1.0, 1.5, 1.0, 1.0, 1.5, 1.25, 1.75, 1.4166666666666667, 1.4375, 1.0, 2.0, 1.5,
		2.0]
	for i, method in methods {
		actual := quantile_with_method(values, 0.25, method)!
		assert math.abs(actual - expected[i]) < 1e-12, '${method}: ${actual} != ${expected[i]}'
		assert quantile_with_method(values, 0.0, method)! == values[0], '${method} q=0'
		assert quantile_with_method(values, 1.0, method)! == values[3], '${method} q=1'
	}
	assert quantile_with_method(values, 0.5, .closest_observation)! == 2.0
	assert quantile_with_method(values, 0.5, .nearest)! == 2.0
	assert quantile_with_method(values, 0.5, .lower)! == 2.0
	assert quantile_with_method(values, 0.5, .higher)! == 3.0
	assert quantile_with_method(values, 0.5, .midpoint)! == 2.5
	assert percentile_with_method(values, 25.0, .hazen)! == 1.5
}

fn test_quantile_methods_reject_invalid_probability_and_samples() {
	for q in [-0.1, 1.1, math.nan(), math.inf(1)] {
		if _ := quantile_with_method([1.0, 2.0], q, .linear) {
			assert false, 'invalid quantiles must fail'
		}
	}
	if _ := quantile_with_method([math.nan(), 2.0], 0.5, .linear) {
		assert false, 'non-finite samples must fail'
	}
	if _ := percentile_with_method([1.0, 2.0], math.nan(), .linear) {
		assert false, 'non-finite percentiles must fail'
	}
}

fn test_quantile_rejects_invalid_inputs() {
	quantile([]f64{}, 0.5) or {
		assert err.msg().contains('empty')
		return
	}
	assert false, 'expected empty input to be rejected'
}

fn test_quantile_rejects_invalid_probability_and_non_finite_samples() {
	for q in [-0.1, 1.1, math.nan(), math.inf(1)] {
		quantile([1.0, 2.0], q) or {
			assert err.msg().contains('q must be finite')
			continue
		}
		assert false, 'expected invalid quantile to be rejected'
	}
	quantile([1.0, math.inf(1)], 0.5) or {
		assert err.msg().contains('finite')
		return
	}
	assert false, 'expected non-finite sample to be rejected'
}

fn test_percentile_rejects_out_of_range_values() {
	for p in [-1.0, 100.1, math.nan(), math.inf(1)] {
		percentile([1.0, 2.0], p) or {
			assert err.msg().contains('p must be finite')
			continue
		}
		assert false, 'expected invalid percentile to be rejected'
	}
}

fn test_weighted_quantile_uses_inverted_cdf_semantics() {
	values := [1.0, 2.0, 3.0, 4.0]
	weights := [1.0, 1.0, 1.0, 7.0]
	assert quantile_weighted(values, weights, 0.0)! == 1.0
	assert quantile_weighted(values, weights, 0.25)! == 3.0
	assert quantile_weighted(values, weights, 0.5)! == 4.0
	assert quantile_weighted(values, weights, 1.0)! == 4.0
	assert percentile_weighted(values, weights, 50.0)! == 4.0
	assert quantile_weighted([1.0, 2.0, 3.0], [0.0, 2.0, 0.0], 0.0)! == 2.0
}

fn test_weighted_quantile_validates_shapes_and_weights() {
	if _ := quantile_weighted([1.0, 2.0], [1.0], 0.5) {
		assert false, 'mismatched value and weight lengths must fail'
	}
	if _ := quantile_weighted([1.0, 2.0], [-1.0, 2.0], 0.5) {
		assert false, 'negative weights must fail'
	}
	if _ := quantile_weighted([1.0, 2.0], [0.0, 0.0], 0.5) {
		assert false, 'zero total weight must fail'
	}
	if _ := quantile_weighted([1.0, 2.0], [math.inf(1), 1.0], 0.5) {
		assert false, 'non-finite weights must fail'
	}
	if _ := quantile_weighted([math.nan(), 2.0], [1.0, 1.0], 0.5) {
		assert false, 'non-finite values must fail'
	}
}

fn test_weighted_quantile_rejects_invalid_probability() {
	if _ := quantile_weighted([1.0], [1.0], 1.1) {
		assert false, 'out-of-range quantile must fail'
	}
	if _ := percentile_weighted([1.0], [1.0], math.nan()) {
		assert false, 'non-finite percentile must fail'
	}
}
