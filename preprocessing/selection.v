module preprocessing

import math
import vsl.errors

// FeatureScoreFn scores one feature column against the target.
pub type FeatureScoreFn = fn (feature []f64, target []f64) !f64

// VarianceThreshold removes features whose population variance is not greater
// than the configured threshold.
@[heap]
pub struct VarianceThreshold {
mut:
	fitted   bool
	support_ []int
pub:
	threshold f64
pub mut:
	variances_     []f64
	n_features_in_ int
}

// VarianceThreshold.new creates a selector that keeps features with variance
// greater than threshold.
pub fn VarianceThreshold.new(threshold f64) &VarianceThreshold {
	return &VarianceThreshold{
		threshold: threshold
	}
}

// fit learns feature variances from the supplied training matrix.
pub fn (mut selector VarianceThreshold) fit(data [][]f64) ! {
	if math.is_nan(selector.threshold) || math.is_inf(selector.threshold, 0)
		|| selector.threshold < 0.0 {
		return errors.error('variance threshold must be finite and non-negative', .einval)
	}
	n_features := validate_variance_matrix(data, -1, true)!

	mut means := []f64{len: n_features}
	mut sum_squares := []f64{len: n_features}
	for row_index, row in data {
		count := f64(row_index + 1)
		for feature, value in row {
			centered := value - data[0][feature]
			if math.is_nan(centered) || math.is_inf(centered, 0) {
				return errors.error('feature ${feature} variance is not finite', .einval)
			}
			delta := centered - means[feature]
			means[feature] += delta / count
			sum_squares[feature] += delta * (centered - means[feature])
		}
	}

	mut variances := []f64{len: n_features}
	mut support := []int{}
	for feature in 0 .. n_features {
		if math.is_nan(sum_squares[feature]) || math.is_inf(sum_squares[feature], 0) {
			return errors.error('feature ${feature} variance is not finite', .einval)
		}
		variance := if sum_squares[feature] > 0.0 {
			sum_squares[feature] / f64(data.len)
		} else {
			0.0
		}
		if math.is_nan(variance) || math.is_inf(variance, 0) {
			return errors.error('feature ${feature} variance is not finite', .einval)
		}
		variances[feature] = variance
		if variance > selector.threshold {
			support << feature
		}
	}
	if support.len == 0 {
		return errors.error('variance threshold removed all features', .einval)
	}

	selector.variances_ = variances
	selector.support_ = support
	selector.n_features_in_ = n_features
	selector.fitted = true
}

// transform selects the fitted columns without changing row order.
pub fn (selector &VarianceThreshold) transform(data [][]f64) ![][]f64 {
	if !selector.fitted {
		return errors.error('VarianceThreshold must be fitted before transform', .efailed)
	}
	if data.len == 0 {
		return [][]f64{}
	}
	validate_variance_matrix(data, selector.n_features_in_, false)!

	mut result := [][]f64{cap: data.len}
	for row in data {
		mut selected := []f64{cap: selector.support_.len}
		for feature in selector.support_ {
			selected << row[feature]
		}
		result << selected
	}
	return result
}

// fit_transform learns variances and returns the selected training columns.
pub fn (mut selector VarianceThreshold) fit_transform(data [][]f64) ![][]f64 {
	selector.fit(data)!
	return selector.transform(data)
}

// get_support returns the original column indices retained by fit.
pub fn (selector &VarianceThreshold) get_support() ![]int {
	if !selector.fitted {
		return errors.error('VarianceThreshold must be fitted before requesting support',
			.efailed)
	}
	return selector.support_.clone()
}

// get_feature_names_out returns the retained names in original column order.
pub fn (selector &VarianceThreshold) get_feature_names_out(input_features []string) ![]string {
	if !selector.fitted {
		return errors.error('VarianceThreshold must be fitted before requesting feature names',
			.efailed)
	}
	if input_features.len != selector.n_features_in_ {
		return errors.error('VarianceThreshold expected ${selector.n_features_in_} feature names, got ${input_features.len}',
			.einval)
	}
	mut names := []string{cap: selector.support_.len}
	for feature in selector.support_ {
		names << input_features[feature]
	}
	return names
}

fn validate_variance_matrix(data [][]f64, expected_features int, require_finite bool) !int {
	if data.len == 0 {
		return errors.error('cannot fit variance threshold on empty data', .einval)
	}
	n_features := data[0].len
	if n_features == 0 {
		return errors.error('variance threshold data must contain at least one feature', .einval)
	}
	if expected_features >= 0 && n_features != expected_features {
		return errors.error('expected ${expected_features} features, got ${n_features}', .einval)
	}
	for row_index, row in data {
		if row.len != n_features {
			return errors.error('row ${row_index} has ${row.len} features; expected ${n_features}',
				.einval)
		}
		if require_finite {
			for feature, value in row {
				if math.is_nan(value) || math.is_inf(value, 0) {
					return errors.error('feature ${feature} contains a non-finite value in row ${row_index}',
						.einval)
				}
			}
		}
	}
	return n_features
}

