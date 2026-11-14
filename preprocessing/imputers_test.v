module preprocessing

import math

fn test_simple_imputer_mean_fits_training_data_and_reuses_statistics() ! {
	missing := math.nan()
	training := [[1.0, missing], [3.0, 4.0], [missing, 6.0]]
	mut imputer := SimpleImputer.new(.mean, 0.0)

	filled_training := imputer.fit_transform(training)!
	assert imputer.statistics_ == [2.0, 5.0]
	assert filled_training == [[1.0, 5.0], [3.0, 4.0], [2.0, 6.0]]

	inference := imputer.transform([[missing, 10.0]])!
	assert inference == [[2.0, 10.0]]
	assert imputer.statistics_ == [2.0, 5.0]
}

fn test_simple_imputer_median_uses_middle_non_missing_values() ! {
	missing := math.nan()
	data := [[1.0, 10.0], [missing, 2.0], [9.0, 8.0], [3.0, missing]]
	mut imputer := SimpleImputer.new(.median, 0.0)

	result := imputer.fit_transform(data)!
	assert imputer.statistics_ == [3.0, 8.0]
	assert result == [[1.0, 10.0], [3.0, 2.0], [9.0, 8.0], [3.0, 8.0]]
}

fn test_simple_imputer_median_handles_even_samples_and_extremes() ! {
	mut imputer := SimpleImputer.new(.median, 0.0)
	imputer.fit([[1e308], [1.7e308]])!
	assert math.abs(imputer.statistics_[0] / 1.35e308 - 1.0) < 1e-15
}

fn test_simple_imputer_constant_fills_all_missing_features() ! {
	missing := math.nan()
	data := [[missing, 1.0], [missing, missing]]
	mut imputer := SimpleImputer.new(.constant, -2.5)

	result := imputer.fit_transform(data)!
	assert imputer.statistics_ == [-2.5, -2.5]
	assert result == [[-2.5, 1.0], [-2.5, -2.5]]
}

fn test_simple_imputer_validates_training_and_inference_shapes() ! {
	missing := math.nan()
	mut imputer := SimpleImputer.new(.mean, 0.0)

	if _ := imputer.fit([]) {
		assert false, 'fitting on empty data must fail'
	} else {
		assert err.msg().contains('empty data')
	}
	if _ := imputer.fit([[1.0, 2.0], [3.0]]) {
		assert false, 'ragged training rows must fail'
	} else {
		assert err.msg().contains('row 1')
	}
	if _ := imputer.fit([[missing]]) {
		assert false, 'mean imputation must reject an all-missing feature'
	} else {
		assert err.msg().contains('only missing values')
	}

	imputer.fit([[1.0, 2.0]])!
	if _ := imputer.transform([[1.0]]) {
		assert false, 'inference feature count must match training'
	} else {
		assert err.msg().contains('expected 2 features')
	}
	if _ := imputer.transform([[1.0, 2.0], [3.0]]) {
		assert false, 'ragged inference rows must fail'
	} else {
		assert err.msg().contains('row 1')
	}
	assert imputer.transform([])!.len == 0
}

fn test_simple_imputer_rejects_nan_constant_fill_value() {
	mut imputer := SimpleImputer.new(.constant, math.nan())
	if _ := imputer.fit([[1.0]]) {
		assert false, 'a NaN fill value must not leave missing values unresolved'
	} else {
		assert err.msg().contains('cannot be NaN')
	}
}

fn test_simple_imputer_mean_avoids_overflow_for_large_finite_values() ! {
	mut imputer := SimpleImputer.new(.mean, 0.0)
	imputer.fit([[1e308], [1e308]])!
	assert imputer.statistics_[0] == 1e308
}
