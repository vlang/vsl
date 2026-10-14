module ml

import math
import vsl.errors

// GaussianNB implements a Gaussian Naive Bayes classifier for f64 features and
// numeric class labels. It observes its Data object and refreshes statistics
// when the training data changes.
@[heap]
pub struct GaussianNB {
mut:
	name            string
	data            &Data[f64] = unsafe { nil }
	var_smoothing   f64
	explicit_priors map[f64]f64
	classes         []f64
	class_counts    []int
	class_priors    []f64
	means           [][]f64
	variances       [][]f64
	epsilon         f64
	trained         bool
}

// GaussianNB.new creates and trains a classifier with scikit-learn's default
// variance smoothing value of 1e-9.
pub fn GaussianNB.new(mut data Data[f64], name string) !&GaussianNB {
	return GaussianNB.new_with_smoothing(mut data, name, 1e-9)
}

// GaussianNB.new_with_smoothing creates and trains a Gaussian Naive Bayes classifier.
// `var_smoothing` is multiplied by the largest global feature variance and
// added to each class-feature variance. A positive smoothing value uses that
// value as the variance floor when all training features are constant.
pub fn GaussianNB.new_with_smoothing(mut data Data[f64], name string, var_smoothing f64) !&GaussianNB {
	if math.is_nan(var_smoothing) || math.is_inf(var_smoothing, 0) || var_smoothing < 0.0 {
		return errors.error('var_smoothing must be finite and non-negative', .einval)
	}
	mut model := &GaussianNB{
		name:          name
		data:          data
		var_smoothing: var_smoothing
	}
	model.train()!
	data.add_observer(model)
	return model
}

// name returns this model's observer name.
pub fn (model &GaussianNB) name() string {
	return model.name
}

// update recomputes the learned statistics after the observed data changes.
pub fn (mut model GaussianNB) update() {
	model.train() or {
		model.trained = false
	}
}

// train computes class means, population variances, and prior probabilities.
pub fn (mut model GaussianNB) train() ! {
	model.trained = false
	if model.data.nb_samples <= 0 || model.data.nb_features <= 0 {
		return errors.error('GaussianNB requires at least one sample and one feature', .einval)
	}
	if model.data.y.len != model.data.nb_samples || model.data.x.m != model.data.nb_samples
		|| model.data.x.n != model.data.nb_features {
		return errors.error('GaussianNB expects matching X and y dimensions', .einval)
	}

	mut classes := model.data.y.clone()
	for label in classes {
		if math.is_nan(label) || math.is_inf(label, 0) {
			return errors.error('GaussianNB class labels must be finite', .einval)
		}
	}
	classes.sort()
	mut unique_classes := []f64{cap: classes.len}
	for label in classes {
		if unique_classes.len == 0 || unique_classes[unique_classes.len - 1] != label {
			unique_classes << label
		}
	}

	n_classes := unique_classes.len
	n_features := model.data.nb_features
	mut class_index := map[f64]int{}
	for i, label in unique_classes {
		class_index[label] = i
	}
	mut counts := []int{len: n_classes}
	mut means := [][]f64{len: n_classes}
	mut m2 := [][]f64{len: n_classes}
	for i in 0 .. n_classes {
		means[i] = []f64{len: n_features}
		m2[i] = []f64{len: n_features}
	}
	mut global_mean := []f64{len: n_features}
	mut global_m2 := []f64{len: n_features}
	for row in 0 .. model.data.nb_samples {
		label := model.data.y[row]
		idx := class_index[label]
		counts[idx]++
		count := f64(counts[idx])
		for col in 0 .. n_features {
			value := model.data.x.get(row, col)
			if math.is_nan(value) || math.is_inf(value, 0) {
				return errors.error('GaussianNB feature values must be finite', .einval)
			}
			delta := value - means[idx][col]
			means[idx][col] += delta / count
			m2[idx][col] += delta * (value - means[idx][col])
			global_mean[col] += value
		}
	}
	for col in 0 .. n_features {
		global_mean[col] /= f64(model.data.nb_samples)
	}
	for row in 0 .. model.data.nb_samples {
		for col in 0 .. n_features {
			delta := model.data.x.get(row, col) - global_mean[col]
			global_m2[col] += delta * delta
		}
	}

	mut max_global_variance := 0.0
	for col in 0 .. n_features {
		variance := global_m2[col] / f64(model.data.nb_samples)
		if math.is_nan(variance) || math.is_inf(variance, 0) || variance < 0.0 {
			return errors.error('GaussianNB global feature variances must be finite', .einval)
		}
		if variance > max_global_variance {
			max_global_variance = variance
		}
	}
	epsilon := if max_global_variance == 0.0 && model.var_smoothing > 0.0 {
		model.var_smoothing
	} else {
		max_global_variance * model.var_smoothing
	}
	if math.is_nan(epsilon) || math.is_inf(epsilon, 0) {
		return errors.error('GaussianNB variance smoothing overflowed', .einval)
	}
	mut variances := [][]f64{len: n_classes}
	mut priors := []f64{len: n_classes}
	for i in 0 .. n_classes {
		variances[i] = []f64{len: n_features}
		priors[i] = f64(counts[i]) / f64(model.data.nb_samples)
		for col in 0 .. n_features {
			variance := m2[i][col] / f64(counts[i]) + epsilon
			if math.is_nan(variance) || math.is_inf(variance, 0) || variance <= 0.0 {
				return errors.error('GaussianNB needs positive finite variances; increase var_smoothing',
					.einval)
			}
			variances[i][col] = variance
		}
	}
	if model.explicit_priors.len > 0 {
		if model.explicit_priors.len != n_classes {
			return errors.error('class priors must contain exactly one entry per observed class',
				.einval)
		}
		mut sum := 0.0
		for i, label in unique_classes {
			if label !in model.explicit_priors {
				return errors.error('class priors must contain every observed class', .einval)
			}
			prior := model.explicit_priors[label]
			if math.is_nan(prior) || math.is_inf(prior, 0) || prior < 0.0 {
				return errors.error('class priors must be finite and non-negative', .einval)
			}
			priors[i] = prior
			sum += prior
		}
		if math.abs(sum - 1.0) > 1e-12 {
			return errors.error('class priors must sum to 1', .einval)
		}
	}
	model.classes = unique_classes
	model.class_counts = counts
	model.class_priors = priors
	model.means = means
	model.variances = variances
	model.epsilon = epsilon
	model.trained = true
}

