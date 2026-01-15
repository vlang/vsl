module ml

import vsl.la

fn test_svm_linear_separable() {
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
	mut model := SVM.new(mut data, 'svm_linear_test')
	model.set_kernel(.linear, 1.0, 3)
	model.set_c(1.0)

	// Train the model
	model.train(100, 1e-3)

	// Test predictions
	pred_0 := model.predict([0.5, 0.5])
	pred_1 := model.predict([2.5, 2.5])

	// Predictions should be 0.0 or 1.0 (converted from -1.0/1.0)
	assert pred_0 == 0.0 || pred_0 == 1.0
	assert pred_1 == 0.0 || pred_1 == 1.0

	// Class 0 should predict 0, class 1 should predict 1
	assert pred_0 == 0.0
	assert pred_1 == 1.0
}

fn test_svm_rbf_kernel() {
	// Non-linearly separable dataset (XOR-like)
	x := [
		[0.0, 0.0],
		[0.0, 1.0],
		[1.0, 0.0],
		[1.0, 1.0],
		[2.0, 0.0],
		[2.0, 1.0],
		[3.0, 0.0],
		[3.0, 1.0],
	]
	y := [
		0.0,
		1.0,
		1.0,
		0.0,
		0.0,
		1.0,
		1.0,
		0.0,
	]
	mut data := Data.from_raw_xy_sep(x, y)!
	mut model := SVM.new(mut data, 'svm_rbf_test')
	model.set_kernel(.rbf, 1.0, 3)
	model.set_c(10.0)

	// Train the model
	model.train(200, 1e-3)

	// Test predictions
	pred := model.predict([0.5, 0.5])
	assert pred == 0.0 || pred == 1.0
}

fn test_svm_observer() {
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
	mut model := SVM.new(mut data, 'svm_observer_test')

	// Get initial alpha length
	initial_alpha_len := model.alpha.len

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

	// Alpha should be updated (different length)
	assert model.alpha.len == new_y.len
	assert model.alpha.len != initial_alpha_len
	assert !model.trained // Should be marked as not trained
}

fn test_svm_predict() {
	// Simple 1D dataset
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
	mut model := SVM.new(mut data, 'svm_predict_test')
	model.set_kernel(.linear, 1.0, 3)
	model.set_c(1.0)

	// Train the model
	model.train(100, 1e-3)

	// Test prediction
	pred := model.predict([1.5])
	assert pred == 0.0 || pred == 1.0
}

fn test_svm_support_vectors() {
	// Simple dataset
	x := [
		[0.0, 0.0],
		[1.0, 1.0],
		[2.0, 2.0],
		[3.0, 3.0],
	]
	y := [
		0.0,
		0.0,
		1.0,
		1.0,
	]
	mut data := Data.from_raw_xy_sep(x, y)!
	mut model := SVM.new(mut data, 'svm_sv_test')
	model.set_kernel(.linear, 1.0, 3)
	model.set_c(1.0)

	// Train the model
	model.train(100, 1e-3)

	// Should have support vectors
	assert model.support_vectors.len > 0
	assert model.support_vectors.len <= data.nb_samples
	assert model.support_vector_labels.len == model.support_vectors.len
}

fn test_svm_predict_proba() {
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
	mut model := SVM.new(mut data, 'svm_proba_test')
	model.set_kernel(.linear, 1.0, 3)
	model.set_c(1.0)

	// Train the model
	model.train(100, 1e-3)

	// Test probability prediction
	proba := model.predict_proba([1.5])
	assert proba >= 0.0 && proba <= 1.0
}
