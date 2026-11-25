module main

import vsl.ml

fn main() {
	mut data := ml.Data.from_raw_xy_sep([
		[3.0, 0.0],
		[1.0, 1.0],
		[0.0, 3.0],
		[1.0, 2.0],
	], [0.0, 0.0, 1.0, 1.0])!
	mut model := ml.MultinomialNB.new_with_config(mut data, 'word_counts',
		ml.MultinomialNBConfig{
			alpha:          1.0
			sample_weights: [1.0, 1.0, 1.0, 1.0]
		})!
	println('classes: ${model.classes()}')
	println('priors: ${model.class_priors()}')
	println('prediction: ${model.predict([2.0, 0.0])!}')
	println('probabilities: ${model.predict_proba([2.0, 0.0])!}')
}
