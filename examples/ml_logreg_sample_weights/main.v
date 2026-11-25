module main

import vsl.ml

fn main() {
	// Give the two minority-class observations greater influence.
	mut data := ml.Data.from_raw_xy_sep([
		[0.0],
		[1.0],
		[2.0],
		[3.0],
		[4.0],
		[5.0],
	], [
		0.0,
		0.0,
		0.0,
		1.0,
		1.0,
		1.0,
	])!
	mut model := ml.LogReg.new(mut data, 'weighted_logreg_example')
	weights := [1.0, 1.0, 3.0, 3.0, 1.0, 1.0]

	model.train(epochs: 0, sample_weights: weights)
	println('Initial weighted cost: ${model.cost():.6f}')
	model.train(
		epochs:         1000
		learning_rate:  0.1
		sample_weights: weights
	)
	println('Final weighted cost: ${model.cost():.6f}')

	for feature in [1.0, 2.5, 4.0] {
		probability := model.predict([feature])
		println('x=${feature:.1f}: P(class 1)=${probability:.3f}')
	}
}
