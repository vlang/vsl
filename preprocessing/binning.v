module preprocessing

import vsl.errors

// BinningStrategy specifies how to create bin edges
pub enum BinningStrategy {
	uniform  // equal-width bins
	quantile // equal-frequency bins
}

// cut bins values into discrete intervals using equal-width binning.
// Returns the bin labels for each value.
pub fn cut(values []f64, n_bins int, labels []string) ![]string {
	if values.len == 0 {
		return errors.error('cannot bin empty data', .einval)
	}
	if n_bins < 2 {
		return errors.error('n_bins must be at least 2', .einval)
	}

	// Find min and max
	mut min_val := values[0]
	mut max_val := values[0]
	for v in values {
		if v < min_val {
			min_val = v
		}
		if v > max_val {
			max_val = v
		}
	}

	// Create bin edges
	bin_width := (max_val - min_val) / f64(n_bins)
	mut edges := []f64{len: n_bins + 1}
	for i in 0 .. n_bins + 1 {
		edges[i] = min_val + f64(i) * bin_width
	}

	// Generate labels if not provided
	bin_labels := if labels.len == n_bins {
		labels
	} else {
		mut auto_labels := []string{len: n_bins}
		for i in 0 .. n_bins {
			auto_labels[i] = 'bin_${i}'
		}
		auto_labels
	}

	// Assign bins
	mut result := []string{len: values.len}
	for i, v in values {
		bin_idx := find_bin(v, edges)
		result[i] = bin_labels[bin_idx]
	}

	return result
}

// qcut bins values into discrete intervals using quantile-based binning.
// Returns the bin labels for each value.
pub fn qcut(values []f64, n_bins int, labels []string) ![]string {
	if values.len == 0 {
		return errors.error('cannot bin empty data', .einval)
	}
	if n_bins < 2 {
		return errors.error('n_bins must be at least 2', .einval)
	}

	// Sort values to find quantiles
	mut sorted := values.clone()
	sorted.sort(a < b)

	// Create bin edges based on quantiles
	mut edges := []f64{len: n_bins + 1}
	edges[0] = sorted[0]
	edges[n_bins] = sorted[sorted.len - 1]

	for i in 1 .. n_bins {
		q := f64(i) / f64(n_bins)
		idx := int(q * f64(sorted.len - 1))
		edges[i] = sorted[idx]
	}

	// Generate labels if not provided
	bin_labels := if labels.len == n_bins {
		labels
	} else {
		mut auto_labels := []string{len: n_bins}
		for i in 0 .. n_bins {
			auto_labels[i] = 'Q${i + 1}'
		}
		auto_labels
	}

	// Assign bins
	mut result := []string{len: values.len}
	for i, v in values {
		bin_idx := find_bin(v, edges)
		result[i] = bin_labels[bin_idx]
	}

	return result
}

// find_bin finds the bin index for a value given the bin edges
fn find_bin(value f64, edges []f64) int {
	n_bins := edges.len - 1
	for i in 0 .. n_bins {
		if value <= edges[i + 1] {
			return i
		}
	}
	return n_bins - 1
}

// Binner provides a fitted binning transformer
@[heap]
pub struct Binner {
mut:
	fitted bool
pub mut:
	edges_   []f64    // bin edges
	labels_  []string // bin labels
	n_bins   int
	strategy BinningStrategy
}

// Binner.new creates a new Binner
pub fn Binner.new(n_bins int, strategy BinningStrategy, labels []string) &Binner {
	return &Binner{
		n_bins:   n_bins
		strategy: strategy
		labels_:  labels
	}
}

// fit computes the bin edges based on the data
pub fn (mut b Binner) fit(values []f64) ! {
	if values.len == 0 {
		return errors.error('cannot fit on empty data', .einval)
	}
	if b.n_bins < 2 {
		return errors.error('n_bins must be at least 2', .einval)
	}

	match b.strategy {
		.uniform {
			// Equal-width bins
			mut min_val := values[0]
			mut max_val := values[0]
			for v in values {
				if v < min_val {
					min_val = v
				}
				if v > max_val {
					max_val = v
				}
			}

			bin_width := (max_val - min_val) / f64(b.n_bins)
			b.edges_ = []f64{len: b.n_bins + 1}
			for i in 0 .. b.n_bins + 1 {
				b.edges_[i] = min_val + f64(i) * bin_width
			}
		}
		.quantile {
			// Quantile-based bins
			mut sorted := values.clone()
			sorted.sort(a < b)

			b.edges_ = []f64{len: b.n_bins + 1}
			b.edges_[0] = sorted[0]
			b.edges_[b.n_bins] = sorted[sorted.len - 1]

			for i in 1 .. b.n_bins {
				q := f64(i) / f64(b.n_bins)
				idx := int(q * f64(sorted.len - 1))
				b.edges_[i] = sorted[idx]
			}
		}
	}

	// Generate labels if not provided
	if b.labels_.len != b.n_bins {
		b.labels_ = []string{len: b.n_bins}
		for i in 0 .. b.n_bins {
			b.labels_[i] = 'bin_${i}'
		}
	}

	b.fitted = true
}

// transform applies the binning to the data
pub fn (b &Binner) transform(values []f64) ![]string {
	if !b.fitted {
		return errors.error('Binner must be fitted before transform', .efailed)
	}

	mut result := []string{len: values.len}
	for i, v in values {
		bin_idx := find_bin(v, b.edges_)
		result[i] = b.labels_[bin_idx]
	}
	return result
}

// fit_transform fits and transforms in one step
pub fn (mut b Binner) fit_transform(values []f64) ![]string {
	b.fit(values)!
	return b.transform(values)
}

// transform_to_indices returns bin indices instead of labels
pub fn (b &Binner) transform_to_indices(values []f64) ![]int {
	if !b.fitted {
		return errors.error('Binner must be fitted before transform', .efailed)
	}

	mut result := []int{len: values.len}
	for i, v in values {
		result[i] = find_bin(v, b.edges_)
	}
	return result
}

// digitize returns indices of the bins to which each value belongs.
// Similar to numpy.digitize
pub fn digitize(values []f64, bins []f64) []int {
	mut result := []int{len: values.len}
	for i, v in values {
		mut idx := 0
		for j, edge in bins {
			if v > edge {
				idx = j + 1
			} else {
				break
			}
		}
		result[i] = idx
	}
	return result
}
