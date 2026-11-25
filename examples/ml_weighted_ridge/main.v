module main

import vsl.ml

fn main() {
	mut data := ml.Data.from_raw_xy_sep[f64]([[0.0], [1.0], [2.0]], [1.0, 2.0, 4.0])!
	mut model := ml.Ridge.new(mut data, 'weighted_ridge', 0.25)
	model.train_with_sample_weights([1.0, 3.0, 0.0])!

	println('coefficient=${model.coef_[0]}')
	println('intercept=${model.intercept_}')
	println('prediction at x=2: ${model.predict([2.0])}')
}
