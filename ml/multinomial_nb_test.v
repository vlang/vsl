module ml

import math

fn multinomial_nb_data() !&Data[f64] {
	return Data.from_raw_xy_sep([
		[3.0, 0.0],
		[1.0, 1.0],
		[0.0, 3.0],
		[1.0, 2.0],
	], [20.0, 10.0, 20.0, 10.0])
}

fn test_multinomial_nb_probabilities_and_class_order() ! {
	mut data := multinomial_nb_data()!
	model := MultinomialNB.new(mut data, 'multinomial_nb')!
	assert model.classes() == [10.0, 20.0]
	assert model.class_priors() == [0.5, 0.5]
	log_probabilities := model.feature_log_probabilities()
	assert math.abs(math.exp(log_probabilities[0][0]) - (3.0 / 7.0)) < 1e-12
	assert math.abs(math.exp(log_probabilities[0][1]) - (4.0 / 7.0)) < 1e-12
	assert math.abs(math.exp(log_probabilities[1][0]) - 0.5) < 1e-12
	assert math.abs(math.exp(log_probabilities[1][1]) - 0.5) < 1e-12
	assert model.predict([0.0, 2.0])! == 10.0
	probabilities := model.predict_proba([0.0, 0.0])!
	assert probabilities == [0.5, 0.5]
	log_predictions := model.predict_log_proba([0.0, 0.0])!
	assert math.abs(math.exp(log_predictions[0]) - probabilities[0]) < 1e-12
}

fn test_multinomial_nb_sample_weights_match_duplicated_rows() ! {
	mut weighted_data := Data.from_raw_xy_sep([
		[2.0, 0.0],
		[0.0, 1.0],
		[1.0, 1.0],
	], [0.0, 1.0, 1.0])!
	weighted := MultinomialNB.new_with_config(mut weighted_data, 'weighted',
		MultinomialNBConfig{
			alpha:          0.5
			sample_weights: [2.0, 0.0, 1.0]
		})!
	mut repeated_data := Data.from_raw_xy_sep([
		[2.0, 0.0],
		[2.0, 0.0],
		[1.0, 1.0],
	], [0.0, 0.0, 1.0])!
	repeated := MultinomialNB.new_with_config(mut repeated_data, 'repeated',
		MultinomialNBConfig{
			alpha: 0.5
		})!
	assert weighted.class_priors() == repeated.class_priors()
	assert weighted.feature_log_probabilities() == repeated.feature_log_probabilities()
	assert weighted.predict_proba([1.0, 0.0])! == repeated.predict_proba([1.0, 0.0])!
}

fn test_multinomial_nb_rejects_invalid_data_and_configuration() {
	mut valid_data := multinomial_nb_data()!
	assert multinomial_nb_rejects(mut valid_data, MultinomialNBConfig{
		alpha: -1.0
	})
	assert multinomial_nb_rejects(mut valid_data, MultinomialNBConfig{
		sample_weights: [1.0]
	})
	mut negative_data := Data.from_raw_xy_sep([[1.0], [-1.0]], [0.0, 1.0])!
	assert multinomial_nb_rejects(mut negative_data, MultinomialNBConfig{})
	mut zero_weight_data := Data.from_raw_xy_sep([[1.0], [2.0]], [0.0, 1.0])!
	assert multinomial_nb_rejects(mut zero_weight_data, MultinomialNBConfig{
		sample_weights: [0.0, 0.0]
	})
}

fn test_multinomial_nb_zero_smoothing_preserves_zero_probability_edges() ! {
	mut data := Data.from_raw_xy_sep([[1.0, 0.0], [0.0, 1.0]], [0.0, 1.0])!
	model := MultinomialNB.new_with_config(mut data, 'unsmoothed', MultinomialNBConfig{
		alpha: 0.0
	})!
	assert model.predict_proba([1.0, 0.0])! == [1.0, 0.0]
	if _ := model.predict_proba([1.0, 1.0]) {
		assert false, 'zero-probability evidence for all classes must return an error'
	}
}

