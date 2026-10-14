import vsl.ml

fn main() {
	mut data := ml.Data.from_raw_xy_sep([
		[-1.0, -1.0],
		[-2.0, -1.0],
		[-3.0, -2.0],
		[1.0, 1.0],
		[2.0, 1.0],
		[3.0, 2.0],
	], [1.0, 1, 1, 2, 2, 2]) or { panic(err) }
	model := ml.GaussianNB.new(mut data, 'gaussian_nb_example') or { panic(err) }

	for sample in [[-0.8, -1.0], [2.0, 1.0]] {
		prediction := model.predict(sample) or { panic(err) }
		probabilities := model.predict_proba(sample) or { panic(err) }
		println('sample=${sample} class=${prediction} class_probabilities=${probabilities}')
	}
}
