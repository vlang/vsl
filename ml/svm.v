module ml

import math

pub struct SVMConfig {
pub mut:
	max_iterations int = 1000
	learning_rate  f64 = 0.01
	tolerance      f64 = 1e-6
}

pub struct DataPoint {
pub mut:
	x []f64
	y int
}

pub struct SVMModel {
pub mut:
	weights []f64
	bias    f64
	config  SVMConfig
}

pub struct SVM {
pub mut:
	model  &SVMModel = unsafe { nil }
	config SVMConfig
}

pub fn SVM.new(config SVMConfig) &SVM {
	return &SVM{
		config: config
	}
}

pub fn (mut s SVM) train(data []DataPoint) {
	s.model = train_svm(data, s.config)
}

pub fn (s &SVM) predict(x []f64) int {
	return predict(s.model, x)
}

fn vector_dot(x []f64, y []f64) f64 {
	mut sum := 0.0
	for i := 0; i < x.len; i++ {
		sum += x[i] * y[i]
	}
	return sum
}

pub fn train_svm(data []DataPoint, config SVMConfig) &SVMModel {
	mut model := &SVMModel{
		weights: []f64{len: data[0].x.len, init: 0.0}
		bias: 0.0
		config: config
	}

	for _ in 0 .. config.max_iterations {
		mut cost := 0.0
		for point in data {
			prediction := vector_dot(model.weights, point.x) + model.bias
			margin := f64(point.y) * prediction

			if margin < 1 {
				for i in 0 .. model.weights.len {
					model.weights[i] += config.learning_rate * (f64(point.y) * point.x[i] - 2 * config.tolerance * model.weights[i])
				}
				model.bias += config.learning_rate * f64(point.y)
				cost += 1 - margin
			} else {
				for i in 0 .. model.weights.len {
					model.weights[i] -= config.learning_rate * 2 * config.tolerance * model.weights[i]
				}
			}
		}

		if cost == 0 {
			break
		}
	}

	return model
}

pub fn predict(model &SVMModel, x []f64) int {
	prediction := vector_dot(model.weights, x) + model.bias
	return if prediction >= 0 { 1 } else { -1 }
}
