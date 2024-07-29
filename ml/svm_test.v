module ml

import math

fn test_polynomial_kernel() {
	x := [1.0, 2.0, 3.0]
	y := [4.0, 5.0, 6.0]
	kernel := polynomial_kernel(3)
	result := kernel(x, y)
	expected := math.pow(1 * 4 + 2 * 5 + 3 * 6 + 1, 3) // (32 + 1)^3
	assert result == expected
}

fn test_rbf_kernel() {
	x := [1.0, 2.0, 3.0]
	y := [4.0, 5.0, 6.0]
	gamma := 0.5
	kernel := rbf_kernel(gamma)
	result := kernel(x, y)
	expected := math.exp(-gamma * ((1 - 4) * (1 - 4) + (2 - 5) * (2 - 5) + (3 - 6) * (3 - 6))) // exp(-0.5 * 27)
	assert math.abs(result - expected) < 1e-6
}

fn test_train_svm() {
	kernel := linear_kernel
	data := [
		DataPoint{[2.0, 3.0], 1},
		DataPoint{[1.0, 1.0], -1},
		DataPoint{[3.0, 4.0], 1},
		DataPoint{[0.0, 0.0], -1},
	]
	config := SVMConfig{}
	model := train_svm(data, kernel, config)

	for point in data {
		assert predict(model, point.x) == point.y
	}
}

fn test_predict_svm() {
	kernel := linear_kernel
	data := [
		DataPoint{[2.0, 3.0], 1},
		DataPoint{[1.0, 1.0], -1},
		DataPoint{[3.0, 4.0], 1},
		DataPoint{[0.0, 0.0], -1},
	]
	config := SVMConfig{}
	model := train_svm(data, kernel, config)

	assert predict(model, [2.0, 3.0]) == 1
	assert predict(model, [1.0, 1.0]) == -1
	assert predict(model, [3.0, 4.0]) == 1
	assert predict(model, [0.0, 0.0]) == -1
}

fn test_train_multiclass_svm() {
	kernel := linear_kernel
	data := [
		DataPoint{[2.0, 3.0], 1},
		DataPoint{[1.0, 1.0], 2},
		DataPoint{[3.0, 4.0], 1},
		DataPoint{[0.0, 0.0], 2},
		DataPoint{[3.0, 3.0], 3},
	]
	config := SVMConfig{}
	model := train_multiclass_svm(data, kernel, config)

	for point in data {
		assert predict_multiclass(model, point.x) == point.y
	}
}

fn test_predict_multiclass_svm() {
	kernel := linear_kernel
	data := [
		DataPoint{[2.0, 3.0], 1},
		DataPoint{[1.0, 1.0], 2},
		DataPoint{[3.0, 4.0], 1},
		DataPoint{[0.0, 0.0], 2},
		DataPoint{[3.0, 3.0], 3},
	]
	config := SVMConfig{}
	model := train_multiclass_svm(data, kernel, config)

	assert predict_multiclass(model, [2.0, 3.0]) == 1
	assert predict_multiclass(model, [1.0, 1.0]) == 2
	assert predict_multiclass(model, [3.0, 4.0]) == 1
	assert predict_multiclass(model, [0.0, 0.0]) == 2
	assert predict_multiclass(model, [3.0, 3.0]) == 3
}

fn test_kernels() {
	kernels := [
		linear_kernel,
		polynomial_kernel(3),
		rbf_kernel(0.5),
	]
	for kernel in kernels {
		test_train_svm()
		test_predict_svm()
		test_train_multiclass_svm()
		test_predict_multiclass_svm()
	}
}
