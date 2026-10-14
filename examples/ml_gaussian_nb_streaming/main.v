module main

import vsl.ml

fn main() {
	mut model := ml.GaussianNB.new_untrained('streaming_classifier', 2)!
	first_batch := ml.Data.from_raw_xy_sep([
		[-2.0, -1.0],
		[-1.0, -1.0],
	], [0.0, 0.0])!
	second_batch := ml.Data.from_raw_xy_sep([
		[1.0, 1.0],
		[2.0, 1.0],
	], [1.0, 1.0])!
	model.partial_fit(first_batch, ml.GaussianNBPartialFitConfig{
		classes: [0.0, 1.0]
	})!
	model.partial_fit(second_batch, ml.GaussianNBPartialFitConfig{})!
	println('classes: ${model.classes()}')
	println('weighted priors: ${model.class_priors()}')
	println('prediction: ${model.predict([1.5, 1.0])!}')
}
