module preprocessing

import math

fn test_variance_threshold_selects_training_columns_and_names() ! {
	training := [[1.0, 7.0, 2.0], [3.0, 7.0, 2.0], [5.0, 7.0, 4.0]]
	mut selector := VarianceThreshold.new(0.5)

	selected := selector.fit_transform(training)!
	assert math.abs(selector.variances_[0] - 8.0 / 3.0) < 1e-12
	assert selector.variances_[1] == 0.0
	assert math.abs(selector.variances_[2] - 8.0 / 9.0) < 1e-12
	assert selector.get_support()! == [0, 2]
	assert selector.get_feature_names_out(['signal', 'constant', 'weak'])! == ['signal', 'weak']
	assert selected == [[1.0, 2.0], [3.0, 2.0], [5.0, 4.0]]
}

fn test_variance_threshold_reuses_fit_state_for_inference_and_pipeline() ! {
	training := [[1.0, 8.0], [3.0, 8.0], [5.0, 8.0]]
	mut pipeline := Pipeline.new([
		PipelineStep{
			name:        'select'
			transformer: VarianceThreshold.new(0.0)
		},
	])!
	assert pipeline.fit_transform(training, ['signal', 'constant'])! == [[1.0], [3.0], [5.0]]
	assert pipeline.get_feature_names_out()! == ['signal']
	assert pipeline.transform([[20.0, 1000.0]])! == [[20.0]]
}

fn test_variance_threshold_handles_large_offsets_and_preserves_failed_fit() ! {
	base := 1_000_000_000_000_000.0
	mut selector := VarianceThreshold.new(0.0)
	selector.fit([[base], [base + 1.0], [base + 2.0]])!
	assert math.abs(selector.variances_[0] - 2.0 / 3.0) < 1e-12
	assert selector.get_support()! == [0]

	if _ := selector.fit([[1.0, 2.0]]) {
		assert false, 'a refit with a different width must fail'
	}
	assert selector.get_support()! == [0]
	assert math.abs(selector.variances_[0] - 2.0 / 3.0) < 1e-12
}

fn test_variance_threshold_rejects_invalid_or_unfitted_inputs() {
	mut unfitted := VarianceThreshold.new(0.0)
	if _ := unfitted.transform([[1.0]]) {
		assert false, 'transform before fit must fail'
	} else {
		assert err.msg().contains('must be fitted')
	}

	for threshold in [-1.0, math.nan(), math.inf(1)] {
		mut selector := VarianceThreshold.new(threshold)
		if _ := selector.fit([[1.0], [2.0]]) {
			assert false, 'invalid thresholds must fail'
		} else {
			assert err.msg().contains('finite and non-negative')
		}
	}
}

fn test_variance_threshold_rejects_empty_non_finite_and_all_filtered_data() {
	mut selector := VarianceThreshold.new(0.0)
	if _ := selector.fit([]) {
		assert false, 'empty training data must fail'
	} else {
		assert err.msg().contains('empty data')
	}
	if _ := selector.fit([[1.0], [math.nan()]]) {
		assert false, 'non-finite training values must fail'
	} else {
		assert err.msg().contains('non-finite')
	}
	if _ := selector.fit([[math.max_f64], [-math.max_f64]]) {
		assert false, 'unrepresentable variances must fail'
	} else {
		assert err.msg().contains('variance is not finite')
	}
	mut all_filtered := VarianceThreshold.new(1.0)
	if _ := all_filtered.fit([[1.0, 2.0], [1.0, 4.0]]) {
		assert false, 'a threshold that removes all features must fail'
	} else {
		assert err.msg().contains('removed all features')
	}
}

fn test_variance_threshold_validates_transform_width_and_feature_names() ! {
	mut selector := VarianceThreshold.new(0.0)
	selector.fit([[1.0, 2.0], [2.0, 2.0]])!

	if _ := selector.transform([[1.0]]) {
		assert false, 'inference width must match training width'
	} else {
		assert err.msg().contains('expected 2 features')
	}
	if _ := selector.get_feature_names_out(['only_one_name']) {
		assert false, 'feature name width must match training width'
	} else {
		assert err.msg().contains('expected 2 feature names')
	}
}
