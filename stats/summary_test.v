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
