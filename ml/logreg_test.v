module ml

import vsl.float.float64
import vsl.la

fn test_logreg_binary_classification() {
	// Simple 2D dataset with clear separation
	x := [
		[0.0, 0.0],
		[0.0, 1.0],
		[1.0, 0.0],
		[1.0, 1.0],
		[2.0, 2.0],
		[2.0, 3.0],
		[3.0, 2.0],
		[3.0, 3.0],
	]
	y := [
		0.0,
		0.0,
		0.0,
		0.0,
		1.0,
		1.0,
		1.0,
		1.0,
	]
	mut data := Data.from_raw_xy_sep(x, y)!
	mut model := LogReg.new(mut data, 'logreg_test')

	// Train the model
	model.train(epochs: 100, learning_rate: 0.1)

	// Test predictions
	pred_0 := model.predict([0.5, 0.5])
	pred_1 := model.predict([2.5, 2.5])

	// Predictions should be probabilities between 0 and 1
	assert pred_0 >= 0.0 && pred_0 <= 1.0
	assert pred_1 >= 0.0 && pred_1 <= 1.0

	// Class 0 should have lower probability than class 1
	assert pred_0 < pred_1
}

fn test_logreg_predict() {
	// Simple 1D dataset
	x := [
		[0.0],
		[1.0],
		[2.0],
		[3.0],
		[4.0],
	]
	y := [
		0.0,
		0.0,
		1.0,
		1.0,
		1.0,
	]
	mut data := Data.from_raw_xy_sep(x, y)!
	mut model := LogReg.new(mut data, 'logreg_predict_test')

	// Set initial parameters manually for testing
	model.params.set_thetas([1.0])
	model.params.set_bias(-1.5)

	// Test prediction
	pred := model.predict([1.5])
	assert pred >= 0.0 && pred <= 1.0
}

fn test_logreg_observer() {
	// Test that model updates when data changes
	x := [
		[0.0],
		[1.0],
		[2.0],
	]
	y := [
		0.0,
		0.0,
		1.0,
	]
	mut data := Data.from_raw_xy_sep(x, y)!
	mut model := LogReg.new(mut data, 'logreg_observer_test')

	// Get initial ybar length
	initial_ybar_len := model.ybar.len

	// Change data
	new_x := [
		[0.0],
		[1.0],
		[2.0],
		[3.0],
	]
	new_y := [
		0.0,
		0.0,
		1.0,
		1.0,
	]
	new_matrix := la.Matrix.deep2(new_x)
	data.set(new_matrix, new_y)!

	// ybar should be updated (different length)
	assert model.ybar.len == new_y.len
	assert model.ybar.len != initial_ybar_len
}

fn test_logreg_cost() {
	// Simple dataset
	x := [
		[0.0],
		[1.0],
		[2.0],
	]
	y := [
		0.0,
		0.0,
		1.0,
	]
	mut data := Data.from_raw_xy_sep(x, y)!
	mut model := LogReg.new(mut data, 'logreg_cost_test')

	// Set parameters
	model.params.set_thetas([1.0])
	model.params.set_bias(-1.0)

	// Cost should be non-negative
	cost := model.cost()
	assert cost >= 0.0
}

fn test_logreg_gradients() {
	// Simple dataset
	x := [
		[0.0],
		[1.0],
		[2.0],
	]
	y := [
		0.0,
		0.0,
		1.0,
	]
	mut data := Data.from_raw_xy_sep(x, y)!
	mut model := LogReg.new(mut data, 'logreg_gradients_test')

	// Set parameters
	model.params.set_thetas([1.0])
	model.params.set_bias(-1.0)

	// Compute gradients
	dcdtheta, dcdb := model.gradients()

	// Gradients should have correct dimensions
	assert dcdtheta.len == data.nb_features
	// dcdb should be f64 type (just verify it's a number)
	assert dcdb >= -1000.0 && dcdb <= 1000.0
}

fn test_logreg_train() {
	// Linearly separable 2D dataset
	x := [
		[0.0, 0.0],
		[0.0, 1.0],
		[1.0, 0.0],
		[1.0, 1.0],
		[2.0, 2.0],
		[2.0, 3.0],
		[3.0, 2.0],
		[3.0, 3.0],
	]
	y := [
		0.0,
		0.0,
		0.0,
		0.0,
		1.0,
		1.0,
		1.0,
		1.0,
	]
	mut data := Data.from_raw_xy_sep(x, y)!
	mut model := LogReg.new(mut data, 'logreg_train_test')

	// Get initial cost
	initial_cost := model.cost()

	// Train the model
	model.train(epochs: 100, learning_rate: 0.1)

	// Cost should decrease after training
	final_cost := model.cost()
	assert final_cost <= initial_cost || float64.tolerance(final_cost, initial_cost, 1e-3)
}

fn test_logreg_train_newton() {
	// Simple dataset
	x := [
		[0.0],
		[1.0],
		[2.0],
		[3.0],
	]
	y := [
		0.0,
		0.0,
		1.0,
		1.0,
	]
	mut data := Data.from_raw_xy_sep(x, y)!
	mut model := LogReg.new(mut data, 'logreg_newton_test')

	// Get initial cost
	initial_cost := model.cost()

	// Train using Newton's method
	model.train(epochs: 10, use_newton: true)

	// Cost should decrease
	final_cost := model.cost()
	assert final_cost <= initial_cost || float64.tolerance(final_cost, initial_cost, 1e-3)
}
