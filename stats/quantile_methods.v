module stats

import math

// QuantileMethod selects one of NumPy's thirteen sample-quantile estimators.
pub enum QuantileMethod {
	inverted_cdf
	averaged_inverted_cdf
	closest_observation
	interpolated_inverted_cdf
	hazen
	weibull
	linear
	median_unbiased
	normal_unbiased
	lower
	higher
	midpoint
	nearest
}

// quantile_with_method returns a quantile using the selected estimator.
// It sorts a copy and rejects empty or non-finite samples.
pub fn quantile_with_method(values []f64, q f64, method QuantileMethod) !f64 {
	return quantile_with_method_and_policy(values, q, method, .reject)
}

// quantile_with_method_and_policy applies a quantile estimator and an explicit
// policy for non-finite samples.
pub fn quantile_with_method_and_policy(values []f64, q f64, method QuantileMethod, policy NonFinitePolicy) !f64 {
	if values.len == 0 {
		return error('stats.quantile_with_method_and_policy: values must not be empty')
	}
	if math.is_nan(q) || math.is_inf(q, 0) || q < 0.0 || q > 1.0 {
		return error('stats.quantile_with_method_and_policy: q must be finite and between 0 and 1')
	}
	mut sorted := []f64{cap: values.len}
	mut has_non_finite := false
	for value in values {
		if math.is_nan(value) || math.is_inf(value, 0) {
			has_non_finite = true
			if policy == .reject {
				return error('stats.quantile_with_method: values must all be finite')
			}
		} else {
			sorted << value
		}
	}
	if policy == .propagate && has_non_finite {
		return math.nan()
	}
	if sorted.len == 0 {
		return error('stats.quantile_with_method_and_policy: no finite values remain')
	}
	sorted.sort()
	position := quantile_method_position(q, sorted.len, method)
	lower_index := int(math.floor(position))
	upper_index := math.min(lower_index + 1, sorted.len - 1)
	weight := position - f64(lower_index)
	return sorted[lower_index] * (1.0 - weight) + sorted[upper_index] * weight
}

// percentile_with_method is the 0..100-scale form of quantile_with_method.
pub fn percentile_with_method(values []f64, p f64, method QuantileMethod) !f64 {
	if math.is_nan(p) || math.is_inf(p, 0) || p < 0.0 || p > 100.0 {
		return error('stats.percentile_with_method: p must be finite and between 0 and 100')
	}
	return quantile_with_method(values, p / 100.0, method)
}

// percentile_with_method_and_policy is the 0..100-scale policy variant.
pub fn percentile_with_method_and_policy(values []f64, p f64, method QuantileMethod, policy NonFinitePolicy) !f64 {
	if math.is_nan(p) || math.is_inf(p, 0) || p < 0.0 || p > 100.0 {
		return error('stats.percentile_with_method_and_policy: p must be finite and between 0 and 100')
	}
	return quantile_with_method_and_policy(values, p / 100.0, method, policy)
}

fn quantile_method_position(q f64, n int, method QuantileMethod) f64 {
	mut position := q * f64(n - 1)
	match method {
		.inverted_cdf, .averaged_inverted_cdf, .closest_observation {
			m := match method {
				.inverted_cdf, .averaged_inverted_cdf { 0.0 }
				else { -0.5 }
			}
			index := q * f64(n) + m - 1.0
			lower := math.floor(index)
			fraction := index - lower
			weight := match method {
				.inverted_cdf {
					if fraction > 0.0 { 1.0 } else { 0.0 }
				}
				.averaged_inverted_cdf {
					if fraction > 0.0 { 1.0 } else { 0.5 }
				}
				.closest_observation {
					if fraction == 0.0 && int(lower) % 2 == 1 { 0.0 } else { 1.0 }
				}
				else { 0.0 }
			}
			position = lower + weight
		}
		.interpolated_inverted_cdf { position = q * f64(n) - 1.0 }
		.hazen { position = q * f64(n) - 0.5 }
		.weibull { position = q * f64(n + 1) - 1.0 }
		.linear { position = q * f64(n - 1) }
		.median_unbiased { position = q * f64(n) + q / 3.0 + 1.0 / 3.0 - 1.0 }
		.normal_unbiased { position = q * f64(n) + q / 4.0 + 3.0 / 8.0 - 1.0 }
		.lower, .higher, .midpoint, .nearest {
			base := q * f64(n - 1)
			lower := math.floor(base)
			upper := math.ceil(base)
			position = match method {
				.lower { lower }
				.higher { upper }
				.midpoint { (lower + upper) / 2.0 }
				.nearest {
					if base - lower > 0.5 { upper } else { lower }
				}
			}
		}
	}
	return math.max(0.0, math.min(position, f64(n - 1)))
}
