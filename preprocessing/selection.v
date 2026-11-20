module preprocessing

import math
import vsl.errors

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
