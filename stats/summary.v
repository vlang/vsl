module stats

import math

// NonFinitePolicy controls how descriptive statistics handle NaN and infinity.
pub enum NonFinitePolicy {
	reject
	omit
	propagate
}

// Summary contains single-pass descriptive statistics for finite f64 samples.
pub struct Summary {
pub:
	count    int
	mean     f64
	variance f64
	stddev   f64
	min      f64
	max      f64
}

// summarize computes stable online moments and extrema for a non-empty sample.
// `ddof` is the delta degrees of freedom: 0 gives population variance, 1 gives
// sample variance. Non-finite values are rejected rather than silently skipped.
pub fn summarize(values []f64, ddof int) !Summary {
	return summarize_with_policy(values, ddof, .reject)
}

// summarize_with_policy computes stable moments using the selected policy.
// Omitted samples do not contribute to count or degrees of freedom. Propagate
// returns NaN for numeric statistics when any sample is non-finite; count
// remains the number of input observations.
pub fn summarize_with_policy(values []f64, ddof int, policy NonFinitePolicy) !Summary {
	if values.len == 0 {
		return error('stats.summarize: values must not be empty')
	}
	if ddof < 0 || (policy != .omit && ddof >= values.len) {
		return error('stats.summarize: ddof must be non-negative and smaller than the sample count')
	}
	if policy == .reject {
		return summarize_finite(values, ddof)
	}
	if policy == .propagate {
		for value in values {
			if math.is_nan(value) || math.is_inf(value, 0) {
				return nan_summary(values.len)
			}
		}
		return summarize_finite(values, ddof)
	}
	mut finite := []f64{cap: values.len}
	for value in values {
		if !(math.is_nan(value) || math.is_inf(value, 0)) {
			finite << value
		}
	}
	if finite.len == 0 {
		return error('stats.summarize: no finite values remain')
	}
	if ddof >= finite.len {
		return error('stats.summarize: ddof must be non-negative and smaller than the sample count')
	}
	return summarize_finite(finite, ddof)
}

fn nan_summary(count int) Summary {
	nan := math.nan()
	return Summary{
		count:    count
		mean:     nan
		variance: nan
		stddev:   nan
		min:      nan
		max:      nan
	}
}

fn summarize_finite(values []f64, ddof int) !Summary {
	mut mean := 0.0
	mut m2 := 0.0
	mut min := 0.0
	mut max := 0.0
	for index, value in values {
		if math.is_nan(value) || math.is_inf(value, 0) {
			return error('stats.summarize: values must all be finite')
		}
		if index == 0 {
			min = value
			max = value
		} else {
			if value < min {
				min = value
			}
			if value > max {
				max = value
			}
		}

		count := f64(index + 1)
		delta := value - mean
		mean += delta / count
		delta_after := value - mean
		m2 += delta * delta_after
		if math.is_nan(mean) || math.is_inf(mean, 0) || math.is_nan(m2) || math.is_inf(m2, 0) {
			return error('stats.summarize: moments overflowed f64')
		}
	}

	variance := m2 / f64(values.len - ddof)
	return Summary{
		count:    values.len
		mean:     mean
		variance: variance
		stddev:   math.sqrt(variance)
		min:      min
		max:      max
	}
}

// quantile returns the requested quantile using linear interpolation between
// adjacent sorted values (the default Type 7 definition used by NumPy/SciPy).
pub fn quantile(values []f64, q f64) !f64 {
	return quantile_with_method(values, q, .linear)
}

// quantile_with_policy returns a linear quantile using the selected
// non-finite sample policy.
pub fn quantile_with_policy(values []f64, q f64, policy NonFinitePolicy) !f64 {
	return quantile_with_method_and_policy(values, q, .linear, policy)
}

// percentile returns the requested percentile using linear interpolation.
// `p` is expressed on the inclusive range [0, 100].
pub fn percentile(values []f64, p f64) !f64 {
	return percentile_with_method(values, p, .linear)
}

