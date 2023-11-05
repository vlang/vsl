module main

import vsl.ml

fn main() {
	// Generate random data with two classes
	x := [
		[1.0, 2.0],
		[2.0, 3.0],
		[3.0, 3.0],
		[2.0, 1.0],
		[6.0, 7.0],
		[8.0, 6.0],
		[7.0, 8.0],
		[8.0, 7.0],
		[4.0, 5.0],
		[5.0, 5.0],
		[4.5, 6.0],
		[7.0, 6.0],
	]
	y := [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0]
	mut data := ml.Data.from_raw_xy_sep(x, y)!

	// Create a KNN model
	mut knn := ml.KNN.new(mut data, 'Example KNN')!

	// Set weights to give more importance to class 1
	weights := {
		0.0: 1.0
		1.0: 2.0
	}
	knn.set_weights(weights)!

	// Train the KNN model
	knn.train()

	// Predict the class for a new point
	to_pred := [4.0, 5.0]
	prediction := knn.predict(k: 3, to_pred: to_pred)!

	// Print the prediction
	println('Prediction: ${prediction}')

	// Plot the KNN model
	knn.get_plotter().show()!
}
