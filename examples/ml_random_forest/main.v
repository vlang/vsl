module main

import vsl.ml

struct TestCase {
	features    []f64
	description string
}

fn main() {
	// Prepare training data for Random Forest
	// Classification example: predict flower type (similar to Iris dataset)
	// Features: [sepal_length, sepal_width, petal_length, petal_width]
	// Target: 0.0 (setosa), 1.0 (versicolor), 2.0 (virginica) - simplified to binary
	mut data := ml.Data.from_raw_xy_sep([
		// Class 0 (setosa-like)
		[5.1, 3.5, 1.4, 0.2],
		[4.9, 3.0, 1.4, 0.2],
		[4.7, 3.2, 1.3, 0.2],
		[4.6, 3.1, 1.5, 0.2],
		[5.0, 3.6, 1.4, 0.2],
		// Class 1 (versicolor-like)
		[7.0, 3.2, 4.7, 1.4],
		[6.4, 3.2, 4.5, 1.5],
		[6.9, 3.1, 4.9, 1.5],
		[5.5, 2.3, 4.0, 1.3],
		[6.5, 2.8, 4.6, 1.5],
		[5.7, 2.8, 4.5, 1.3],
		[6.3, 3.3, 4.7, 1.6],
	], [
		0.0, // setosa
		0.0, // setosa
		0.0, // setosa
		0.0, // setosa
		0.0, // setosa
		1.0, // versicolor
		1.0, // versicolor
		1.0, // versicolor
		1.0, // versicolor
		1.0, // versicolor
		1.0, // versicolor
		1.0, // versicolor
	])!

	// Initialize Random Forest model
	mut model := ml.RandomForest.new(mut data, 'flower_classifier')
	model.set_n_estimators(50) // Number of trees
	model.set_bootstrap(true) // Use bootstrap sampling

	println('Training Random Forest...')
	println('Number of trees: ${model.n_estimators}')
	println('Bootstrap sampling: ${model.bootstrap}')

	// Train the model
	model.train()!

	println('\nTraining completed!')
	println('Number of trees trained: ${model.trees.len}')

	// Test predictions on new data
	println('\n=== Predictions ===')
	test_cases := [
		TestCase{
			features:    [5.0, 3.4, 1.5, 0.2]
			description: 'Setosa-like flower'
		},
		TestCase{
			features:    [6.2, 3.0, 4.5, 1.5]
			description: 'Versicolor-like flower'
		},
		TestCase{
			features:    [5.5, 2.5, 4.0, 1.3]
			description: 'Borderline case'
		},
	]

	for test_case in test_cases {
		predicted_class := model.predict(test_case.features)
		probability := model.predict_proba(test_case.features)
		class_label := if predicted_class == 1.0 { 'VERSICOLOR' } else { 'SETOSA' }
		println('${test_case.description}:')
		println('  Features: ${test_case.features}')
		println('  Predicted class: ${class_label}')
		println('  Probability (class 1): ${probability:.4f}')
		println('')
	}

	// Compare with single decision tree
	println('\n=== Comparison with Single Decision Tree ===')
	mut single_tree := ml.DecisionTree.new(mut data, 'single_tree')
	single_tree.set_max_depth(5)
	single_tree.train()

	single_pred := single_tree.predict([6.2, 3.0, 4.5, 1.5])
	rf_pred := model.predict([6.2, 3.0, 4.5, 1.5])
	println('Single tree prediction: ${single_pred}')
	println('Random Forest prediction: ${rf_pred}')

	// Feature importance (placeholder)
	println('\n=== Feature Importance ===')
	importance := model.get_feature_importance()
	println('Feature importance: ${importance}')

	// Try regression example
	println('\n=== Regression Example ===')
	reg_x := [
		[0.0],
		[1.0],
		[2.0],
		[3.0],
		[4.0],
		[5.0],
	]
	reg_y := [
		0.0,
		2.1,
		4.2,
		6.1,
		8.3,
		10.0,
	]
	mut reg_data := ml.Data.from_raw_xy_sep(reg_x, reg_y)!
	mut reg_model := ml.RandomForest.new(mut reg_data, 'regression_forest')
	reg_model.set_n_estimators(20)
	reg_model.train()!

	reg_pred := reg_model.predict([2.5])
	println('Regression prediction for x=2.5: ${reg_pred:.2f}')

	// Note: Plotting is only supported for 2D data (2 features)
	// This example uses 4 features, so plotting is skipped
	// Uncomment the following lines if you have 2D data:
	// println('\nGenerating plot...')
	// plt := model.get_plotter()
	// plt.show()!

	println('\nRandom Forest completed successfully! ✅')
}