fn test_multinomial_nb_ignores_zero_weight_only_classes_without_smoothing() ! {
	mut data_with_zero_weight_class := Data.from_raw_xy_sep([
		[2.0, 0.0],
		[0.0, 2.0],
		[10.0, 0.0],
	], [1.0, 2.0, 0.0])!
	with_zero_weight_class := MultinomialNB.new_with_config(mut data_with_zero_weight_class,
		'zero_weight_class', MultinomialNBConfig{
			alpha:          0.0
			sample_weights: [1.0, 1.0, 0.0]
		})!
	mut data_without_class := Data.from_raw_xy_sep([[2.0, 0.0], [0.0, 2.0]], [1.0, 2.0])!
	without_class := MultinomialNB.new_with_config(mut data_without_class, 'without_class',
		MultinomialNBConfig{
			alpha: 0.0
		})!

	assert with_zero_weight_class.classes() == [1.0, 2.0]
	assert with_zero_weight_class.classes() == without_class.classes()
	assert with_zero_weight_class.class_priors() == without_class.class_priors()
	assert with_zero_weight_class.feature_log_probabilities() == without_class.feature_log_probabilities()
	for features in [[1.0, 0.0], [0.0, 1.0]] {
		assert with_zero_weight_class.predict(features)! == without_class.predict(features)!
		assert with_zero_weight_class.predict_proba(features)! == without_class.predict_proba(features)!
	}
}

fn test_multinomial_nb_normalizes_extreme_finite_counts() ! {
	mut equal_data := Data.from_raw_xy_sep([
		[1.0, 99.0],
		[1.0, 99.0],
		[1.0, 99.0],
		[1.0, 99.0],
	], [0.0, 0.0, 1.0, 1.0])!
	equal_model := MultinomialNB.new(mut equal_data, 'extreme_equal')!
	assert equal_model.predict_proba([1e308, 0.0])! == [0.5, 0.5]

	mut distinct_data := Data.from_raw_xy_sep([
		[1.0, 99.0],
		[1.0, 99.0],
		[99.0, 1.0],
		[99.0, 1.0],
	], [0.0, 0.0, 1.0, 1.0])!
	distinct_model := MultinomialNB.new(mut distinct_data, 'extreme_distinct')!
	assert distinct_model.predict_proba([1e308, 0.0])! == [0.0, 1.0]
}

fn test_multinomial_nb_rejects_predictions_outside_feature_domain() ! {
	mut data := multinomial_nb_data()!
	model := MultinomialNB.new(mut data, 'multinomial_nb_invalid_prediction')!
	if _ := model.predict([-1.0, 0.0]) {
		assert false, 'negative prediction features must be rejected'
	}
	if _ := model.predict([math.nan(), 0.0]) {
		assert false, 'non-finite prediction features must be rejected'
	}
	if _ := model.predict([1.0]) {
		assert false, 'wrong feature counts must be rejected'
	}
}

fn test_multinomial_nb_invalid_observed_update_disables_prediction() {
	mut data := multinomial_nb_data()!
	model := MultinomialNB.new(mut data, 'multinomial_nb_observer')!
	data.set(data.x, [20.0, 10.0, 20.0, 10.0])!
	assert model.predict([0.0, 2.0])! == 10.0
	data.set(data.x, [20.0, 10.0, 20.0, 10.0])!
	data.x.set(0, 0, -1.0)
	data.notify_update()
	if _ := model.predict([0.0, 2.0]) {
		assert false, 'predictions must fail after an invalid observed update'
	}
}

fn multinomial_nb_rejects(mut data Data[f64], config MultinomialNBConfig) bool {
	_ := MultinomialNB.new_with_config(mut data, 'invalid_multinomial_nb', config) or {
		return true
	}
	return false
}
