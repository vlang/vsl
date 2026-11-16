module main

import vsl.ml

fn main() {
	mut data := ml.Data.from_raw_xy_sep([
		[1.0, 4.0],
		[2.0, 5.0],
		[1.5, 3.0],
		[0.5, 4.5],
		[5.0, 7.0],
		[6.0, 8.0],
		[7.0, 7.5],
		[5.5, 6.5],
	], [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0])!
	mut model := ml.LogReg.new(mut data, 'persisted_student_classifier')
	model.train(epochs: 1000, learning_rate: 0.1)

	model.save_json('student_model.json')!
	loaded := ml.load_logreg_artifact('student_model.json')!
	probability := loaded.predict([4.0, 6.0])!
	println('Probability of passing: ${probability:.4f}')
}
