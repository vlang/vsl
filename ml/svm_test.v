module ml

import math

fn test_vector_dot() {
	x := [1.0, 2.0, 3.0]
	y := [4.0, 5.0, 6.0]
	result := vector_dot(x, y)
	assert math.abs(result - 32.0) < 1e-6
}

fn test_vector_subtract() {
	x := [1.0, 2.0, 3.0]
	y := [4.0, 5.0, 6.0]
	result := vector_subtract(x, y)
	assert result == [-3.0, -3.0, -3.0]
}

fn test_linear_kernel() {
	x := [1.0, 2.0, 3.0]
	y := [4.0, 5.0, 6.0]
	result := linear_kernel(x, y)
	assert math.abs(result - 32.0) < 1e-6
}

fn test_polynomial_kernel() {
	x := [1.0, 2.0, 3.0]
	y := [4.0, 5.0, 6.0]
	kernel := polynomial_kernel(3)
	result := kernel(x, y)
	expected := math.pow(32.0 + 1.0, 3)
	assert math.abs(result - expected) < 1e-6
}

fn test_rbf_kernel() {
	x := [1.0, 2.0, 3.0]
	y := [4.0, 5.0, 6.0]
	gamma := 0.5
	kernel := rbf_kernel(gamma)
	result := kernel(x, y)
	expected := math.exp(-gamma * 27.0)
	assert math.abs(result - expected) < 1e-6
}

fn test_svm_new() {
	config := SVMConfig{}
	svm := SVM.new(linear_kernel, config)
	assert svm.kernel == linear_kernel
	assert svm.config == config
}

fn test_svm_train_and_predict() {
	mut svm := SVM.new(linear_kernel, SVMConfig{})
	data := [
		DataPoint{[2.0, 3.0], 1},
		DataPoint{[1.0, 1.0], -1},
		DataPoint{[3.0, 4.0], 1},
		DataPoint{[0.0, 0.0], -1},
	]
	svm.train(data)

	for point in data {
		prediction := svm.predict(point.x)
		assert prediction == point.y
	}
}

fn test_train_svm() {
	data := [
		DataPoint{[2.0, 3.0], 1},
		DataPoint{[1.0, 1.0], -1},
		DataPoint{[3.0, 4.0], 1},
		DataPoint{[0.0, 0.0], -1},
	]
	config := SVMConfig{}
	model := train_svm(data, linear_kernel, config)

	for point in data {
		prediction := predict(model, point.x)
		assert prediction == point.y
	}
}

fn test_predict_raw() {
	data := [
		DataPoint{[2.0, 3.0], 1},
		DataPoint{[1.0, 1.0], -1},
	]
	config := SVMConfig{}
	model := train_svm(data, linear_kernel, config)

	result := predict_raw(model, [2.0, 3.0])
	assert result > 0

	result2 := predict_raw(model, [1.0, 1.0])
	assert result2 < 0
}

fn test_predict() {
	data := [
		DataPoint{[2.0, 3.0], 1},
		DataPoint{[1.0, 1.0], -1},
		DataPoint{[3.0, 4.0], 1},
		DataPoint{[0.0, 0.0], -1},
	]
	config := SVMConfig{}
	model := train_svm(data, linear_kernel, config)

	for point in data {
		prediction := predict(model, point.x)
		assert prediction == point.y
	}
}

fn main() {
	test_vector_dot()
	test_vector_subtract()
	test_linear_kernel()
	test_polynomial_kernel()
	test_rbf_kernel()
	test_svm_new()
	test_svm_train_and_predict()
	test_train_svm()
	test_predict_raw()
	test_predict()
	println('All tests passed successfully!')
}
