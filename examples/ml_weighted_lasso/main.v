module main

import vsl.ml

fn main() {
	mut data := ml.Data.from_raw_xy_sep([
		[0.0],
		[1.0],
		[2.0],
	], [1.0, 2.0, 10.0])!
	mut model := ml.Lasso.new(mut data, 'weighted_lasso', 0.25)
	model.train_with_sample_weights([1.0, 2.0, 0.0])!

	println('coefficient: ${model.coef_[0]}')
	println('intercept: ${model.intercept_}')
	println('prediction at 1.5: ${model.predict([1.5])}')
}
