module ml

import math
import vsl.errors

// RadiusNeighborsRegressorConfig controls a radius-neighbor regressor.
pub struct RadiusNeighborsRegressorConfig {
pub:
	radius  f64
	metric  NeighborMetric
	weights RadiusNeighborsWeighting
}

// RadiusNeighborsRegressor predicts a numeric target from all training rows
// within a configured radius. It owns copies of its training rows and targets.
@[heap]
pub struct RadiusNeighborsRegressor {
	training [][]f64
	targets  []f64
	config   RadiusNeighborsRegressorConfig
}

// RadiusNeighborsRegressor.new validates and copies training rows and targets.
pub fn RadiusNeighborsRegressor.new(training [][]f64, targets []f64, config RadiusNeighborsRegressorConfig) !&RadiusNeighborsRegressor {
	if targets.len != training.len {
		return errors.error('targets must have the same number of entries as training rows',
			.einval)
	}
	for target in targets {
		if math.is_nan(target) || math.is_inf(target, 0) {
			return errors.error('targets must be finite', .einval)
		}
	}
	// Reuse the query primitive's radius, shape, and feature validation without
	// computing pairwise training distances during construction.
	radius_neighbors(training, [][]f64{}, config.radius, config.metric)!

	mut training_copy := [][]f64{cap: training.len}
	for row in training {
		training_copy << row.clone()
	}
	return &RadiusNeighborsRegressor{
		training: training_copy
		targets:  targets.clone()
		config:   config
	}
}

// predict returns the estimated target for one query row.
pub fn (regressor &RadiusNeighborsRegressor) predict(query []f64) !f64 {
	return regressor.predict_batch([query])![0]
}

// predict_batch predicts each query row in input order. A query with no
// training rows inside the configured radius returns an error.
pub fn (regressor &RadiusNeighborsRegressor) predict_batch(queries [][]f64) ![]f64 {
	neighbors := radius_neighbors(regressor.training, queries, regressor.config.radius,
		regressor.config.metric)!
	mut predictions := []f64{cap: queries.len}
	for query_index, indices in neighbors.indices {
		prediction := regressor.average(indices, neighbors.distances[query_index])!
		if math.is_nan(prediction) || math.is_inf(prediction, 0) {
			return errors.error('predicted targets must be finite', .efailed)
		}
		predictions << prediction
	}
	return predictions
}

fn (regressor &RadiusNeighborsRegressor) average(indices []int, distances []f64) !f64 {
	if indices.len == 0 {
		return errors.error('no training rows found within the configured radius', .efailed)
	}

	mut exact_match_count := 0
	mut nearest_nonzero_distance := math.max_f64
	for distance in distances {
		if distance == 0.0 {
			exact_match_count++
		} else if distance < nearest_nonzero_distance {
			nearest_nonzero_distance = distance
		}
	}

	if regressor.config.weights == .inverse_distance && exact_match_count > 0 {
		mut exact_indices := []int{cap: exact_match_count}
		for i, distance in distances {
			if distance == 0.0 {
				exact_indices << indices[i]
			}
		}
		return stable_target_average(regressor.targets, exact_indices, []f64{})
	}

	mut weights := []f64{cap: indices.len}
	if regressor.config.weights == .inverse_distance {
		for distance in distances {
			// Scaling by the nearest distance keeps weights in (0, 1] and
			// avoids overflowing reciprocals for tiny positive distances.
			weights << nearest_nonzero_distance / distance
		}
	}
	return stable_target_average(regressor.targets, indices, weights)
}

fn stable_target_average(targets []f64, indices []int, weights []f64) !f64 {
	mut target_scale := 0.0
	for index in indices {
		target_scale = math.max(target_scale, math.abs(targets[index]))
	}
	if target_scale == 0.0 {
		return 0.0
	}

	mut scaled_sum := 0.0
	mut weight_sum := 0.0
	for position, index in indices {
		weight := if weights.len == 0 { 1.0 } else { weights[position] }
		scaled_sum += (targets[index] / target_scale) * weight
		weight_sum += weight
	}
	if math.is_nan(scaled_sum) || math.is_inf(scaled_sum, 0) || weight_sum <= 0.0
		|| math.is_nan(weight_sum) || math.is_inf(weight_sum, 0) {
		return errors.error('target average accumulation must be finite', .efailed)
	}

	normalized_mean := scaled_sum / weight_sum
	if math.is_nan(normalized_mean) || math.is_inf(normalized_mean, 0) {
		return errors.error('predicted targets must be finite', .efailed)
	}
	// Floating-point accumulation can exceed the convex range by a final ulp.
	// Clamp only that normalized ratio before scaling by the largest target.
	bounded_mean := math.max(-1.0, math.min(1.0, normalized_mean))
	result := bounded_mean * target_scale
	if math.is_nan(result) || math.is_inf(result, 0) {
		return errors.error('predicted targets must be finite', .efailed)
	}
	return result
}