// set_priors overrides the empirical class priors. The map must contain all
// observed classes and its values must sum to one.
pub fn (mut model GaussianNB) set_priors(priors map[f64]f64) ! {
	if !model.trained {
		return errors.error('GaussianNB must be trained before setting class priors', .efailed)
	}
	if priors.len != model.classes.len {
		return errors.error('class priors must contain exactly one entry per observed class',
			.einval)
	}
	mut sum := 0.0
	for label in model.classes {
		if label !in priors {
			return errors.error('class priors must contain every observed class', .einval)
		}
		prior := priors[label]
		if math.is_nan(prior) || math.is_inf(prior, 0) || prior < 0.0 {
			return errors.error('class priors must be finite and non-negative', .einval)
		}
		sum += prior
	}
	if math.abs(sum - 1.0) > 1e-12 {
		return errors.error('class priors must sum to 1', .einval)
	}
	model.explicit_priors = priors.clone()
	for i, label in model.classes {
		model.class_priors[i] = priors[label]
	}
}

// clear_priors removes a prior override and retrains with empirical class
// frequencies. It can recover a model after observed data changes its classes.
pub fn (mut model GaussianNB) clear_priors() ! {
	model.explicit_priors = map[f64]f64{}
	model.train()!
}

// predict_log_proba returns normalized log probabilities in ascending class order.
pub fn (model &GaussianNB) predict_log_proba(x []f64) ![]f64 {
	if !model.trained {
		return errors.error('GaussianNB is not trained', .efailed)
	}
	if x.len != model.data.nb_features {
		return errors.error('predict expects ${model.data.nb_features} features, got ${x.len}',
			.einval)
	}
	mut scores := []f64{len: model.classes.len}
	mut max_score := -math.inf(1)
	for class_idx in 0 .. model.classes.len {
		prior := model.class_priors[class_idx]
		if prior == 0.0 {
			scores[class_idx] = -math.inf(1)
			continue
		}
		score := math.log(prior)
		mut likelihood := 0.0
		for feature_idx, value in x {
			if math.is_nan(value) || math.is_inf(value, 0) {
				return errors.error('prediction features must be finite', .einval)
			}
			variance := model.variances[class_idx][feature_idx]
			delta := value - model.means[class_idx][feature_idx]
			likelihood += -0.5 * (math.log(2.0 * math.pi * variance) + delta * delta / variance)
		}
		scores[class_idx] = score + likelihood
		if scores[class_idx] > max_score {
			max_score = scores[class_idx]
		}
	}
	mut exp_sum := 0.0
	for score in scores {
		exp_sum += math.exp(score - max_score)
	}
	if exp_sum <= 0.0 || math.is_nan(exp_sum) || math.is_inf(exp_sum, 0) {
		return errors.error('GaussianNB could not normalize class probabilities', .efailed)
	}
	log_norm := max_score + math.log(exp_sum)
	for i in 0 .. scores.len {
		scores[i] -= log_norm
	}
	return scores
}

// predict_proba returns class probabilities in ascending class order.
pub fn (model &GaussianNB) predict_proba(x []f64) ![]f64 {
	log_probabilities := model.predict_log_proba(x)!
	mut probabilities := []f64{len: log_probabilities.len}
	for i, value in log_probabilities {
		probabilities[i] = math.exp(value)
	}
	return probabilities
}

// predict returns the class with the greatest posterior probability.
pub fn (model &GaussianNB) predict(x []f64) !f64 {
	log_probabilities := model.predict_log_proba(x)!
	mut best_idx := 0
	for i in 1 .. log_probabilities.len {
		if log_probabilities[i] > log_probabilities[best_idx] {
			best_idx = i
		}
	}
	return model.classes[best_idx]
}

// classes returns the sorted class labels known to the model.
pub fn (model &GaussianNB) classes() []f64 {
	return model.classes.clone()
}

// class_counts returns the number of training samples for each sorted class.
pub fn (model &GaussianNB) class_counts() []int {
	return model.class_counts.clone()
}

// class_priors returns the prior probability for each sorted class.
pub fn (model &GaussianNB) class_priors() []f64 {
	return model.class_priors.clone()
}

// means returns a copy of the learned means in [class][feature] order.
pub fn (model &GaussianNB) means() [][]f64 {
	return model.means.map(it.clone())
}

// variances returns a copy of the smoothed variances in [class][feature] order.
pub fn (model &GaussianNB) variances() [][]f64 {
	return model.variances.map(it.clone())
}

// epsilon returns the additive variance smoothing value used by the model.
pub fn (model &GaussianNB) epsilon() f64 {
	return model.epsilon
}
