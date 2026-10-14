module stats

import math

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
	if values.len == 0 {
		return error('stats.summarize: values must not be empty')
	}
	if ddof < 0 || ddof >= values.len {
		return error('stats.summarize: ddof must be non-negative and smaller than the sample count')
	}

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
	if values.len == 0 {
		return error('stats.quantile: values must not be empty')
	}
	if math.is_nan(q) || math.is_inf(q, 0) || q < 0.0 || q > 1.0 {
		return error('stats.quantile: q must be finite and between 0 and 1')
	}
	mut sorted := values.clone()
	for value in sorted {
		if math.is_nan(value) || math.is_inf(value, 0) {
			return error('stats.quantile: values must all be finite')
		}
	}
	sorted.sort()
	position := q * f64(sorted.len - 1)
	lower_index := int(math.floor(position))
	upper_index := if lower_index + 1 < sorted.len { lower_index + 1 } else { lower_index }
	fraction := position - f64(lower_index)
	return sorted[lower_index] * (1.0 - fraction) + sorted[upper_index] * fraction
}

// percentile returns the requested percentile using linear interpolation.
// `p` is expressed on the inclusive range [0, 100].
pub fn percentile(values []f64, p f64) !f64 {
	if math.is_nan(p) || math.is_inf(p, 0) || p < 0.0 || p > 100.0 {
		return error('stats.percentile: p must be finite and between 0 and 100')
	}
	return quantile(values, p / 100.0)
}
