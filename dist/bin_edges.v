module dist

import math
import vsl.errors

const max_automatic_histogram_bins = 10_000_000

// HistogramBinRule selects a NumPy-compatible automatic bin-width estimator.
pub enum HistogramBinRule {
	auto
	fd
	doane
	scott
	stone
	rice
	sturges
	sqrt
}

// histogram_bin_edges returns equal-width edges selected from the finite
// sample. Constant samples use one bin spanning value +/- 0.5.
pub fn histogram_bin_edges(values []f64, rule HistogramBinRule) ![]f64 {
	if values.len == 0 {
		return errors.error('histogram_bin_edges: values must not be empty', .efailed)
	}
	validate_histogram_bin_samples(values)!
	minimum, maximum := histogram_sample_bounds(values)
	if minimum == maximum {
		lower := minimum - 0.5
		upper := maximum + 0.5
		if math.is_inf(lower, 0) || math.is_inf(upper, 0) || lower >= upper {
			return errors.error('histogram_bin_edges: cannot expand constant value to finite edges', .efailed)
		}
		return [lower, upper]
	}
	return histogram_bin_edges_impl(values, rule, minimum, maximum, minimum, maximum)
}

// histogram_bin_edges_in_range selects edges over an explicit finite interval.
// Only observations inside the closed interval influence the bin rule. Samples
// outside it do not contribute; an interval containing no observations errors.
pub fn histogram_bin_edges_in_range(values []f64, rule HistogramBinRule, lower f64, upper f64) ![]f64 {
	if values.len == 0 {
		return errors.error('histogram_bin_edges_in_range: values must not be empty', .efailed)
	}
	if math.is_nan(lower) || math.is_inf(lower, 0) || math.is_nan(upper) || math.is_inf(upper, 0)
		|| lower >= upper {
		return errors.error('histogram_bin_edges_in_range: range must be finite and increasing', .efailed)
	}
	validate_histogram_bin_samples(values)!
	mut in_range := []f64{cap: values.len}
	for value in values {
		if value >= lower && value <= upper {
			in_range << value
		}
	}
	if in_range.len == 0 {
		return errors.error('histogram_bin_edges_in_range: range contains no sample values', .efailed)
	}
	sample_min, sample_max := histogram_sample_bounds(in_range)
	return histogram_bin_edges_impl(in_range, rule, sample_min, sample_max, lower, upper)
}

fn validate_histogram_bin_samples(values []f64) ! {
	for value in values {
		if math.is_nan(value) || math.is_inf(value, 0) {
			return errors.error('histogram_bin_edges: values must all be finite', .efailed)
		}
	}
}

fn histogram_sample_bounds(values []f64) (f64, f64) {
	mut minimum := values[0]
	mut maximum := values[0]
	for value in values[1..] {
		if value < minimum {
			minimum = value
		}
		if value > maximum {
			maximum = value
		}
	}
	return minimum, maximum
}

fn histogram_bin_edges_impl(values []f64, rule HistogramBinRule, sample_min f64, sample_max f64, edge_min f64, edge_max f64) ![]f64 {
	sample_span := sample_max - sample_min
	edge_span := edge_max - edge_min
	if math.is_inf(sample_span, 0) || math.is_inf(edge_span, 0) || edge_span <= 0.0 {
		return errors.error('histogram_bin_edges: range width must be finite and positive', .efailed)
	}
	mut sorted := values.clone()
	sorted.sort()
	bins := histogram_bin_rule_count(sorted, sample_span, edge_min, edge_max, edge_span, rule)!
	if bins < 1 || bins > max_automatic_histogram_bins {
		return errors.error('histogram_bin_edges: estimated bin count exceeds the supported limit', .efailed)
	}
	mut edges := []f64{len: bins + 1}
	width := edge_span / f64(bins)
	for index in 0 .. bins {
		edge := edge_min + f64(index) * width
		if math.is_nan(edge) || math.is_inf(edge, 0) || (index > 0 && edge <= edges[index - 1]) {
			return errors.error('histogram_bin_edges: cannot represent distinct finite bin edges', .efailed)
		}
		edges[index] = edge
	}
	edges[bins] = edge_max
	if edges[bins] <= edges[bins - 1] {
		return errors.error('histogram_bin_edges: cannot represent distinct finite bin edges', .efailed)
	}
	return edges
}

