module main

import vsl.ml

struct TestCase {
	features    []f64
	description string
}

fn main() {
	// Prepare training data for SVM
	// Binary classification example: classify points as inside or outside a circle
	// Features: [x, y] coordinates
	// Target: 0.0 (outside) or 1.0 (inside)
	mut data := ml.Data.from_raw_xy_sep([
		// Points outside the circle (class 0)
		[2.0, 2.0],
		[2.0, -2.0],
		[-2.0, 2.0],
		[-2.0, -2.0],
		[1.5, 1.5],
		[1.5, -1.5],
		[-1.5, 1.5],
		[-1.5, -1.5],
		// Points inside the circle (class 1)
		[0.0, 0.0],
		[0.5, 0.5],
		[-0.5, 0.5],
		[0.5, -0.5],
		[-0.5, -0.5],
		[0.8, 0.0],
		[0.0, 0.8],
		[-0.8, 0.0],
	], [
		0.0, // outside
		0.0, // outside
		0.0, // outside
		0.0, // outside
		0.0, // outside
		0.0, // outside
		0.0, // outside
		0.0, // outside
		1.0, // inside
		1.0, // inside
		1.0, // inside
		1.0, // inside
		1.0, // inside
		1.0, // inside
		1.0, // inside
		1.0, // inside
	])!

	// Initialize SVM model with RBF kernel (for non-linear decision boundary)
	mut model := ml.SVM.new(mut data, 'circle_classifier')
	model.set_kernel(.rbf, 1.0, 3) // RBF kernel with gamma=1.0
	model.set_c(10.0) // Regularization parameter

	println('Training SVM with RBF kernel...')
	println('C (regularization): ${model.c}')
	println('Gamma (RBF parameter): ${model.gamma}')

	// Train the model
	model.train(200, 1e-3)

	println('\nTraining completed!')
	println('Number of support vectors: ${model.support_vectors.len}')

	// Test predictions on new data
	println('\n=== Predictions ===')
	test_cases := [
		TestCase{
			features:    [0.0, 0.0]
			description: 'Center point'
		},
		TestCase{
			features:    [0.5, 0.5]
			description: 'Inside point'
		},
		TestCase{
			features:    [1.5, 1.5]
			description: 'Edge point'
		},
		TestCase{
			features:    [2.0, 2.0]
			description: 'Outside point'
		},
		TestCase{
			features:    [-1.0, 0.0]
			description: 'Left side'
		},
		TestCase{
			features:    [1.0, 0.0]
			description: 'Right side'
		},
	]

	for test_case in test_cases {
		predicted_class := model.predict(test_case.features)
		probability := model.predict_proba(test_case.features)
		class_label := if predicted_class == 1.0 { 'INSIDE' } else { 'OUTSIDE' }
		println('${test_case.description}:')
		println('  Features: ${test_case.features}')
		println('  Predicted class: ${class_label}')
		println('  Probability: ${probability:.4f}')
		println('')
	}

	// Try with linear kernel for comparison
	println('\n=== Training with Linear Kernel ===')
	mut model_linear := ml.SVM.new(mut data, 'circle_classifier_linear')
	model_linear.set_kernel(.linear, 1.0, 3)
	model_linear.set_c(10.0)
	model_linear.train(200, 1e-3)
	println('Linear kernel - Support vectors: ${model_linear.support_vectors.len}')

	// Create visualization
	println('\nGenerating plot...')
	plt := model.get_plotter()
	plt.show()!

	println('\nSVM classification completed successfully! ✅')
}
