module ml

import math

fn test_lasso_basic() {
	// Simple linear data: y = 2*x + 1
	x_data := [[1.0], [2.0], [3.0], [4.0], [5.0]]
	y_data := [3.0, 5.0, 7.0, 9.0, 11.0]

	mut data := Data.from_raw_xy_sep[f64](x_data, y_data)!

	mut model := Lasso.new(mut data, 'lasso_test', 0.01)
	model.train()

	// Should fit reasonably well
	pred := model.predict([3.0])
	assert math.abs(pred - 7.0) < 1.0
}

fn test_lasso_sparsity() {
	// Create data where some features are irrelevant
	// y = 2*x1 + 0*x2 + 0*x3
	x_data := [[1.0, 0.5, 0.3], [2.0, 0.8, 0.1], [3.0, 0.2, 0.9], [4.0, 0.6, 0.4], [5.0, 0.1, 0.7]]
	y_data := [2.0, 4.0, 6.0, 8.0, 10.0]

	mut data := Data.from_raw_xy_sep[f64](x_data, y_data)!

	mut model := Lasso.new(mut data, 'lasso_sparse', 0.01) // Lower alpha for this test
	model.max_iter = 5000
	model.train()

	// Model should produce reasonable predictions
	pred := model.predict([3.0, 0.5, 0.5])
	assert math.abs(pred - 6.0) < 2.0
}

fn test_lasso_high_regularization() {
	x_data := [[1.0], [2.0], [3.0], [4.0], [5.0]]
	y_data := [1.0, 2.0, 3.0, 4.0, 5.0]

	mut data := Data.from_raw_xy_sep[f64](x_data, y_data)!

	// Very high regularization should drive coefficients to zero
	mut model := Lasso.new(mut data, 'lasso_high_alpha', 100.0)
	model.train()

	assert math.abs(model.coef_[0]) < 0.5
}

fn test_elasticnet_basic() {
	x_data := [[1.0], [2.0], [3.0], [4.0], [5.0]]
	y_data := [3.0, 5.0, 7.0, 9.0, 11.0]

	mut data := Data.from_raw_xy_sep[f64](x_data, y_data)!

	mut model := ElasticNet.new(mut data, 'elasticnet_test', 0.01, 0.5)
	model.train()

	pred := model.predict([3.0])
	assert math.abs(pred - 7.0) < 1.0
}

fn test_elasticnet_l1_ratio_extremes() {
	x_data := [[1.0], [2.0], [3.0], [4.0], [5.0]]
	y_data := [1.0, 2.0, 3.0, 4.0, 5.0]

	mut data1 := Data.from_raw_xy_sep[f64](x_data, y_data)!
	mut data2 := Data.from_raw_xy_sep[f64](x_data, y_data)!

	// l1_ratio = 1.0 should behave like Lasso
	mut en_lasso := ElasticNet.new(mut data1, 'en_lasso', 0.1, 1.0)
	en_lasso.train()

	// l1_ratio = 0.0 should behave like Ridge
	mut en_ridge := ElasticNet.new(mut data2, 'en_ridge', 0.1, 0.0)
	en_ridge.train()

	// Both should produce reasonable predictions
	assert math.abs(en_lasso.predict([3.0]) - 3.0) < 1.0
	assert math.abs(en_ridge.predict([3.0]) - 3.0) < 1.0
}

fn test_ridge_basic() {
	x_data := [[1.0], [2.0], [3.0], [4.0], [5.0]]
	y_data := [3.0, 5.0, 7.0, 9.0, 11.0]

	mut data := Data.from_raw_xy_sep[f64](x_data, y_data)!

	mut model := Ridge.new(mut data, 'ridge_test', 0.1)
	model.train()

	pred := model.predict([3.0])
	assert math.abs(pred - 7.0) < 0.5
}

fn test_lasso_multivariate() {
	// y = 1*x1 + 2*x2 + 3
	x_data := [[1.0, 1.0], [2.0, 1.0], [1.0, 2.0], [2.0, 2.0], [3.0, 1.0]]
	y_data := [6.0, 7.0, 8.0, 9.0, 8.0]

	mut data := Data.from_raw_xy_sep[f64](x_data, y_data)!

	mut model := Lasso.new(mut data, 'lasso_multi', 0.01)
	model.train()

	// Should have reasonable predictions
	pred := model.predict([2.0, 2.0])
	assert math.abs(pred - 9.0) < 2.0
}

fn test_model_coefficients() {
	x_data := [[1.0], [2.0], [3.0], [4.0], [5.0]]
	y_data := [2.0, 4.0, 6.0, 8.0, 10.0]

	mut data := Data.from_raw_xy_sep[f64](x_data, y_data)!

	mut model := Lasso.new(mut data, 'coef_test', 0.0001) // Very low regularization
	model.max_iter = 5000
	model.train()

	// Should learn approximately coef = 2, intercept = 0
	assert model.coef_.len == 1
	// Predictions should be close to expected
	pred := model.predict([3.0])
	assert math.abs(pred - 6.0) < 1.0
}

