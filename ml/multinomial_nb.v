module ml

import math
import vsl.errors

// MultinomialNBConfig controls smoothing and optional per-sample weights.
pub struct MultinomialNBConfig {
pub:
	alpha          f64 = 1.0
	sample_weights []f64
}

struct MultinomialNBDerived {
	classes           []f64
	class_weight_sums []f64
	class_log_priors  []f64
	feature_log_probs [][]f64
}

// MultinomialNB implements a multinomial Naive Bayes classifier for
// non-negative f64 features and finite numeric class labels.
@[heap]
pub struct MultinomialNB {
mut:
	name              string
	data              &Data[f64] = unsafe { nil }
	config            MultinomialNBConfig
	n_features        int
	classes           []f64
	class_weight_sums []f64
	class_log_priors  []f64
	feature_log_probs [][]f64
	trained           bool
}

// MultinomialNB.new creates and trains a classifier with Laplace smoothing.
pub fn MultinomialNB.new(mut data Data[f64], name string) !&MultinomialNB {
	return MultinomialNB.new_with_config(mut data, name, MultinomialNBConfig{})
}

// MultinomialNB.new_with_config creates and trains a classifier. `alpha` must
// be finite and non-negative; an empty sample_weights slice means unit weights.
pub fn MultinomialNB.new_with_config(mut data Data[f64], name string, config MultinomialNBConfig) !&MultinomialNB {
	mut model := &MultinomialNB{
		name:   name
		data:   data
		config: MultinomialNBConfig{
			alpha:          config.alpha
			sample_weights: config.sample_weights.clone()
		}
	}
	model.train()!
	data.add_observer(model)
	return model
}

// name returns this model's observer name.
pub fn (model &MultinomialNB) name() string {
	return model.name
}

// update recomputes the learned statistics after the observed data changes.
pub fn (mut model MultinomialNB) update() {
	model.train() or {
		model.trained = false
	}
}

// train recomputes class and feature probabilities from the observed dataset.
pub fn (mut model MultinomialNB) train() ! {
	model.trained = false
	if model.data == unsafe { nil } {
		return errors.error('train requires a MultinomialNB created with a Data object',
			.efailed)
	}
	derived := multinomial_nb_derive(model.data, model.config)!
	model.n_features = model.data.nb_features
	model.classes = derived.classes
	model.class_weight_sums = derived.class_weight_sums
	model.class_log_priors = derived.class_log_priors
	model.feature_log_probs = derived.feature_log_probs
	model.trained = true
}

fn multinomial_nb_derive(data &Data[f64], config MultinomialNBConfig) !MultinomialNBDerived {
	if math.is_nan(config.alpha) || math.is_inf(config.alpha, 0) || config.alpha < 0.0 {
		return errors.error('alpha must be finite and non-negative', .einval)
	}
	if data.nb_samples <= 0 || data.nb_features <= 0 || data.x == unsafe { nil } {
		return errors.error('MultinomialNB requires at least one sample and one feature', .einval)
	}
	if data.x.m != data.nb_samples || data.x.n != data.nb_features || data.y.len != data.nb_samples {
		return errors.error('MultinomialNB data must have matching X and y dimensions', .einval)
	}
	if config.sample_weights.len != 0 && config.sample_weights.len != data.nb_samples {
		return errors.error('sample_weights must be empty or match the number of samples', .einval)
	}

	mut classes := data.y.clone()
	for label in classes {
		if math.is_nan(label) || math.is_inf(label, 0) {
			return errors.error('class labels must be finite', .einval)
		}
	}
	classes.sort()
	mut unique_classes := []f64{cap: classes.len}
	for label in classes {
		if unique_classes.len == 0 || label != unique_classes[unique_classes.len - 1] {
			unique_classes << label
		}
	}

	mut class_indices := map[f64]int{}
	for index, label in unique_classes {
		class_indices[label] = index
	}
	mut class_weight_sums := []f64{len: unique_classes.len}
	mut feature_counts := [][]f64{len: unique_classes.len}
	for index in 0 .. unique_classes.len {
		feature_counts[index] = []f64{len: data.nb_features}
	}
	mut total_weight := 0.0
	for row in 0 .. data.nb_samples {
		weight := if config.sample_weights.len == 0 {
			1.0
		} else {
			config.sample_weights[row]
		}
		if math.is_nan(weight) || math.is_inf(weight, 0) || weight < 0.0 {
			return errors.error('sample weights must be finite and non-negative', .einval)
		}
		total_weight += weight
		if math.is_inf(total_weight, 0) {
			return errors.error('sum of sample weights overflowed', .einval)
		}
		class_index := class_indices[data.y[row]]
		class_weight_sums[class_index] += weight
		if math.is_inf(class_weight_sums[class_index], 0) {
			return errors.error('cumulative class sample weights overflowed', .einval)
		}
		for column in 0 .. data.nb_features {
			value := data.x.get(row, column)
			if math.is_nan(value) || math.is_inf(value, 0) || value < 0.0 {
				return errors.error('MultinomialNB features must be finite and non-negative',
					.einval)
			}
			weighted_value := weight * value
			new_count := feature_counts[class_index][column] + weighted_value
			if math.is_nan(new_count) || math.is_inf(new_count, 0) {
				return errors.error('MultinomialNB feature counts overflowed', .einval)
			}
			feature_counts[class_index][column] = new_count
		}
	}
	if total_weight <= 0.0 {
		return errors.error('MultinomialNB requires positive total sample weight', .einval)
	}

	mut fitted_classes := []f64{cap: unique_classes.len}
	mut fitted_class_weight_sums := []f64{cap: unique_classes.len}
	mut fitted_feature_counts := [][]f64{cap: unique_classes.len}
	for class_index, class_weight in class_weight_sums {
		if class_weight > 0.0 {
			fitted_classes << unique_classes[class_index]
			fitted_class_weight_sums << class_weight
			fitted_feature_counts << feature_counts[class_index]
		}
	}

	mut class_log_priors := []f64{len: fitted_classes.len}
	mut feature_log_probs := [][]f64{len: fitted_classes.len}
	for class_index in 0 .. fitted_classes.len {
		class_weight := fitted_class_weight_sums[class_index]
		class_log_priors[class_index] = if class_weight > 0.0 {
			math.log(class_weight / total_weight)
		} else {
			-math.inf(1)
		}
		feature_log_probs[class_index] = []f64{len: data.nb_features}
		mut feature_total := 0.0
		for count in fitted_feature_counts[class_index] {
			feature_total += count
			if math.is_inf(feature_total, 0) {
				return errors.error('MultinomialNB class feature counts overflowed', .einval)
			}
		}
		alpha_total := config.alpha * f64(data.nb_features)
		denominator := feature_total + alpha_total
		if denominator <= 0.0 || math.is_inf(denominator, 0) {
			return errors.error('MultinomialNB needs positive finite feature mass or alpha',
				.einval)
		}
		for column, count in fitted_feature_counts[class_index] {
			smoothed_count := count + config.alpha
			feature_log_probs[class_index][column] = if smoothed_count > 0.0 {
				math.log(smoothed_count / denominator)
			} else {
				-math.inf(1)
			}
		}
	}
	return MultinomialNBDerived{
		classes:           fitted_classes
		class_weight_sums: fitted_class_weight_sums
		class_log_priors:  class_log_priors
		feature_log_probs: feature_log_probs
	}
}