// CorrelationSelector selects the k features with the largest absolute
// Pearson correlation with a continuous target.
@[heap]
pub struct CorrelationSelector {
mut:
	fitted   bool
	support_ []int
pub:
	k int
pub mut:
	scores_        []f64
	n_features_in_ int
}

// CorrelationSelector.new creates a deterministic top-k univariate selector.
pub fn CorrelationSelector.new(k int) &CorrelationSelector {
	return &CorrelationSelector{ k: k }
}

// fit computes one correlation score per feature using only the training data.
pub fn (mut selector CorrelationSelector) fit(data [][]f64, target []f64) ! {
	n_features := validate_correlation_matrix(data, target)!
	if selector.k <= 0 || selector.k > n_features {
		return errors.error('k must be in the range [1, ${n_features}]', .einval)
	}

	mut feature_means := []f64{len: n_features}
	mut target_mean := 0.0
	for row_index, row in data {
		target_mean += target[row_index]
		for feature, value in row {
			feature_means[feature] += value
		}
	}
	target_mean /= f64(data.len)
	for feature in 0 .. n_features {
		feature_means[feature] /= f64(data.len)
	}

	mut target_sum_squares := 0.0
	mut scores := []f64{len: n_features}
	mut feature_sum_squares := []f64{len: n_features}
	mut cross_products := []f64{len: n_features}
	for row_index, row in data {
		target_delta := target[row_index] - target_mean
		target_sum_squares += target_delta * target_delta
		for feature, value in row {
			feature_delta := value - feature_means[feature]
			feature_sum_squares[feature] += feature_delta * feature_delta
			cross_products[feature] += feature_delta * target_delta
		}
	}
	for feature in 0 .. n_features {
		denominator := math.sqrt(feature_sum_squares[feature] * target_sum_squares)
		scores[feature] = if denominator == 0.0 {
			0.0
		} else {
			math.abs(cross_products[feature] / denominator)
		}
	}

	mut ranked := []int{len: n_features, init: index}
	ranked.sort_with_compare(fn [scores] (a &int, b &int) int {
		if scores[*a] > scores[*b] {
			return -1
		}
		if scores[*a] < scores[*b] {
			return 1
		}
		return if *a < *b {
			-1
		} else if *a > *b {
			1
		} else {
			0
		}
	})
	mut support := ranked[..selector.k].clone()
	support.sort()
	selector.scores_ = scores
	selector.support_ = support
	selector.n_features_in_ = n_features
	selector.fitted = true
}

// transform selects the fitted columns without changing row order.
pub fn (selector &CorrelationSelector) transform(data [][]f64) ![][]f64 {
	if !selector.fitted {
		return errors.error('CorrelationSelector must be fitted before transform', .efailed)
	}
	if data.len == 0 {
		return [][]f64{}
	}
	validate_correlation_width(data, selector.n_features_in_)!
	mut result := [][]f64{cap: data.len}
	for row in data {
		mut selected := []f64{cap: selector.support_.len}
		for feature in selector.support_ {
			selected << row[feature]
		}
		result << selected
	}
	return result
}

// fit_transform fits the selector and returns the selected training columns.
pub fn (mut selector CorrelationSelector) fit_transform(data [][]f64, target []f64) ![][]f64 {
	selector.fit(data, target)!
	return selector.transform(data)
}

// get_support returns the original column indices retained by fit.
pub fn (selector &CorrelationSelector) get_support() ![]int {
	if !selector.fitted {
		return errors.error('CorrelationSelector must be fitted before requesting support',
			.efailed)
	}
	return selector.support_.clone()
}

// get_feature_names_out returns the retained names in original column order.
pub fn (selector &CorrelationSelector) get_feature_names_out(input_features []string) ![]string {
	if !selector.fitted {
		return errors.error('CorrelationSelector must be fitted before requesting feature names',
			.efailed)
	}
	if input_features.len != selector.n_features_in_ {
		return errors.error('CorrelationSelector expected ${selector.n_features_in_} feature names, got ${input_features.len}',
			.einval)
	}
	mut names := []string{cap: selector.support_.len}
	for feature in selector.support_ {
		names << input_features[feature]
	}
	return names
}

