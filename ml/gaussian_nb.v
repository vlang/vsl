module ml

import math
import vsl.errors

// GaussianNBPartialFitConfig controls one incremental training update.
pub struct GaussianNBPartialFitConfig {
pub:
	// classes declares every possible class on the first update. Later updates
	// may leave it empty or repeat the same class set.
	classes []f64
	// sample_weights is empty for unit weights or has one non-negative value per row.
	sample_weights []f64
}

struct GaussianNBDerived {
	epsilon   f64
	priors    []f64
	variances [][]f64
}

// GaussianNB implements a Gaussian Naive Bayes classifier for f64 features and
// numeric class labels. It observes its Data object and refreshes statistics
// when the training data changes.
@[heap]
pub struct GaussianNB {
mut:
	name              string
	data              &Data[f64] = unsafe { nil }
	n_features        int
	observer_backed   bool
	var_smoothing     f64
	explicit_priors   map[f64]f64
	classes           []f64
	class_counts      []int
	class_weight_sums []f64
	class_priors      []f64
	means             [][]f64
	class_m2          [][]f64
	variances         [][]f64
	global_weight_sum f64
	global_mean       []f64
	global_m2         []f64
	epsilon           f64
	trained           bool
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
		name:            name
		data:            data
		n_features:      data.nb_features
		observer_backed: true
		var_smoothing:   var_smoothing
	}
	model.train()!
	data.add_observer(model)
	return model
}

// GaussianNB.new_untrained creates an empty classifier for incremental fitting.
pub fn GaussianNB.new_untrained(name string, n_features int) !&GaussianNB {
	return GaussianNB.new_untrained_with_smoothing(name, n_features, 1e-9)
}