// predict_log_proba returns normalized log probabilities in ascending class order.
pub fn (model &MultinomialNB) predict_log_proba(x []f64) ![]f64 {
	if !model.trained {
		return errors.error('MultinomialNB is not trained', .efailed)
	}
	if x.len != model.n_features {
		return errors.error('predict expects ${model.n_features} features, got ${x.len}',
			.einval)
	}
	for value in x {
		if math.is_nan(value) || math.is_inf(value, 0) || value < 0.0 {
			return errors.error('prediction features must be finite and non-negative', .einval)
		}
	}
	mut max_input := 1.0
	for value in x {
		if value > max_input {
			max_input = value
		}
	}
	mut feature_log_prob_maxima := []f64{len: model.n_features}
	for column in 0 .. model.n_features {
		mut maximum := -math.inf(1)
		for class_index in 0 .. model.classes.len {
			value := model.feature_log_probs[class_index][column]
			if value > maximum {
				maximum = value
			}
		}
		feature_log_prob_maxima[column] = maximum
	}
	mut scores := []f64{len: model.classes.len}
	mut max_score := -math.inf(1)
	for class_index in 0 .. model.classes.len {
		score := model.class_log_priors[class_index]
		if score == -math.inf(1) {
			scores[class_index] = score
			continue
		}
		mut joint := score / max_input
		for column, value in x {
			if value > 0.0 {
				maximum := feature_log_prob_maxima[column]
				if maximum == -math.inf(1) {
					joint = -math.inf(1)
					break
				}
				joint += (value / max_input) * (model.feature_log_probs[class_index][column] -
					maximum)
			}
		}
		scores[class_index] = joint
		if joint > max_score {
			max_score = joint
		}
	}
	if max_score == -math.inf(1) {
		return errors.error('MultinomialNB could not normalize class probabilities', .efailed)
	}
	mut exp_sum := 0.0
	for score in scores {
		scaled_difference := score - max_score
		exp_sum += math.exp(scaled_difference * max_input)
	}
	if exp_sum <= 0.0 || math.is_nan(exp_sum) || math.is_inf(exp_sum, 0) {
		return errors.error('MultinomialNB could not normalize class probabilities', .efailed)
	}
	log_norm := math.log(exp_sum)
	for index in 0 .. scores.len {
		if scores[index] == -math.inf(1) {
			continue
		}
		log_probability := (scores[index] - max_score) * max_input - log_norm
		scores[index] = if math.is_inf(log_probability, -1) {
			-math.inf(1)
		} else {
			log_probability
		}
	}
	return scores
}

// predict_proba returns class probabilities in ascending class order.
pub fn (model &MultinomialNB) predict_proba(x []f64) ![]f64 {
	log_probabilities := model.predict_log_proba(x)!
	mut probabilities := []f64{len: log_probabilities.len}
	for index, value in log_probabilities {
		probabilities[index] = math.exp(value)
	}
	return probabilities
}

// predict returns the class with the greatest posterior probability.
pub fn (model &MultinomialNB) predict(x []f64) !f64 {
	log_probabilities := model.predict_log_proba(x)!
	mut best_index := 0
	for index in 1 .. log_probabilities.len {
		if log_probabilities[index] > log_probabilities[best_index] {
			best_index = index
		}
	}
	return model.classes[best_index]
}

// classes returns the sorted class labels known to the model.
pub fn (model &MultinomialNB) classes() []f64 {
	return model.classes.clone()
}

// class_weight_sums returns the accumulated sample weight for each sorted class.
pub fn (model &MultinomialNB) class_weight_sums() []f64 {
	return model.class_weight_sums.clone()
}

// class_priors returns the prior probability for each sorted class.
pub fn (model &MultinomialNB) class_priors() []f64 {
	return model.class_log_priors.map(math.exp(it))
}

// feature_log_probabilities returns a copy in [class][feature] order.
pub fn (model &MultinomialNB) feature_log_probabilities() [][]f64 {
	return model.feature_log_probs.map(it.clone())
}
