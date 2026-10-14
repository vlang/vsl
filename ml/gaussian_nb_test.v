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

fn test_gaussian_nb_partial_fit_matches_full_fit_across_batches() {
	mut full_data := gaussian_nb_data()!
	full := GaussianNB.new(mut full_data, 'gaussian_nb_full')!
	mut streamed := GaussianNB.new_untrained('gaussian_nb_streamed', 2)!
	first := Data.from_raw_xy_sep([
		[-1.0, -1.0],
		[-2.0, -1.0],
		[-3.0, -2.0],
	], [1.0, 1, 1])!
	second := Data.from_raw_xy_sep([
		[1.0, 1.0],
		[2.0, 1.0],
		[3.0, 2.0],
	], [2.0, 2, 2])!
	streamed.partial_fit(first, GaussianNBPartialFitConfig{
		classes: [2.0, 1.0]
	})!
	streamed.partial_fit(second, GaussianNBPartialFitConfig{})!
	assert streamed.classes() == full.classes()
	assert streamed.class_counts() == full.class_counts()
	assert streamed.class_priors() == full.class_priors()
	assert streamed.means() == full.means()
	assert streamed.variances() == full.variances()
	assert streamed.predict_proba([-0.8, -1.0])! == full.predict_proba([-0.8, -1.0])!
}

fn test_gaussian_nb_partial_fit_uses_sample_weights() {
	mut model := GaussianNB.new_untrained_with_smoothing('gaussian_nb_weighted', 1, 1e-9)!
	first := Data.from_raw_xy_sep([[0.0], [2.0]], [0.0, 0])!
	second := Data.from_raw_xy_sep([[10.0]], [1.0])!
	model.partial_fit(first, GaussianNBPartialFitConfig{
		classes:        [0.0, 1.0]
		sample_weights: [1.0, 3.0]
	})!
	model.partial_fit(second, GaussianNBPartialFitConfig{
		sample_weights: [2.0]
	})!
	assert model.class_counts() == [2, 1]
	assert model.class_weight_sums() == [4.0, 2.0]
	assert model.class_priors() == [2.0 / 3.0, 1.0 / 3.0]
	assert model.means() == [[1.5], [10.0]]
	assert math.abs(model.epsilon() - (149.0 / 9.0) * 1e-9) < 1e-20
	assert math.abs(model.variances()[0][0] - (0.75 + model.epsilon())) < 1e-12
	assert math.abs(model.variances()[1][0] - model.epsilon()) < 1e-12
}

fn test_gaussian_nb_partial_fit_handles_declared_future_classes_and_zero_weights() {
	mut model := GaussianNB.new_untrained('gaussian_nb_future_class', 1)!
	first := Data.from_raw_xy_sep([[2.0]], [0.0])!
	model.partial_fit(first, GaussianNBPartialFitConfig{
		classes: [0.0, 1.0, 2.0]
	})!
	assert model.classes() == [0.0, 1.0, 2.0]
	assert model.class_priors() == [1.0, 0.0, 0.0]
	before_means := model.means()
	zero_weight := Data.from_raw_xy_sep([[100.0]], [1.0])!
	model.partial_fit(zero_weight, GaussianNBPartialFitConfig{
		sample_weights: [0.0]
	})!
	assert model.means() == before_means
	assert model.class_priors() == [1.0, 0.0, 0.0]
	empty_batch := Data.new[f64](0, 1, true, true)!
	model.partial_fit(empty_batch, GaussianNBPartialFitConfig{})!
	assert model.means() == before_means
	future_class := Data.from_raw_xy_sep([[4.0]], [1.0])!
	model.partial_fit(future_class, GaussianNBPartialFitConfig{})!
	assert model.class_priors() == [0.5, 0.5, 0.0]
}

fn test_gaussian_nb_partial_fit_keeps_large_finite_values_finite() {
	mut model := GaussianNB.new_untrained('gaussian_nb_large_values', 1)!
	batch := Data.from_raw_xy_sep([[1e150], [-1e150]], [0.0, 1.0])!
	model.partial_fit(batch, GaussianNBPartialFitConfig{
		classes: [0.0, 1.0]
	})!
	assert !math.is_nan(model.epsilon())
	assert !math.is_inf(model.epsilon(), 0)
	assert model.means() == [[1e150], [-1e150]]
}

fn test_gaussian_nb_partial_fit_rejects_invalid_updates_without_mutating_model() {
	mut empty_model := GaussianNB.new_untrained('gaussian_nb_zero_weight_first_batch', 1)!
	zero_weight_first_batch := Data.from_raw_xy_sep([[1.0]], [0.0])!
	assert gaussian_nb_partial_fit_rejects(mut empty_model, zero_weight_first_batch,
		GaussianNBPartialFitConfig{
			classes:        [0.0]
			sample_weights: [0.0]
		})
	mut model := GaussianNB.new_untrained('gaussian_nb_invalid_stream', 1)!
	first := Data.from_raw_xy_sep([[0.0], [2.0]], [0.0, 1.0])!
	model.partial_fit(first, GaussianNBPartialFitConfig{
		classes: [0.0, 1.0]
	})!
	before_means := model.means()
	bad_weights := Data.from_raw_xy_sep([[9.0]], [0.0])!
	assert gaussian_nb_partial_fit_rejects(mut model, bad_weights, GaussianNBPartialFitConfig{
		sample_weights: [-1.0]
	})
	assert model.means() == before_means
	assert gaussian_nb_partial_fit_rejects(mut model, first, GaussianNBPartialFitConfig{
		classes: [0.0, 2.0]
	})
	mut observer_backed_data := gaussian_nb_data()!
	mut observer_backed := GaussianNB.new(mut observer_backed_data, 'gaussian_nb_observer_stream')!
	assert gaussian_nb_partial_fit_rejects(mut observer_backed, first, GaussianNBPartialFitConfig{})
}

fn gaussian_nb_partial_fit_rejects(mut model GaussianNB, batch &Data[f64], config GaussianNBPartialFitConfig) bool {
	model.partial_fit(batch, config) or { return true }
	return false
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
