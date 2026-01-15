module main

import vsl.ml

struct TestCase {
	features    []f64
	description string
}

fn main() {
	// Prepare training data for decision tree
	// Classification example: predict if weather is good for playing (1) or not (0)
	// Features: [outlook, temperature, humidity]
	// Target: 0.0 (don't play) or 1.0 (play)
	mut data := ml.Data.from_raw_xy_sep([
		// Encoded features: [sunny=0, overcast=1, rainy=2], [hot=0, mild=1, cool=2], [high=0, normal=1]
		[0.0, 0.0, 0.0], // sunny, hot, high
		[0.0, 0.0, 1.0], // sunny, hot, normal
		[1.0, 0.0, 1.0], // overcast, hot, normal
		[2.0, 1.0, 0.0], // rainy, mild, high
		[2.0, 2.0, 1.0], // rainy, cool, normal
		[2.0, 1.0, 1.0], // rainy, mild, normal
		[1.0, 1.0, 0.0], // overcast, mild, high
		[0.0, 1.0, 0.0], // sunny, mild, high
		[0.0, 2.0, 1.0], // sunny, cool, normal
		[2.0, 1.0, 0.0], // rainy, mild, high
		[0.0, 1.0, 1.0], // sunny, mild, normal
		[1.0, 2.0, 0.0], // overcast, cool, high
		[1.0, 2.0, 1.0], // overcast, cool, normal
		[2.0, 2.0, 0.0], // rainy, cool, high
	], [
		0.0, // don't play
		0.0, // don't play
		1.0, // play
		1.0, // play
		1.0, // play
		1.0, // play
		1.0, // play
		0.0, // don't play
		1.0, // play
		0.0, // don't play
		1.0, // play
		1.0, // play
		1.0, // play
		0.0, // don't play
	])!

	// Initialize decision tree model
	mut model := ml.DecisionTree.new(mut data, 'weather_classifier')
	model.set_criterion(.gini) // Use Gini impurity
	model.set_max_depth(5) // Limit tree depth to prevent overfitting
	model.set_min_samples_split(2)
	model.set_min_samples_leaf(1)

	println('Training decision tree...')
	println('Criterion: Gini impurity')

	// Train the model
	model.train()

	println('\nTraining completed!')

	// Test predictions on new data
	println('\n=== Predictions ===')
	test_cases := [
		TestCase{
			features:    [0.0, 1.0, 1.0]
			description: 'Sunny mild normal'
		},
		TestCase{
			features:    [2.0, 0.0, 0.0]
			description: 'Rainy hot high'
		},
		TestCase{
			features:    [1.0, 1.0, 1.0]
			description: 'Overcast mild normal'
		},
		TestCase{
			features:    [0.0, 0.0, 0.0]
			description: 'Sunny hot high'
		},
	]

	for test_case in test_cases {
		predicted_class := model.predict(test_case.features)
		class_label := if predicted_class == 1.0 { 'PLAY' } else { "DON'T PLAY" }
		println('${test_case.description}:')
		println('  Features: ${test_case.features}')
		println('  Predicted class: ${class_label}')
		println('')
	}

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
		2.0,
		4.0,
		6.0,
		8.0,
		10.0,
	]
	mut reg_data := ml.Data.from_raw_xy_sep(reg_x, reg_y)!
	mut reg_model := ml.DecisionTree.new(mut reg_data, 'regression_tree')
	reg_model.set_criterion(.mse) // Use MSE for regression
	reg_model.set_max_depth(3)
	reg_model.train()

	reg_pred := reg_model.predict([2.5])
	println('Regression prediction for x=2.5: ${reg_pred:.2f}')

	// Note: Plotting is only supported for 2D data (2 features)
	// This example uses 3 features, so plotting is skipped
	// Uncomment the following lines if you have 2D data:
	// println('\nGenerating plot...')
	// plt := model.get_plotter()
	// plt.show()!

	println('\nDecision tree completed successfully! ✅')
}