fn histogram_bin_rule_count(sorted []f64, sample_span f64, edge_min f64, edge_max f64, edge_span f64, rule HistogramBinRule) !int {
	if sample_span == 0.0 {
		return 1
	}
	n := sorted.len
	count := f64(n)
	root := math.cbrt(count)
	mut width := 0.0
	match rule {
		.auto {
			fd_width := histogram_fd_width(sorted, root)
			sqrt_width := sample_span / math.sqrt(count)
			sturges_width := sample_span / (math.log2(count) + 1.0)
			width = math.min(math.max(fd_width, sqrt_width / 2.0), sturges_width)
		}
		.fd { width = histogram_fd_width(sorted, root) }
		.doane {
			if n > 2 {
				mean, stddev := histogram_population_moments(sorted)
				if stddev > 0.0 {
					mut skewness := 0.0
					for value in sorted {
						z := (value - mean) / stddev
						skewness += z * z * z / count
					}
					sigma_skew := math.sqrt(6.0 * (count - 2.0) / ((count + 1.0) * (count + 3.0)))
					bins := 1.0 + math.log2(count) + math.log2(1.0 + math.abs(skewness) / sigma_skew)
					width = sample_span / bins
				}
			}
		}
		.scott {
			_, stddev := histogram_population_moments(sorted)
			width = math.pow(24.0 * math.sqrt(math.pi) / count, 1.0 / 3.0) * stddev
		}
		.stone {
			bins := histogram_stone_bin_count(sorted, sample_span, edge_min, edge_max)!
			width = sample_span / f64(bins)
		}
		.rice { width = sample_span / (2.0 * root) }
		.sturges { width = sample_span / (math.log2(count) + 1.0) }
		.sqrt { width = sample_span / math.sqrt(count) }
	}
	if math.is_nan(width) || math.is_inf(width, 0) || width <= 0.0 {
		return 1
	}
	estimated_bins := math.ceil(edge_span / width)
	if math.is_nan(estimated_bins) || math.is_inf(estimated_bins, 0)
		|| estimated_bins > f64(max_automatic_histogram_bins) {
		return error('histogram_bin_edges: estimated bin count exceeds the supported limit')
	}
	return math.max(1, int(estimated_bins))
}

fn histogram_fd_width(sorted []f64, root f64) f64 {
	iqr := histogram_sorted_quantile(sorted, 0.75) - histogram_sorted_quantile(sorted, 0.25)
	return 2.0 * iqr / root
}

fn histogram_sorted_quantile(sorted []f64, q f64) f64 {
	position := q * f64(sorted.len - 1)
	lower := int(math.floor(position))
	upper := math.min(lower + 1, sorted.len - 1)
	weight := position - f64(lower)
	return sorted[lower] * (1.0 - weight) + sorted[upper] * weight
}

fn histogram_population_moments(values []f64) (f64, f64) {
	mut mean := 0.0
	mut m2 := 0.0
	for index, value in values {
		count := f64(index + 1)
		delta := value - mean
		mean += delta / count
		m2 += delta * (value - mean)
	}
	return mean, math.sqrt(m2 / f64(values.len))
}

fn histogram_stone_bin_count(sorted []f64, sample_span f64, edge_min f64, edge_max f64) !int {
	n := sorted.len
	if n <= 1 || sample_span == 0.0 {
		return 1
	}
	upper_bound := math.max(100, int(math.sqrt(f64(n))))
	mut best_bins := 1
	mut best_score := math.inf(1)
	edge_span := edge_max - edge_min
	for bins in 1 .. upper_bound + 1 {
		mut counts := []int{len: bins}
		for value in sorted {
			mut bin := int((value - edge_min) / edge_span * f64(bins))
			if bin < 0 {
				continue
			}
			if bin >= bins {
				bin = bins - 1
			}
			counts[bin]++
		}
		mut sum_probability_squared := 0.0
		for bin_count in counts {
			probability := f64(bin_count) / f64(n)
			sum_probability_squared += probability * probability
		}
		width := sample_span / f64(bins)
		score := (2.0 - f64(n + 1) * sum_probability_squared) / width
		if score < best_score {
			best_score = score
			best_bins = bins
		}
	}
	return best_bins
}
