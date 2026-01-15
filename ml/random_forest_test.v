module ml

import vsl.la

fn test_random_forest_classification() {
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
	mut model := RandomForest.new(mut data, 'rf_class_test')
	model.set_n_estimators(10)

	model.train()!

	pred_0 := model.predict([0.5, 0.5])
	pred_1 := model.predict([2.5, 2.5])

	assert pred_0 == 0.0 || pred_0 == 1.0
	assert pred_1 == 0.0 || pred_1 == 1.0
}

fn test_random_forest_regression() {
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
	mut model := RandomForest.new(mut data, 'rf_reg_test')
	model.set_n_estimators(10)

	model.train()!

	pred := model.predict([2.5])
	assert pred >= 1.0 && pred <= 3.0
}

fn test_random_forest_observer() {
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
	mut model := RandomForest.new(mut data, 'rf_observer_test')
	model.set_n_estimators(5)
	model.train()!
	assert model.trained == true

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

	assert model.trained == false
}

fn test_random_forest_predict() {
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
	mut model := RandomForest.new(mut data, 'rf_predict_test')
	model.set_n_estimators(10)
	model.train()!

	pred := model.predict([1.5])
	assert pred == 0.0 || pred == 1.0
}

fn test_random_forest_feature_importance() {
	x := [
		[0.0, 0.0],
		[1.0, 1.0],
		[2.0, 2.0],
	]
	y := [
		0.0,
		1.0,
		0.0,
	]
	mut data := Data.from_raw_xy_sep(x, y)!
	mut model := RandomForest.new(mut data, 'rf_importance_test')
	model.set_n_estimators(5)
	model.train()!

	importance := model.get_feature_importance()
	assert importance.len == data.nb_features
}

fn test_random_forest_bootstrap() {
	x := [
		[0.0],
		[1.0],
		[2.0],
	]
	y := [
		0.0,
		1.0,
		0.0,
	]
	mut data := Data.from_raw_xy_sep(x, y)!
	mut model := RandomForest.new(mut data, 'rf_bootstrap_test')
	model.set_n_estimators(5)
	model.set_bootstrap(true)
	model.train()!

	assert model.trees.len == 5
}