fn test_lasso_sample_weights_match_duplicated_observations() {
	mut weighted_data := Data.from_raw_xy_sep[f64]([[0.0], [1.0], [2.0]], [1.0, 2.0, 10.0])!
	mut duplicated_data := Data.from_raw_xy_sep[f64]([[0.0], [1.0], [1.0]], [1.0, 2.0, 2.0])!

	mut weighted := Lasso.new(mut weighted_data, 'weighted_lasso', 0.25)
	mut duplicated := Lasso.new(mut duplicated_data, 'duplicated_lasso', 0.25)
	weighted.train_with_sample_weights([1.0, 2.0, 0.0])!
	duplicated.train()

	assert weighted.coef_.len == duplicated.coef_.len
	assert math.abs(weighted.coef_[0] - duplicated.coef_[0]) < 1e-12
	assert math.abs(weighted.intercept_ - duplicated.intercept_) < 1e-12
	assert math.abs(weighted.predict([1.5]) - duplicated.predict([1.5])) < 1e-12
}

fn test_lasso_zero_weight_samples_do_not_affect_centered_residuals() {
	mut data := Data.from_raw_xy_sep[f64]([[0.0], [1.0]], [0.0, 1.0])!
	mut model := Lasso.new(mut data, 'zero_weight_lasso', 0.25)
	data.y = [-1e308, 1e308]

	model.train_with_sample_weights([1.0, 0.0])!

	assert model.coef_[0] == 0.0
	assert model.intercept_ == -1e308
	assert model.predict([0.0]) == -1e308
}

fn test_lasso_centers_features_when_fitting_intercept() {
	mut regular_data := Data.from_raw_xy_sep[f64]([[2.0], [4.0], [6.0]], [5.0, 9.0, 13.0])!
	mut weighted_data := Data.from_raw_xy_sep[f64]([[2.0], [4.0], [6.0]], [5.0, 9.0, 13.0])!

	mut regular := Lasso.new(mut regular_data, 'centered_lasso', 0.0)
	mut weighted := Lasso.new(mut weighted_data, 'centered_weighted_lasso', 0.0)
	regular.train()
	weighted.train_with_sample_weights([]f64{})!

	assert math.abs(regular.coef_[0] - 2.0) < 1e-12
	assert math.abs(regular.intercept_ - 1.0) < 1e-12
	assert math.abs(weighted.coef_[0] - 2.0) < 1e-12
	assert math.abs(weighted.intercept_ - 1.0) < 1e-12
}

fn test_lasso_empty_sample_weights_preserve_unit_weight_behavior() {
	mut regular_data := Data.from_raw_xy_sep[f64]([[0.0], [1.0], [2.0]], [1.0, 2.0, 4.0])!
	mut weighted_data := Data.from_raw_xy_sep[f64]([[0.0], [1.0], [2.0]], [1.0, 2.0, 4.0])!

	mut regular := Lasso.new(mut regular_data, 'regular_lasso', 0.1)
	mut weighted := Lasso.new(mut weighted_data, 'unit_weight_lasso', 0.1)
	regular.train()
	weighted.train_with_sample_weights([]f64{})!

	assert math.abs(regular.coef_[0] - weighted.coef_[0]) < 1e-12
	assert math.abs(regular.intercept_ - weighted.intercept_) < 1e-12
}

fn test_lasso_failed_weighted_refit_preserves_fitted_model() {
	mut data := Data.from_raw_xy_sep[f64]([[2.0], [4.0], [6.0]], [5.0, 9.0, 13.0])!
	mut model := Lasso.new(mut data, 'atomic_weighted_lasso', 0.1)
	model.train()

	previous_coefficient := model.coef_[0]
	previous_intercept := model.intercept_
	previous_prediction := model.predict([3.0])
	data.y = [-1e308, 0.0, 1e308]
	model.train_with_sample_weights([1.0, 1.0, 1.0]) or {
		assert math.abs(model.coef_[0] - previous_coefficient) < 1e-12
		assert math.abs(model.intercept_ - previous_intercept) < 1e-12
		assert math.abs(model.predict([3.0]) - previous_prediction) < 1e-12
		assert model.fitted
		return
	}
	assert false, 'expected overflowing coordinate products to fail'
}

fn test_lasso_sample_weights_reject_invalid_values() {
	assert lasso_rejects_sample_weights([1.0])
	assert lasso_rejects_sample_weights([1.0, -1.0, 1.0])
	assert lasso_rejects_sample_weights([1.0, math.nan(), 1.0])
	assert lasso_rejects_sample_weights([1.0, math.inf(1), 1.0])
	assert lasso_rejects_sample_weights([0.0, 0.0, 0.0])
}

fn lasso_rejects_sample_weights(sample_weights []f64) bool {
	mut data := Data.from_raw_xy_sep[f64]([[0.0], [1.0], [2.0]], [1.0, 2.0, 4.0]) or {
		panic(err)
	}
	mut model := Lasso.new(mut data, 'invalid_weight_lasso', 0.1)
	model.train_with_sample_weights(sample_weights) or { return true }
	return false
}
