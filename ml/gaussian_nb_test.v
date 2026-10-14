module ml

import math
import vsl.la

fn gaussian_nb_data() !&Data[f64] {
	x := [
		[-1.0, -1.0],
		[-2.0, -1.0],
		[-3.0, -2.0],
		[1.0, 1.0],
		[2.0, 1.0],
		[3.0, 2.0],
	]
	y := [1.0, 1, 1, 2, 2, 2]
	return Data.from_raw_xy_sep(x, y)
}

fn test_gaussian_nb_predict_and_probabilities() {
	mut data := gaussian_nb_data()!
	model := GaussianNB.new(mut data, 'gaussian_nb')!
	assert model.classes() == [1.0, 2.0]
	assert model.class_counts() == [3, 3]
	assert model.class_priors() == [0.5, 0.5]
	assert math.abs(model.epsilon() - (14.0 / 3.0) * 1e-9) < 1e-15
	assert model.predict([-0.8, -1.0])! == 1.0
	assert model.predict([2.0, 1.0])! == 2.0
	probabilities := model.predict_proba([-0.8, -1.0])!
	assert probabilities.len == 2
	assert math.abs(probabilities[0] + probabilities[1] - 1.0) < 1e-12
	assert probabilities[0] > probabilities[1]
	assert math.abs(probabilities[0] - 0.9999999494346746) < 1e-14
	log_probabilities := model.predict_log_proba([-0.8, -1.0])!
	assert math.abs(math.exp(log_probabilities[0]) - probabilities[0]) < 1e-12
}

fn test_gaussian_nb_matches_population_statistics_and_smoothing() {
	mut data := gaussian_nb_data()!
	model := GaussianNB.new_with_smoothing(mut data, 'gaussian_nb_stats', 1e-9)!
	means := model.means()
	variances := model.variances()
	assert means == [[-2.0, -4.0 / 3.0], [2.0, 4.0 / 3.0]]
	assert math.abs(model.epsilon() - (14.0 / 3.0) * 1e-9) < 1e-15
	assert math.abs(variances[0][0] - (2.0 / 3.0 + model.epsilon())) < 1e-12
	assert math.abs(variances[1][1] - (2.0 / 9.0 + model.epsilon())) < 1e-12
}

fn test_gaussian_nb_explicit_priors() {
	mut data := gaussian_nb_data()!
	mut model := GaussianNB.new_with_smoothing(mut data, 'gaussian_nb_priors', 1e-9)!
	model.set_priors({
		1.0: 0.8
		2.0: 0.2
	})!
	assert model.class_priors() == [0.8, 0.2]
	assert model.predict([0.0, 0.0])! == 1.0
	assert gaussian_nb_rejects_priors(mut model, {
		1.0: 0.5
		2.0: 0.6
	})
}

fn test_gaussian_nb_constant_features_use_finite_variance_floor() {
	x := [[4.0], [4.0], [4.0], [4.0]]
	y := [2.0, 2.0, 9.0, 9.0]
	mut data := Data.from_raw_xy_sep(x, y)!
	model := GaussianNB.new_with_smoothing(mut data, 'gaussian_nb_constant', 1e-9)!
	assert model.epsilon() == 1e-9
	assert model.predict([4.0])! == 2.0
	probs := model.predict_proba([4.0])!
	assert math.abs(probs[0] - 0.5) < 1e-12
}

fn test_gaussian_nb_zero_smoothing_for_non_degenerate_data() {
	mut data := gaussian_nb_data()!
	model := GaussianNB.new_with_smoothing(mut data, 'gaussian_nb_no_smoothing', 0.0)!
	assert model.epsilon() == 0.0
	assert model.predict([-0.8, -1.0])! == 1.0
}

fn test_gaussian_nb_tracks_data_updates() {
	mut data := gaussian_nb_data()!
	model := GaussianNB.new_with_smoothing(mut data, 'gaussian_nb_observer', 1e-9)!
	new_x := [[-1.0], [-2.0], [1.0], [2.0], [3.0]]
	new_y := [3.0, 3, 8, 8, 8]
	data.set(la.Matrix.deep2(new_x), new_y)!
	assert model.classes() == [3.0, 8.0]
	assert model.class_counts() == [2, 3]
	assert model.class_priors() == [0.4, 0.6]
}

fn test_gaussian_nb_can_clear_priors_after_classes_change() {
	mut data := gaussian_nb_data()!
	mut model := GaussianNB.new_with_smoothing(mut data, 'gaussian_nb_class_change', 1e-9)!
	model.set_priors({
		1.0: 0.5
		2.0: 0.5
	})!
	data.set(la.Matrix.deep2([[-1.0], [1.0], [2.0]]), [3.0, 8.0, 8.0])!
	assert gaussian_nb_rejects_prediction(model, [0.0])
	model.clear_priors()!
	assert model.classes() == [3.0, 8.0]
	assert model.class_priors() == [1.0 / 3.0, 2.0 / 3.0]
	assert model.predict([1.0])! == 8.0
}

fn test_gaussian_nb_rejects_predictions_after_invalid_observed_update() {
	mut data := gaussian_nb_data()!
	mut model := GaussianNB.new_with_smoothing(mut data, 'gaussian_nb_invalid_update', 1e-9)!
	new_y := [1.0, 1, 1, 2, math.nan(), 2]
	data.set(data.x, new_y)!
	assert gaussian_nb_rejects_prediction(model, [-0.5, -0.5])
}

fn test_gaussian_nb_rejects_invalid_inputs() {
	mut data := gaussian_nb_data()!
	assert gaussian_nb_rejects_smoothing(mut data, -1.0)
	mut model := GaussianNB.new_with_smoothing(mut data, 'gaussian_nb_invalid', 1e-9)!
	assert gaussian_nb_rejects_prediction(model, [1.0])
	assert gaussian_nb_rejects_prediction(model, [math.inf(1), 0.0])
	assert gaussian_nb_rejects_priors(mut model, {
		1.0: 0.5
		9.0: 0.5
	})
}

fn gaussian_nb_rejects_smoothing(mut data Data[f64], smoothing f64) bool {
	_ := GaussianNB.new_with_smoothing(mut data, 'bad_smoothing', smoothing) or { return true }
	return false
}

fn gaussian_nb_rejects_prediction(model &GaussianNB, x []f64) bool {
	_ := model.predict(x) or { return true }
	return false
}

fn gaussian_nb_rejects_priors(mut model GaussianNB, priors map[f64]f64) bool {
	model.set_priors(priors) or { return true }
	return false
}
