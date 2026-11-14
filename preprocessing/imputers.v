module preprocessing

import math
import vsl.errors

// ImputationStrategy selects how a feature's missing values are filled.
pub enum ImputationStrategy {
	mean
	median
	constant
}

// SimpleImputer learns one replacement value per feature from training data.
@[heap]
pub struct SimpleImputer {
mut:
	fitted bool
pub:
	strategy   ImputationStrategy
	fill_value f64
pub mut:
	statistics_ []f64
	n_features  int
}

// SimpleImputer.new creates an imputer that treats NaN values as missing.
pub fn SimpleImputer.new(strategy ImputationStrategy, fill_value f64) &SimpleImputer {
	return &SimpleImputer{
		strategy:   strategy
		fill_value: fill_value
	}
}

// fit learns replacement values from the provided training matrix.
pub fn (mut imputer SimpleImputer) fit(data [][]f64) ! {
	n_features := validate_imputer_matrix(data, -1)!
	if imputer.strategy == .constant && math.is_nan(imputer.fill_value) {
		return errors.error('constant fill value cannot be NaN', .einval)
	}

	mut statistics := []f64{len: n_features}
	for feature in 0 .. n_features {
		match imputer.strategy {
			.constant {
				statistics[feature] = imputer.fill_value
			}
			.mean {
				mut count := 0
				mut mean := 0.0
				for row in data {
					value := row[feature]
					if math.is_nan(value) {
						continue
					}
					count++
					weight := f64(count)
					mean = mean * ((weight - 1.0) / weight) + value / weight
				}
				if count == 0 {
					return errors.error('feature ${feature} contains only missing values', .einval)
				}
				statistics[feature] = mean
			}
			.median {
				mut values := []f64{}
				for row in data {
					value := row[feature]
					if !math.is_nan(value) {
						values << value
					}
				}
				if values.len == 0 {
					return errors.error('feature ${feature} contains only missing values', .einval)
				}
				values.sort(a < b)
				middle := values.len / 2
				statistics[feature] = if values.len % 2 == 0 {
					median_midpoint(values[middle - 1], values[middle])
				} else {
					values[middle]
				}
			}
		}
	}

	imputer.statistics_ = statistics
	imputer.n_features = n_features
	imputer.fitted = true
}

// transform replaces NaN values using statistics learned by fit.
pub fn (imputer &SimpleImputer) transform(data [][]f64) ![][]f64 {
	if !imputer.fitted {
		return errors.error('SimpleImputer must be fitted before transform', .efailed)
	}
	if data.len == 0 {
		return [][]f64{}
	}
	validate_imputer_matrix(data, imputer.n_features)!

	mut result := [][]f64{len: data.len}
	for row_index, row in data {
		mut transformed := []f64{len: imputer.n_features}
		for feature, value in row {
			transformed[feature] = if math.is_nan(value) {
				imputer.statistics_[feature]
			} else {
				value
			}
		}
		result[row_index] = transformed
	}
	return result
}

// fit_transform learns replacement values and applies them to the same matrix.
pub fn (mut imputer SimpleImputer) fit_transform(data [][]f64) ![][]f64 {
	imputer.fit(data)!
	return imputer.transform(data)
}

// get_feature_names_out preserves names because imputation does not change columns.
pub fn (imputer &SimpleImputer) get_feature_names_out(input_features []string) ![]string {
	if !imputer.fitted {
		return errors.error('SimpleImputer must be fitted before get_feature_names_out', .efailed)
	}
	return identity_feature_names(input_features, imputer.n_features, 'SimpleImputer')
}

fn validate_imputer_matrix(data [][]f64, expected_features int) !int {
	if data.len == 0 {
		return errors.error('cannot fit an imputer on empty data', .einval)
	}
	n_features := data[0].len
	if n_features == 0 {
		return errors.error('imputer data must contain at least one feature', .einval)
	}
	if expected_features >= 0 && n_features != expected_features {
		return errors.error('expected ${expected_features} features, got ${n_features}', .einval)
	}
	for row_index, row in data {
		if row.len != n_features {
			return errors.error('row ${row_index} has ${row.len} features; expected ${n_features}',
				.einval)
		}
	}
	return n_features
}

fn median_midpoint(lower f64, upper f64) f64 {
	if lower == upper {
		return lower
	}
	if math.is_inf(lower, 0) || math.is_inf(upper, 0)
		|| (lower < 0.0 && upper >= 0.0) || (lower <= 0.0 && upper > 0.0) {
		return lower / 2.0 + upper / 2.0
	}
	return lower + (upper - lower) / 2.0
}
