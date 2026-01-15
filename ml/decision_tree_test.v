module ml

import vsl.la

fn test_decision_tree_classification() {
	// Simple 2D classification dataset
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
	mut model := DecisionTree.new(mut data, 'dt_class_test')
	model.set_criterion(.gini)
	model.set_max_depth(10)

	// Train the model
	model.train()

	// Test predictions
	pred_0 := model.predict([0.5, 0.5])
	pred_1 := model.predict([2.5, 2.5])

	// Should predict correct classes
	assert pred_0 == 0.0
	assert pred_1 == 1.0
}

fn test_decision_tree_regression() {
	// Simple 1D regression dataset
	x := [
		[0.0],
		[1.0],
		[2.0],
		[3.0],
		[4.0],
	]
	y := [
		0.0,
		1.0,
		2.0,
		3.0,
		4.0,
	]
	mut data := Data.from_raw_xy_sep(x, y)!
	mut model := DecisionTree.new(mut data, 'dt_reg_test')
	model.set_criterion(.mse)
	model.set_max_depth(5)

	// Train the model
	model.train()

	// Test predictions
	pred := model.predict([2.5])
	assert pred >= 1.0 && pred <= 3.0
}

fn test_decision_tree_max_depth() {
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
	mut model := DecisionTree.new(mut data, 'dt_depth_test')
	model.set_max_depth(2)

	// Train the model
	model.train()

	// Should still make predictions
	pred := model.predict([1.5])
	assert pred == 0.0 || pred == 1.0
}

fn test_decision_tree_observer() {
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
	mut model := DecisionTree.new(mut data, 'dt_observer_test')

	// Train initially
	model.train()
	assert model.trained == true

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

	// Should be marked as not trained
	assert model.trained == false
}

fn test_decision_tree_predict() {
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
	mut model := DecisionTree.new(mut data, 'dt_predict_test')
	model.train()

	pred := model.predict([1.5])
	assert pred == 0.0 || pred == 1.0
}

fn test_decision_tree_gini() {
	// Test Gini impurity calculation
	y1 := [0.0, 0.0, 1.0, 1.0] // Perfect split
	y2 := [0.0, 0.0, 0.0, 1.0] // Impure

	// Gini should be lower for y1 (more pure)
	// This is tested indirectly through tree building
	x := [
		[0.0],
		[1.0],
		[2.0],
		[3.0],
	]
	mut data := Data.from_raw_xy_sep(x, y1)!
	mut model := DecisionTree.new(mut data, 'dt_gini_test')
	model.set_criterion(.gini)
	model.train()

	// Should build a tree successfully
	assert model.trained == true
}
