module dist

import math
import vsl.errors

// WeightedHistogram accumulates non-negative observation weights in fixed bins.
pub struct WeightedHistogram {
pub mut:
	stations []f64 // bin edges
	counts   []f64 // accumulated weight per bin
}

// WeightedHistogram.new creates weighted bins using the same edge convention
// as Histogram: left-closed bins, with the final right edge included.
pub fn WeightedHistogram.new(stations []f64) &WeightedHistogram {
	return &WeightedHistogram{
		stations: stations
	}
}

// count adds each sample's non-negative weight to its bin and returns the
// total weight from this call, including observations outside the range.
// `clear` controls whether previous bin weights are retained. When accumulating
// calls with `clear: false`, sum their returned weights for density normalization.
pub fn (mut o WeightedHistogram) count(values []f64, weights []f64, clear bool) !f64 {
	binning := Histogram.new(o.stations)
	binning.validate_stations()!
	if values.len != weights.len {
		return errors.error('WeightedHistogram values and weights must have equal lengths', .efailed)
	}
	mut increments := []f64{len: o.stations.len - 1}
	mut total_weight := 0.0
	for i, value in values {
		weight := weights[i]
		if math.is_nan(value) || math.is_inf(value, 0) {
			return errors.error('WeightedHistogram values must all be finite', .efailed)
		}
		if math.is_nan(weight) || math.is_inf(weight, 0) || weight < 0.0 {
			return errors.error('WeightedHistogram weights must be finite and non-negative', .efailed)
		}
		total_weight += weight
		if math.is_inf(total_weight, 0) {
			return errors.error('WeightedHistogram total weight overflowed f64', .efailed)
		}
		bin := binning.find_bin_unchecked(value)
		if bin >= 0 {
			increments[bin] += weight
		}
	}
	mut next_counts := if clear || o.counts.len != increments.len {
		[]f64{len: increments.len}
	} else {
		o.counts.clone()
	}
	for i, increment in increments {
		if math.is_nan(next_counts[i]) || math.is_inf(next_counts[i], 0) || next_counts[i] < 0.0 {
			return errors.error('WeightedHistogram accumulated counts must be finite and non-negative', .efailed)
		}
		next_counts[i] += increment
		if math.is_inf(next_counts[i], 0) {
			return errors.error('WeightedHistogram bin weight overflowed f64', .efailed)
		}
	}
	o.counts = next_counts
	return total_weight
}

// density returns each bin's accumulated weight fraction divided by its width.
// `total_weight` includes observations outside the range, so the integrated
// density is the fraction of total weight that fell inside the histogram.
pub fn (o WeightedHistogram) density(total_weight f64) ![]f64 {
	binning := Histogram.new(o.stations)
	binning.validate_stations()!
	if math.is_nan(total_weight) || math.is_inf(total_weight, 0) || total_weight <= 0.0 {
		return errors.error('WeightedHistogram density needs a positive finite total weight', .efailed)
	}
	nbins := o.stations.len - 1
	if o.counts.len != nbins {
		return errors.error('WeightedHistogram density requires counts for every bin', .efailed)
	}
	mut densities := []f64{len: nbins}
	for i in 0 .. nbins {
		weight := o.counts[i]
		if math.is_nan(weight) || math.is_inf(weight, 0) || weight < 0.0 {
			return errors.error('WeightedHistogram counts must be finite and non-negative', .efailed)
		}
		width := o.stations[i + 1] - o.stations[i]
		if math.is_inf(width, 0) || width <= 0.0 {
			return errors.error('WeightedHistogram bin widths must be finite and positive', .efailed)
		}
		densities[i] = weight / total_weight / width
		if math.is_inf(densities[i], 0) {
			return errors.error('WeightedHistogram density overflowed f64', .efailed)
		}
	}
	return densities
}

// density_area integrates densities over the configured range.
pub fn (o WeightedHistogram) density_area(total_weight f64) !f64 {
	densities := o.density(total_weight)!
	mut area := 0.0
	for i, density in densities {
		area += density * (o.stations[i + 1] - o.stations[i])
	}
	return area
}
