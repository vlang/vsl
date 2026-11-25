module main

import vsl.ml

fn main() {
	training := [
		[0.0],
		[2.0],
		[4.0],
	]
	targets := [0.0, 20.0, 40.0]
	uniform_model := ml.KNNRegressor.new(training, targets, k: 2)!
	distance_model := ml.KNNRegressor.new(training, targets, k: 2, weighting: .distance)!

	query := [1.0]
	println('uniform prediction: ${uniform_model.predict(query)!}')
	println('distance-weighted prediction: ${distance_model.predict(query)!}')
}
