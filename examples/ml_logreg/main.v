module main

import vsl.ml
import vsl.plot

struct TestCase {
	features    []f64
	description string
}

fn main() {
	// Prepare training data for logistic regression
	// Binary classification example: predict if a student passes (1) or fails (0)
	// Features: [hours_studied, hours_slept]
	// Target: pass (1.0) or fail (0.0)
	mut data := ml.Data.from_raw_xy_sep([
		// Students who failed (class 0)
		[1.0, 4.0], // Studied 1 hour, slept 4 hours
		[2.0, 5.0], // Studied 2 hours, slept 5 hours
		[1.5, 3.0], // Studied 1.5 hours, slept 3 hours
		[0.5, 4.5], // Studied 0.5 hours, slept 4.5 hours
		[2.0, 3.5], // Studied 2 hours, slept 3.5 hours
		// Students who passed (class 1)
		[5.0, 7.0], // Studied 5 hours, slept 7 hours
		[6.0, 8.0], // Studied 6 hours, slept 8 hours
		[7.0, 7.5], // Studied 7 hours, slept 7.5 hours
		[5.5, 6.5], // Studied 5.5 hours, slept 6.5 hours
		[6.5, 8.5], // Studied 6.5 hours, slept 8.5 hours
	], [
		0.0, // fail
		0.0, // fail
		0.0, // fail
		0.0, // fail
		0.0, // fail
		1.0, // pass
		1.0, // pass
		1.0, // pass
		1.0, // pass
		1.0, // pass
	])!

	// Initialize logistic regression model
	mut model := ml.LogReg.new(mut data, 'student_pass_predictor')

	// Display initial cost
	initial_cost := model.cost()
	println('Initial cost: ${initial_cost:.6f}')

	// Train the model using gradient descent
	println('\nTraining model...')
	model.train(epochs: 1000, learning_rate: 0.1)

	// Display final cost
	final_cost := model.cost()
	println('Final cost: ${final_cost:.6f}')
	println('Cost reduction: ${initial_cost - final_cost:.6f}')

	// Test predictions on new data
	println('\n=== Predictions ===')
	test_cases := [
		TestCase{
			features:    [3.0, 5.0]
			description: 'Average student'
		},
		TestCase{
			features:    [4.0, 6.0]
			description: 'Good student'
		},
		TestCase{
			features:    [8.0, 9.0]
			description: 'Excellent student'
		},
		TestCase{
			features:    [1.0, 3.0]
			description: 'Poor student'
		},
	]

	for test_case in test_cases {
		probability := model.predict(test_case.features)
		predicted_class := if probability >= 0.5 { 'PASS' } else { 'FAIL' }
		println('${test_case.description}:')
		println('  Features: ${test_case.features}')
		println('  Probability of passing: ${probability:.4f}')
		println('  Predicted class: ${predicted_class}')
		println('')
	}

	// Display model parameters
	theta := model.params.access_thetas()
	bias := model.params.get_bias()
	println('=== Model Parameters ===')
	println('Theta (weights): ${theta}')
	println('Bias: ${bias:.6f}')

	// Create visualization
	println('\nGenerating plot...')
	plt := model.get_plotter()
	plt.show()!

	println('\nLogistic regression completed successfully! ✅')
}
