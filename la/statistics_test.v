module la

import math

fn test_correlation_matrix_identity() {
	// Perfectly correlated (same data)
	mut data := Matrix.new[f64](4, 2)
	data.set(0, 0, 1.0)
	data.set(0, 1, 1.0)
	data.set(1, 0, 2.0)
	data.set(1, 1, 2.0)
	data.set(2, 0, 3.0)
	data.set(2, 1, 3.0)
	data.set(3, 0, 4.0)
	data.set(3, 1, 4.0)

	corr := correlation_matrix(data)

	assert corr.m == 2
	assert corr.n == 2
	assert math.abs(corr.get(0, 0) - 1.0) < 1e-10
	assert math.abs(corr.get(1, 1) - 1.0) < 1e-10
	assert math.abs(corr.get(0, 1) - 1.0) < 1e-10 // Perfect correlation
}

fn test_correlation_matrix_negative() {
	// Negatively correlated
	mut data := Matrix.new[f64](4, 2)
	data.set(0, 0, 1.0)
	data.set(0, 1, 4.0)
	data.set(1, 0, 2.0)
	data.set(1, 1, 3.0)
	data.set(2, 0, 3.0)
	data.set(2, 1, 2.0)
	data.set(3, 0, 4.0)
	data.set(3, 1, 1.0)

	corr := correlation_matrix(data)

	assert math.abs(corr.get(0, 1) - (-1.0)) < 1e-10 // Perfect negative correlation
}

fn test_covariance_matrix() {
	mut data := Matrix.new[f64](4, 2)
	data.set(0, 0, 1.0)
	data.set(0, 1, 2.0)
	data.set(1, 0, 2.0)
	data.set(1, 1, 4.0)
	data.set(2, 0, 3.0)
	data.set(2, 1, 6.0)
	data.set(3, 0, 4.0)
	data.set(3, 1, 8.0)

	cov := covariance_matrix(data, 0)

	assert cov.m == 2
	assert cov.n == 2
	// Should be symmetric
	assert math.abs(cov.get(0, 1) - cov.get(1, 0)) < 1e-10
}

fn test_column_mean() {
	mut data := Matrix.new[f64](4, 2)
	data.set(0, 0, 1.0)
	data.set(0, 1, 10.0)
	data.set(1, 0, 2.0)
	data.set(1, 1, 20.0)
	data.set(2, 0, 3.0)
	data.set(2, 1, 30.0)
	data.set(3, 0, 4.0)
	data.set(3, 1, 40.0)

	means := column_mean(data)

	assert means.len == 2
	assert math.abs(means[0] - 2.5) < 1e-10
	assert math.abs(means[1] - 25.0) < 1e-10
}

fn test_column_std() {
	mut data := Matrix.new[f64](4, 1)
	data.set(0, 0, 1.0)
	data.set(1, 0, 2.0)
	data.set(2, 0, 3.0)
	data.set(3, 0, 4.0)

	stds := column_std(data, 0)

	// Variance = ((1-2.5)^2 + (2-2.5)^2 + (3-2.5)^2 + (4-2.5)^2) / 4
	// = (2.25 + 0.25 + 0.25 + 2.25) / 4 = 5 / 4 = 1.25
	// Std = sqrt(1.25) ≈ 1.118
	expected := math.sqrt(1.25)
	assert math.abs(stds[0] - expected) < 1e-10
}

fn test_column_min_max() {
	mut data := Matrix.new[f64](4, 2)
	data.set(0, 0, 1.0)
	data.set(0, 1, -5.0)
	data.set(1, 0, 5.0)
	data.set(1, 1, 10.0)
	data.set(2, 0, 3.0)
	data.set(2, 1, 0.0)
	data.set(3, 0, -2.0)
	data.set(3, 1, 7.0)

	mins := column_min(data)
	maxs := column_max(data)

	assert mins[0] == -2.0
	assert mins[1] == -5.0
	assert maxs[0] == 5.0
	assert maxs[1] == 10.0
}

fn test_column_sum() {
	mut data := Matrix.new[f64](3, 2)
	data.set(0, 0, 1.0)
	data.set(0, 1, 10.0)
	data.set(1, 0, 2.0)
	data.set(1, 1, 20.0)
	data.set(2, 0, 3.0)
	data.set(2, 1, 30.0)

	sums := column_sum(data)

	assert math.abs(sums[0] - 6.0) < 1e-10
	assert math.abs(sums[1] - 60.0) < 1e-10
}

fn test_center_matrix() {
	mut data := Matrix.new[f64](4, 2)
	data.set(0, 0, 1.0)
	data.set(0, 1, 10.0)
	data.set(1, 0, 2.0)
	data.set(1, 1, 20.0)
	data.set(2, 0, 3.0)
	data.set(2, 1, 30.0)
	data.set(3, 0, 4.0)
	data.set(3, 1, 40.0)

	centered := center_matrix(data)

	// Means should now be 0
	centered_means := column_mean(centered)
	assert math.abs(centered_means[0]) < 1e-10
	assert math.abs(centered_means[1]) < 1e-10
}

fn test_standardize_matrix() {
	mut data := Matrix.new[f64](4, 1)
	data.set(0, 0, 1.0)
	data.set(1, 0, 2.0)
	data.set(2, 0, 3.0)
	data.set(3, 0, 4.0)

	standardized := standardize_matrix(data)

	// Mean should be 0, std should be 1
	std_means := column_mean(standardized)
	std_stds := column_std(standardized, 0)

	assert math.abs(std_means[0]) < 1e-10
	assert math.abs(std_stds[0] - 1.0) < 1e-10
}
