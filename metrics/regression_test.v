module metrics

import math

fn test_mean_squared_error() {
	y_true := [1.0, 2.0, 3.0, 4.0]
	y_pred := [1.0, 2.0, 3.0, 4.0]

	mse := mean_squared_error(y_true, y_pred)!

	assert math.abs(mse) < 1e-10
}

fn test_mean_squared_error_nonzero() {
	y_true := [1.0, 2.0, 3.0]
	y_pred := [2.0, 2.0, 2.0]

	mse := mean_squared_error(y_true, y_pred)!

	// (1-2)^2 + (2-2)^2 + (3-2)^2 = 1 + 0 + 1 = 2
	// MSE = 2/3
	assert math.abs(mse - 2.0 / 3.0) < 1e-10
}

fn test_root_mean_squared_error() {
	y_true := [1.0, 2.0, 3.0]
	y_pred := [2.0, 2.0, 2.0]

	rmse := root_mean_squared_error(y_true, y_pred)!

	expected := math.sqrt(2.0 / 3.0)
	assert math.abs(rmse - expected) < 1e-10
}

fn test_mean_absolute_error() {
	y_true := [1.0, 2.0, 3.0]
	y_pred := [2.0, 2.0, 2.0]

	mae := mean_absolute_error(y_true, y_pred)!

	// |1-2| + |2-2| + |3-2| = 1 + 0 + 1 = 2
	// MAE = 2/3
	assert math.abs(mae - 2.0 / 3.0) < 1e-10
}

fn test_r2_score_perfect() {
	y_true := [1.0, 2.0, 3.0, 4.0]
	y_pred := [1.0, 2.0, 3.0, 4.0]

	r2 := r2_score(y_true, y_pred)!

	assert math.abs(r2 - 1.0) < 1e-10
}

fn test_r2_score_mean_prediction() {
	y_true := [1.0, 2.0, 3.0, 4.0, 5.0]
	y_pred := [3.0, 3.0, 3.0, 3.0, 3.0] // predict mean

	r2 := r2_score(y_true, y_pred)!

	// Predicting mean gives R² = 0
	assert math.abs(r2) < 1e-10
}

fn test_r2_score_negative() {
	y_true := [1.0, 2.0, 3.0]
	y_pred := [10.0, 10.0, 10.0] // bad predictions

	r2 := r2_score(y_true, y_pred)!

	// Can be negative for bad predictions
	assert r2 < 0
}

fn test_mean_absolute_percentage_error() {
	y_true := [100.0, 200.0, 300.0]
	y_pred := [110.0, 200.0, 270.0]

	mape := mean_absolute_percentage_error(y_true, y_pred)!

	// |100-110|/100 + |200-200|/200 + |300-270|/300 = 0.1 + 0 + 0.1 = 0.2
	// MAPE = 0.2/3 * 100 = 6.67%
	expected := (10.0 / 100.0 + 0.0 + 30.0 / 300.0) / 3.0 * 100.0
	assert math.abs(mape - expected) < 1e-10
}

fn test_explained_variance_score() {
	y_true := [1.0, 2.0, 3.0, 4.0]
	y_pred := [1.0, 2.0, 3.0, 4.0]

	evs := explained_variance_score(y_true, y_pred)!

	assert math.abs(evs - 1.0) < 1e-10
}

fn test_max_error() {
	y_true := [1.0, 2.0, 3.0]
	y_pred := [1.5, 2.0, 5.0]

	max_err := max_error(y_true, y_pred)!

	// Max error is |3-5| = 2
	assert math.abs(max_err - 2.0) < 1e-10
}

fn test_median_absolute_error() {
	y_true := [1.0, 2.0, 3.0, 4.0, 5.0]
	y_pred := [1.0, 3.0, 3.0, 3.0, 5.0]

	med_err := median_absolute_error(y_true, y_pred)!

	// Errors: 0, 1, 0, 1, 0 -> sorted: 0, 0, 0, 1, 1 -> median = 0
	assert math.abs(med_err) < 1e-10
}

fn test_median_absolute_error_even() {
	y_true := [1.0, 2.0, 3.0, 4.0]
	y_pred := [2.0, 2.0, 2.0, 2.0]

	med_err := median_absolute_error(y_true, y_pred)!

	// Errors: 1, 0, 1, 2 -> sorted: 0, 1, 1, 2 -> median = (1+1)/2 = 1
	assert math.abs(med_err - 1.0) < 1e-10
}

fn test_mean_squared_log_error() {
	y_true := [1.0, 2.0, 3.0]
	y_pred := [1.0, 2.0, 3.0]

	msle := mean_squared_log_error(y_true, y_pred)!

	assert math.abs(msle) < 1e-10
}

fn test_mean_squared_log_error_negative() {
	y_true := [-1.0, 2.0]
	y_pred := [1.0, 2.0]

	if _ := mean_squared_log_error(y_true, y_pred) {
		assert false, 'should have returned error for negative values'
	}
}

fn test_regression_metrics_length_mismatch() {
	y_true := [1.0, 2.0]
	y_pred := [1.0]

	if _ := mean_squared_error(y_true, y_pred) {
		assert false, 'should have returned error'
	}
}

fn test_regression_metrics_empty() {
	y_true := []f64{}
	y_pred := []f64{}

	if _ := r2_score(y_true, y_pred) {
		assert false, 'should have returned error for empty arrays'
	}
}