fn validate_correlation_matrix(data [][]f64, target []f64) !int {
	if data.len == 0 {
		return errors.error('cannot fit correlation selector on empty data', .einval)
	}
	if target.len != data.len {
		return errors.error('target must have one value per data row', .einval)
	}
	for row_index, value in target {
		if math.is_nan(value) || math.is_inf(value, 0) {
			return errors.error('target contains a non-finite value in row ${row_index}', .einval)
		}
	}
	n_features := validate_correlation_width(data, -1)!
	for row_index, row in data {
		for feature, value in row {
			if math.is_nan(value) || math.is_inf(value, 0) {
				return errors.error('feature ${feature} contains a non-finite value in row ${row_index}',
					.einval)
			}
		}
	}
	return n_features
}

fn validate_correlation_width(data [][]f64, expected_features int) !int {
	if data.len == 0 {
		return if expected_features >= 0 {
			error('expected ${expected_features} features, got 0')
		} else {
			error('correlation selector data must not be empty')
		}
	}
	n_features := data[0].len
	if n_features == 0 {
		return error('correlation selector data must contain at least one feature')
	}
	if expected_features >= 0 && n_features != expected_features {
		return error('expected ${expected_features} features, got ${n_features}')
	}
	for row_index, row in data {
		if row.len != n_features {
			return error('row ${row_index} has ${row.len} features; expected ${n_features}')
		}
	}
	return n_features
}

// SelectKBest retains the k features with the highest scores from a
// user-supplied univariate scoring function.
@[heap]
pub struct SelectKBest {
mut:
	fitted   bool
	support_ []int
pub:
	k        int
	score_fn FeatureScoreFn @[required]
pub mut:
	scores_        []f64
	n_features_in_ int
}

// SelectKBest.new creates a deterministic top-k univariate selector.
pub fn SelectKBest.new(k int, score_fn FeatureScoreFn) &SelectKBest {
	return &SelectKBest{
		k:        k
		score_fn: score_fn
	}
}

// fit computes one score per feature using only the supplied training data.
pub fn (mut selector SelectKBest) fit(data [][]f64, target []f64) ! {
	n_features := validate_correlation_matrix(data, target)!
	if selector.k <= 0 || selector.k > n_features {
		return errors.error('k must be in the range [1, ${n_features}]', .einval)
	}

	mut scores := []f64{len: n_features}
	for feature in 0 .. n_features {
		mut column := []f64{len: data.len}
		for row_index, row in data {
			column[row_index] = row[feature]
		}
		score := selector.score_fn(column, target) or {
			return errors.error('feature ${feature} scoring failed: ${err.msg()}', .einval)
		}
		if math.is_nan(score) || math.is_inf(score, 0) {
			return errors.error('feature ${feature} score is not finite', .einval)
		}
		scores[feature] = score
	}

	mut ranked := []int{len: n_features, init: index}
	ranked.sort_with_compare(fn [scores] (a &int, b &int) int {
		if scores[*a] > scores[*b] {
			return -1
		}
		if scores[*a] < scores[*b] {
			return 1
		}
		return if *a < *b {
			-1
		} else if *a > *b {
			1
		} else {
			0
		}
	})
	mut support := ranked[..selector.k].clone()
	support.sort()
	selector.scores_ = scores
	selector.support_ = support
	selector.n_features_in_ = n_features
	selector.fitted = true
}

// transform selects the fitted columns without changing row order.
pub fn (selector &SelectKBest) transform(data [][]f64) ![][]f64 {
	if !selector.fitted {
		return errors.error('SelectKBest must be fitted before transform', .efailed)
	}
	if data.len == 0 {
		return [][]f64{}
	}
	validate_correlation_width(data, selector.n_features_in_)!
	mut result := [][]f64{cap: data.len}
	for row in data {
		mut selected := []f64{cap: selector.support_.len}
		for feature in selector.support_ {
			selected << row[feature]
		}
		result << selected
	}
	return result
}

// fit_transform fits the selector and returns the selected training columns.
pub fn (mut selector SelectKBest) fit_transform(data [][]f64, target []f64) ![][]f64 {
	selector.fit(data, target)!
	return selector.transform(data)
}

// get_support returns the original column indices retained by fit.
pub fn (selector &SelectKBest) get_support() ![]int {
	if !selector.fitted {
		return errors.error('SelectKBest must be fitted before requesting support', .efailed)
	}
	return selector.support_.clone()
}

// get_feature_names_out returns the retained names in original column order.
pub fn (selector &SelectKBest) get_feature_names_out(input_features []string) ![]string {
	if !selector.fitted {
		return errors.error('SelectKBest must be fitted before requesting feature names',
			.efailed)
	}
	if input_features.len != selector.n_features_in_ {
		return errors.error('SelectKBest expected ${selector.n_features_in_} feature names, got ${input_features.len}',
			.einval)
	}
	mut names := []string{cap: selector.support_.len}
	for feature in selector.support_ {
		names << input_features[feature]
	}
	return names
}
