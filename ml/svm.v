module ml

import math
import rand

pub struct SVMConfig {
pub mut:
	max_iterations int = 1000
	learning_rate  f64 = 0.01
	tolerance      f64 = 1e-6
	c              f64 = 1.0 // Regularization parameter
}

pub struct DataPoint {
pub mut:
	x []f64
	y int
}

pub struct SVMModel {
pub mut:
	support_vectors []DataPoint
	alphas          []f64
	b               f64
	kernel          KernelFunction @[required]
	config          SVMConfig
}

type KernelFunction = fn ([]f64, []f64) f64

pub fn linear_kernel(x []f64, y []f64) f64 {
	return dot_product(x, y)
}

pub fn polynomial_kernel(degree int) KernelFunction {
	return fn [degree] (x []f64, y []f64) f64 {
		return math.pow(dot_product(x, y) + 1.0, f64(degree))
	}
}

pub fn rbf_kernel(gamma f64) KernelFunction {
	return fn [gamma] (x []f64, y []f64) f64 {
		diff := vector_subtract(x, y)
		return math.exp(-gamma * dot_product(diff, diff))
	}
}

fn dot_product(a []f64, b []f64) f64 {
	mut sum := 0.0
	for i in 0 .. a.len {
		sum += a[i] * b[i]
	}
	return sum
}

fn vector_subtract(a []f64, b []f64) []f64 {
	mut result := []f64{len: a.len}
	for i in 0 .. a.len {
		result[i] = a[i] - b[i]
	}
	return result
}

pub fn train_svm(data []DataPoint, kernel KernelFunction, config SVMConfig) &SVMModel {
	mut model := &SVMModel{
		support_vectors: []DataPoint{}
		alphas: []f64{len: data.len, init: 0.0}
		b: 0.0
		kernel: kernel
		config: config
	}

	mut passes := 0
	for passes < model.config.max_iterations {
		mut num_changed_alphas := 0
		for i in 0 .. data.len {
			ei := predict_raw(model, data[i].x) - f64(data[i].y)
			if (data[i].y * ei < -model.config.tolerance && model.alphas[i] < model.config.c)
				|| (data[i].y * ei > model.config.tolerance && model.alphas[i] > 0) {
				j := rand.int_in_range(0, data.len - 1) or { panic(err) }
				ej := predict_raw(model, data[j].x) - f64(data[j].y)

				alpha_i_old := model.alphas[i]
				alpha_j_old := model.alphas[j]

				mut l, mut h := 0.0, 0.0
				if data[i].y != data[j].y {
					l = math.max(0.0, model.alphas[j] - model.alphas[i])
					h = math.min(model.config.c, model.config.c + model.alphas[j] - model.alphas[i])
				} else {
					l = math.max(0.0, model.alphas[i] + model.alphas[j] - model.config.c)
					h = math.min(model.config.c, model.alphas[i] + model.alphas[j])
				}

				if l == h {
					continue
				}

				eta := 2 * model.kernel(data[i].x, data[j].x) - model.kernel(data[i].x, data[i].x) - model.kernel(data[j].x, data[j].x)

				if eta >= 0 {
					continue
				}

				model.alphas[j] = alpha_j_old - f64(data[j].y) * (ei - ej) / eta
				model.alphas[j] = math.max(l, math.min(h, model.alphas[j]))

				if math.abs(model.alphas[j] - alpha_j_old) < 1e-5 {
					continue
				}

				model.alphas[i] = alpha_i_old + f64(data[i].y * data[j].y) * (alpha_j_old - model.alphas[j])

				b1 := model.b - ei - f64(data[i].y) * (model.alphas[i] - alpha_i_old) * model.kernel(data[i].x, data[i].x) - f64(data[j].y) * (model.alphas[j] - alpha_j_old) * model.kernel(data[i].x, data[j].x)

				b2 := model.b - ej - f64(data[i].y) * (model.alphas[i] - alpha_i_old) * model.kernel(data[i].x, data[j].x) - f64(data[j].y) * (model.alphas[j] - alpha_j_old) * model.kernel(data[j].x, data[j].x)

				if 0 < model.alphas[i] && model.alphas[i] < model.config.c {
					model.b = b1
				} else if 0 < model.alphas[j] && model.alphas[j] < model.config.c {
					model.b = b2
				} else {
					model.b = (b1 + b2) / 2
				}

				num_changed_alphas++
			}
		}

		if num_changed_alphas == 0 {
			passes++
		} else {
			passes = 0
		}
	}

	for i in 0 .. data.len {
		if model.alphas[i] > 0 {
			model.support_vectors << data[i]
		}
	}

	return model
}

fn predict_raw(model &SVMModel, x []f64) f64 {
	mut sum := 0.0
	for i, sv in model.support_vectors {
		sum += model.alphas[i] * f64(sv.y) * model.kernel(x, sv.x)
	}
	return sum + model.b
}

pub fn predict(model &SVMModel, x []f64) int {
	return if predict_raw(model, x) >= 0 { 1 } else { -1 }
}

pub struct MulticlassSVM {
pub mut:
	models  [][]&SVMModel
	classes []int
}

pub fn train_multiclass_svm(data []DataPoint, kernel KernelFunction, config SVMConfig) &MulticlassSVM {
	mut classes := []int{}
	for point in data {
		if point.y !in classes {
			classes << point.y
		}
	}
	classes.sort()

	mut models := [][]&SVMModel{len: classes.len, init: []&SVMModel{}}

	for i in 0 .. classes.len {
		models[i] = []&SVMModel{len: classes.len, init: unsafe { nil }} // unsafe { nil } kullanarak initialize ediyoruz
		for j in i + 1 .. classes.len {
			mut binary_data := []DataPoint{}
			for point in data {
				if point.y == classes[i] || point.y == classes[j] {
					binary_data << DataPoint{
						x: point.x
						y: if point.y == classes[i] { 1 } else { -1 }
					}
				}
			}
			models[i][j] = train_svm(binary_data, kernel, config)
		}
	}

	return &MulticlassSVM{
		models: models
		classes: classes
	}
}

pub fn predict_multiclass(model &MulticlassSVM, x []f64) int {
	mut class_votes := map[int]int{}

	for i in 0 .. model.classes.len {
		for j in i + 1 .. model.classes.len {
			prediction := predict(model.models[i][j], x)
			if prediction == 1 {
				class_votes[model.classes[i]]++
			} else {
				class_votes[model.classes[j]]++
			}
		}
	}

	mut max_votes := 0
	mut predicted_class := 0
	for class, votes in class_votes {
		if votes > max_votes {
			max_votes = votes
			predicted_class = class
		}
	}

	return predicted_class
}
