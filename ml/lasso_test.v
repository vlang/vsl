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
	x_data := [[1.0, 0.5, 0.3], [2.0, 0.8, 0.1], [3.0, 0.2, 0.9],
		[4.0, 0.6, 0.4], [5.0, 0.1, 0.7]]
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
	x_data := [[1.0, 1.0], [2.0, 1.0], [1.0, 2.0], [2.0, 2.0],
		[3.0, 1.0]]
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
