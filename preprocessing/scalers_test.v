module preprocessing

import math

fn test_standard_scaler_basic() {
	data := [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]

	mut scaler := StandardScaler.new()
	scaler.fit(data)!

	assert scaler.fitted == true
	assert scaler.n_features == 2

	// Check mean (1+3+5)/3 = 3, (2+4+6)/3 = 4
	assert math.abs(scaler.mean_[0] - 3.0) < 1e-10
	assert math.abs(scaler.mean_[1] - 4.0) < 1e-10
}

fn test_standard_scaler_transform() {
	data := [[0.0], [1.0], [2.0], [3.0], [4.0]]

	mut scaler := StandardScaler.new()
	result := scaler.fit_transform(data)!

	// Mean = 2, Std = sqrt(2)
	// Transformed middle value should be 0
	assert math.abs(result[2][0]) < 1e-10 // (2-2)/std = 0
}

fn test_standard_scaler_inverse_transform() {
	data := [[1.0, 10.0], [2.0, 20.0], [3.0, 30.0]]

	mut scaler := StandardScaler.new()
	transformed := scaler.fit_transform(data)!
	recovered := scaler.inverse_transform(transformed)!

	for i in 0 .. data.len {
		for j in 0 .. data[0].len {
			assert math.abs(recovered[i][j] - data[i][j]) < 1e-10
		}
	}
}

fn test_minmax_scaler_basic() {
	data := [[1.0], [2.0], [3.0], [4.0], [5.0]]

	mut scaler := MinMaxScaler.new(0.0, 1.0)
	result := scaler.fit_transform(data)!

	assert scaler.fitted == true
	assert math.abs(result[0][0] - 0.0) < 1e-10 // min -> 0
	assert math.abs(result[4][0] - 1.0) < 1e-10 // max -> 1
	assert math.abs(result[2][0] - 0.5) < 1e-10 // mid -> 0.5
}

fn test_minmax_scaler_custom_range() {
	data := [[0.0], [50.0], [100.0]]

	mut scaler := MinMaxScaler.new(-1.0, 1.0)
	result := scaler.fit_transform(data)!

	assert math.abs(result[0][0] - (-1.0)) < 1e-10 // min -> -1
	assert math.abs(result[2][0] - 1.0) < 1e-10 // max -> 1
	assert math.abs(result[1][0] - 0.0) < 1e-10 // mid -> 0
}

fn test_minmax_scaler_inverse_transform() {
	data := [[10.0, 100.0], [20.0, 200.0], [30.0, 300.0]]

	mut scaler := MinMaxScaler.new(0.0, 1.0)
	transformed := scaler.fit_transform(data)!
	recovered := scaler.inverse_transform(transformed)!

	for i in 0 .. data.len {
		for j in 0 .. data[0].len {
			assert math.abs(recovered[i][j] - data[i][j]) < 1e-10
		}
	}
}

fn test_robust_scaler_basic() {
	// Data with an outlier
	data := [[1.0], [2.0], [3.0], [4.0], [5.0], [100.0]]

	mut scaler := RobustScaler.new()
	scaler.fit(data)!

	assert scaler.fitted == true
	// Median should be around 3.5, IQR should be reasonable
}

fn test_robust_scaler_transform() {
	data := [[1.0], [2.0], [3.0], [4.0], [5.0]]

	mut scaler := RobustScaler.new()
	result := scaler.fit_transform(data)!

	// The median (3) should map to 0
	assert math.abs(result[2][0]) < 1e-10
}

fn test_scaler_not_fitted_error() {
	scaler := StandardScaler.new()
	data := [[1.0, 2.0]]

	// Should return error when not fitted
	if _ := scaler.transform(data) {
		assert false, 'should have returned error'
	}
}

fn test_standard_scaler_constant_feature() {
	// Feature with zero variance
	data := [[5.0], [5.0], [5.0]]

	mut scaler := StandardScaler.new()
	result := scaler.fit_transform(data)!

	// Should handle constant feature (std set to 1)
	for row in result {
		assert math.abs(row[0]) < 1e-10
	}
}
