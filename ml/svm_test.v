module ml

import math

fn test_vector_dot() {
	x := [1.0, 2.0, 3.0]
	y := [4.0, 5.0, 6.0]
	result := vector_dot(x, y)
	assert math.abs(result - 32.0) < 1e-6
}

fn test_svm_new() {
	config := SVMConfig{}
	svm := SVM.new(config)
	assert svm.config == config
}

fn test_svm_train_and_predict() {
	mut svm := SVM.new(SVMConfig{})
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
	model := train_svm(data, config)

	for point in data {
		prediction := predict(model, point.x)
		assert prediction == point.y
	}
}

fn test_predict() {
	data := [
		DataPoint{[2.0, 3.0], 1},
		DataPoint{[1.0, 1.0], -1},
		DataPoint{[3.0, 4.0], 1},
		DataPoint{[0.0, 0.0], -1},
	]
	config := SVMConfig{}
	model := train_svm(data, config)

	for point in data {
		prediction := predict(model, point.x)
		assert prediction == point.y
	}
}

fn main() {
	test_vector_dot()
	test_svm_new()
	test_svm_train_and_predict()
	test_train_svm()
	test_predict()
	println('All tests passed successfully!')
}