// GaussianNB.new_untrained_with_smoothing creates an empty classifier with a
// caller-selected variance smoothing value.
pub fn GaussianNB.new_untrained_with_smoothing(name string, n_features int, var_smoothing f64) !&GaussianNB {
	if n_features <= 0 {
		return errors.error('GaussianNB requires at least one feature', .einval)
	}
	if math.is_nan(var_smoothing) || math.is_inf(var_smoothing, 0) || var_smoothing < 0.0 {
		return errors.error('var_smoothing must be finite and non-negative', .einval)
	}
	return &GaussianNB{
		name:          name
		n_features:    n_features
		var_smoothing: var_smoothing
	}
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

// train recomputes class statistics from the model's observed full dataset.
pub fn (mut model GaussianNB) train() ! {
	model.trained = false
	if !model.observer_backed || model.data == unsafe { nil } {
		return errors.error('train requires a GaussianNB created with a Data object', .efailed)
	}
	if model.data.nb_samples <= 0 || model.data.nb_features <= 0 {
		return errors.error('GaussianNB requires at least one sample and one feature', .einval)
	}
	classes := gaussian_nb_unique_classes(model.data.y)!
	gaussian_nb_validate_batch(model.data, model.data.nb_features, classes, []f64{}, true)!
	model.n_features = model.data.nb_features
	model.reset_statistics(classes)
	model.merge_batch(model.data, []f64{})!
}

// partial_fit incorporates one batch into an untrained incremental model. The
// model stores only sufficient statistics; it does not retain the batch data.
pub fn (mut model GaussianNB) partial_fit(batch &Data[f64], config GaussianNBPartialFitConfig) ! {
	if model.observer_backed {
		return errors.error('partial_fit requires a model created with new_untrained', .einval)
	}
	first_batch := model.classes.len == 0
	mut classes := model.classes.clone()
	if first_batch {
		classes = gaussian_nb_unique_classes(config.classes)!
		if classes.len != config.classes.len {
			return errors.error('GaussianNB class declarations must be unique', .einval)
		}
	} else if config.classes.len > 0 {
		declared := gaussian_nb_unique_classes(config.classes)!
		if declared.len != config.classes.len {
			return errors.error('GaussianNB class declarations must be unique', .einval)
		}
		if declared.len != model.classes.len {
			return errors.error('classes must match the class set declared on the first update',
				.einval)
		}
		for i, label in declared {
			if label != model.classes[i] {
				return errors.error('classes must match the class set declared on the first update',
					.einval)
			}
		}
	}
	gaussian_nb_validate_batch(batch, model.n_features, classes, config.sample_weights,
		first_batch)!
	if first_batch {
		model.reset_statistics(classes)
	}
	model.merge_batch(batch, config.sample_weights) or {
		if first_batch {
			model.reset_statistics([]f64{})
		}
		return err
	}
}

fn (mut model GaussianNB) reset_statistics(classes []f64) {
	model.trained = false
	model.classes = classes.clone()
	model.class_counts = []int{len: classes.len}
	model.class_weight_sums = []f64{len: classes.len}
	model.class_priors = []f64{len: classes.len}
	model.means = [][]f64{len: classes.len}
	model.class_m2 = [][]f64{len: classes.len}
	model.variances = [][]f64{len: classes.len}
	for i in 0 .. classes.len {
		model.means[i] = []f64{len: model.n_features}
		model.class_m2[i] = []f64{len: model.n_features}
		model.variances[i] = []f64{len: model.n_features}
	}
	model.global_weight_sum = 0.0
	model.global_mean = []f64{len: model.n_features}
	model.global_m2 = []f64{len: model.n_features}
	model.epsilon = 0.0
}

fn (mut model GaussianNB) merge_batch(batch &Data[f64], sample_weights []f64) ! {
	if batch.nb_samples == 0 {
		return
	}
	mut class_index := map[f64]int{}
	for i, label in model.classes {
		class_index[label] = i
	}
	mut counts := model.class_counts.clone()
	mut weight_sums := model.class_weight_sums.clone()
	mut means := model.means.map(it.clone())
	mut class_m2 := model.class_m2.map(it.clone())
	mut global_weight_sum := model.global_weight_sum
	mut global_mean := model.global_mean.clone()
	mut global_m2 := model.global_m2.clone()
	for row in 0 .. batch.nb_samples {
		idx := class_index[batch.y[row]]
		counts[idx]++
		weight := if sample_weights.len == 0 { 1.0 } else { sample_weights[row] }
		if weight == 0.0 {
			continue
		}
		new_class_weight := weight_sums[idx] + weight
		new_global_weight := global_weight_sum + weight
		if math.is_inf(new_class_weight, 0) || math.is_inf(new_global_weight, 0) {
			return errors.error('GaussianNB cumulative sample weights overflowed', .einval)
		}
		for col in 0 .. model.n_features {
			value := batch.x.get(row, col)
			class_delta := value - means[idx][col]
			means[idx][col] += class_delta * (weight / new_class_weight)
			class_m2[idx][col] += weight * class_delta * (value - means[idx][col])
			global_delta := value - global_mean[col]
			global_mean[col] += global_delta * (weight / new_global_weight)
			global_m2[col] += weight * global_delta * (value - global_mean[col])
			if math.is_nan(means[idx][col]) || math.is_inf(means[idx][col], 0)
				|| math.is_nan(class_m2[idx][col]) || math.is_inf(class_m2[idx][col], 0)
				|| math.is_nan(global_mean[col]) || math.is_inf(global_mean[col], 0)
				|| math.is_nan(global_m2[col]) || math.is_inf(global_m2[col], 0) {
				return errors.error('GaussianNB sufficient statistics overflowed', .einval)
			}
		}
		weight_sums[idx] = new_class_weight
		global_weight_sum = new_global_weight
	}
	derived := gaussian_nb_derive(model.classes, weight_sums, class_m2,
		global_weight_sum, global_m2, model.var_smoothing, model.explicit_priors)!
	model.class_counts = counts
	model.class_weight_sums = weight_sums
	model.means = means
	model.class_m2 = class_m2
	model.global_weight_sum = global_weight_sum
	model.global_mean = global_mean
	model.global_m2 = global_m2
	model.class_priors = derived.priors
	model.variances = derived.variances
	model.epsilon = derived.epsilon
	model.trained = true
}

fn (mut model GaussianNB) refresh_derived() ! {
	derived := gaussian_nb_derive(model.classes, model.class_weight_sums, model.class_m2,
		model.global_weight_sum, model.global_m2, model.var_smoothing,
		model.explicit_priors)!
	model.class_priors = derived.priors
	model.variances = derived.variances
	model.epsilon = derived.epsilon
	model.trained = true
}

fn gaussian_nb_unique_classes(labels []f64) ![]f64 {
	if labels.len == 0 {
		return errors.error('GaussianNB requires at least one declared class', .einval)
	}
	mut classes := labels.clone()
	for label in classes {
		if math.is_nan(label) || math.is_inf(label, 0) {
			return errors.error('GaussianNB class labels must be finite', .einval)
		}
	}
	classes.sort()
	mut unique := []f64{cap: classes.len}
	for label in classes {
		if unique.len == 0 || label != unique[unique.len - 1] {
			unique << label
		}
	}
	return unique
}

fn gaussian_nb_validate_batch(batch &Data[f64], n_features int, classes []f64, sample_weights []f64,
	require_positive_weight bool) ! {
	if batch.nb_features != n_features || batch.x.n != n_features
		|| batch.nb_samples != batch.y.len || batch.x.m != batch.nb_samples {
		return errors.error('GaussianNB batch must have matching X and y dimensions', .einval)
	}
	if sample_weights.len != 0 && sample_weights.len != batch.nb_samples {
		return errors.error('sample_weights must be empty or match the number of samples', .einval)
	}
	mut class_index := map[f64]bool{}
	for label in classes {
		class_index[label] = true
	}
	mut weight_sum := 0.0
	for row in 0 .. batch.nb_samples {
		label := batch.y[row]
		if math.is_nan(label) || math.is_inf(label, 0) || label !in class_index {
			return errors.error('GaussianNB batch contains an undeclared or non-finite class label',
				.einval)
		}
		weight := if sample_weights.len == 0 { 1.0 } else { sample_weights[row] }
		if math.is_nan(weight) || math.is_inf(weight, 0) || weight < 0.0 {
			return errors.error('sample weights must be finite and non-negative', .einval)
		}
		weight_sum += weight
		for col in 0 .. n_features {
			value := batch.x.get(row, col)
			if math.is_nan(value) || math.is_inf(value, 0) {
				return errors.error('GaussianNB feature values must be finite', .einval)
			}
		}
	}
	if math.is_inf(weight_sum, 0) {
		return errors.error('sum of sample weights overflowed', .einval)
	}
	if require_positive_weight && weight_sum <= 0.0 {
		return errors.error('the first partial_fit batch must have positive total weight', .einval)
	}
}

fn gaussian_nb_derive(classes []f64, class_weight_sums []f64, class_m2 [][]f64,
	global_weight_sum f64, global_m2 []f64, var_smoothing f64,
	explicit_priors map[f64]f64) !GaussianNBDerived {
	if global_weight_sum <= 0.0 {
		return errors.error('GaussianNB has no positive-weight training samples', .efailed)
	}
	mut max_global_variance := 0.0
	for col in 0 .. global_m2.len {
		variance := global_m2[col] / global_weight_sum
		if math.is_nan(variance) || math.is_inf(variance, 0) || variance < 0.0 {
			return errors.error('GaussianNB global feature variances must be finite', .einval)
		}
		if variance > max_global_variance {
			max_global_variance = variance
		}
	}
	epsilon := if max_global_variance == 0.0 && var_smoothing > 0.0 {
		var_smoothing
	} else {
		max_global_variance * var_smoothing
	}
	if math.is_nan(epsilon) || math.is_inf(epsilon, 0) {
		return errors.error('GaussianNB variance smoothing overflowed', .einval)
	}
	mut variances := [][]f64{len: classes.len}
	mut priors := []f64{len: classes.len}
	for i in 0 .. classes.len {
		variances[i] = []f64{len: global_m2.len}
		priors[i] = class_weight_sums[i] / global_weight_sum
		for col in 0 .. global_m2.len {
			variance := if class_weight_sums[i] > 0.0 {
				class_m2[i][col] / class_weight_sums[i] + epsilon
			} else {
				epsilon
			}
			if class_weight_sums[i] > 0.0
				&& (math.is_nan(variance) || math.is_inf(variance, 0) || variance <= 0.0) {
				return errors.error('GaussianNB needs positive finite variances; increase var_smoothing',
					.einval)
			}
			variances[i][col] = variance
		}
	}
	if explicit_priors.len > 0 {
		if explicit_priors.len != classes.len {
			return errors.error('class priors must contain exactly one entry per observed class',
				.einval)
		}
		mut sum := 0.0
		for i, label in classes {
			if label !in explicit_priors {
				return errors.error('class priors must contain every observed class', .einval)
			}
			prior := explicit_priors[label]
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
	return GaussianNBDerived{
		epsilon:   epsilon
		priors:    priors
		variances: variances
	}
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
	if model.observer_backed {
		model.train()!
	} else {
		model.refresh_derived()!
	}
}

// predict_log_proba returns normalized log probabilities in ascending class order.
pub fn (model &GaussianNB) predict_log_proba(x []f64) ![]f64 {
	if !model.trained {
		return errors.error('GaussianNB is not trained', .efailed)
	}
	if x.len != model.n_features {
		return errors.error('predict expects ${model.n_features} features, got ${x.len}',
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

// class_weight_sums returns the accumulated sample weight for each sorted class.
pub fn (model &GaussianNB) class_weight_sums() []f64 {
	return model.class_weight_sums.clone()
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