// percentile_with_policy is the 0..100-scale form of quantile_with_policy.
pub fn percentile_with_policy(values []f64, p f64, policy NonFinitePolicy) !f64 {
	if math.is_nan(p) || math.is_inf(p, 0) || p < 0.0 || p > 100.0 {
		return error('stats.percentile_with_policy: p must be finite and between 0 and 100')
	}
	return quantile_with_policy(values, p / 100.0, policy)
}

struct WeightedValue {
	value  f64
	weight f64
}

fn compare_weighted_values(a &WeightedValue, b &WeightedValue) int {
	if a.value < b.value {
		return -1
	}
	if a.value > b.value {
		return 1
	}
	return 0
}

// quantile_weighted returns NumPy's inverted-CDF weighted quantile. Weights
// represent non-negative sample mass, and values/weights must have equal
// lengths. Non-finite samples or weights are rejected.
pub fn quantile_weighted(values []f64, weights []f64, q f64) !f64 {
	return quantile_weighted_with_policy(values, weights, q, .reject)
}

// quantile_weighted_with_policy uses NumPy's inverted-CDF weighted quantile.
// Under omit, any pair with a non-finite value or weight is excluded.
// Propagate returns NaN when a positive-mass pair contains a non-finite value;
// invalid weights remain errors because their contribution is undefined.
pub fn quantile_weighted_with_policy(values []f64, weights []f64, q f64, policy NonFinitePolicy) !f64 {
	if math.is_nan(q) || math.is_inf(q, 0) || q < 0.0 || q > 1.0 {
		return error('stats.quantile_weighted_with_policy: q must be finite and between 0 and 1')
	}
	if values.len == 0 {
		return error('stats.quantile_weighted_with_policy: values must not be empty')
	}
	if values.len != weights.len {
		return error('stats.quantile_weighted_with_policy: values and weights must have the same length')
	}
	mut pairs := []WeightedValue{cap: values.len}
	mut total_weight := 0.0
	mut has_non_finite := false
	for i, value in values {
		weight := weights[i]
		value_non_finite := math.is_nan(value) || math.is_inf(value, 0)
		weight_non_finite := math.is_nan(weight) || math.is_inf(weight, 0)
		if weight_non_finite {
			if policy == .omit {
				continue
			}
			return error('stats.quantile_weighted_with_policy: weights must be finite')
		}
		if weight < 0.0 {
			return error('stats.quantile_weighted_with_policy: weights must be non-negative')
		}
		if value_non_finite {
			if policy == .reject {
				return error('stats.quantile_weighted: values must all be finite')
			}
			if policy == .propagate && weight > 0.0 {
				has_non_finite = true
			}
			if policy == .omit || weight == 0.0 {
				continue
			}
		}
		total_weight += weight
		if math.is_inf(total_weight, 0) {
			return error('stats.quantile_weighted_with_policy: total weight overflowed f64')
		}
		if weight > 0.0 {
			pairs << WeightedValue{value, weight}
		}
	}
	if has_non_finite {
		return math.nan()
	}
	if total_weight <= 0.0 {
		return error('stats.quantile_weighted_with_policy: total weight must be positive')
	}
	pairs.sort_with_compare(compare_weighted_values)
	target := q * total_weight
	mut cumulative_weight := 0.0
	for pair in pairs {
		cumulative_weight += pair.weight
		if cumulative_weight >= target {
			return pair.value
		}
	}
	return pairs[pairs.len - 1].value
}

// percentile_weighted is the 0..100-scale form of quantile_weighted.
pub fn percentile_weighted(values []f64, weights []f64, p f64) !f64 {
	return percentile_weighted_with_policy(values, weights, p, .reject)
}

// percentile_weighted_with_policy is the 0..100-scale weighted quantile.
pub fn percentile_weighted_with_policy(values []f64, weights []f64, p f64, policy NonFinitePolicy) !f64 {
	if math.is_nan(p) || math.is_inf(p, 0) || p < 0.0 || p > 100.0 {
		return error('stats.percentile_weighted_with_policy: p must be finite and between 0 and 100')
	}
	return quantile_weighted_with_policy(values, weights, p / 100.0, policy)
}
