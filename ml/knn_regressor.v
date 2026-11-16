module ml

import math
import vsl.errors

// KNNWeighting selects how neighbors contribute to a regression prediction.
pub enum KNNWeighting {
	uniform
	distance
}

// KNNRegressorConfig configures a fixed-k nearest-neighbor regressor.
@[params]
pub struct KNNRegressorConfig {
pub:
	k         int            = 5
	metric    NeighborMetric = .euclidean
	weighting KNNWeighting   = .uniform
}

// KNNRegressor predicts continuous targets from the exact nearest training rows.
pub struct KNNRegressor {
	training [][]f64
	targets  []f64
	config   KNNRegressorConfig
}

// new validates and copies training data for a fixed-k regressor.
pub fn KNNRegressor.new(
	training [][]f64,
	targets []f64,
	config KNNRegressorConfig
) !KNNRegressor {
	if training.len == 0 {
		return errors.error('training data must contain at least one row', .einval)
	}
	if targets.len != training.len {
		return errors.error('training targets must have the same length as training rows',
			.einval)
	}
	for target in targets {
		if math.is_nan(target) || math.is_inf(target, 0) {
			return errors.error('training targets must be finite', .einval)
		}
	}
	// Reuse the exact-query validation so malformed features and k are rejected
	// during construction rather than on the first prediction.
	query_neighbors(training, [][]f64{}, config.k, config.metric)!
	return KNNRegressor{
		training: training.map(it.clone())
		targets:  targets.clone()
		config:   config
	}
}

// predict returns a prediction for one feature row.
pub fn (regressor &KNNRegressor) predict(query []f64) !f64 {
	neighbors := query_neighbors(regressor.training, [query], regressor.config.k,
		regressor.config.metric)!
	return regressor.predict_from_neighbors(neighbors.indices[0], neighbors.distances[0])!
}

// predict_batch predicts each query row in its input order.
pub fn (regressor &KNNRegressor) predict_batch(queries [][]f64) ![]f64 {
	neighbors := query_neighbors(regressor.training, queries, regressor.config.k,
		regressor.config.metric)!
	mut predictions := []f64{cap: queries.len}
	for i, indices in neighbors.indices {
		predictions << regressor.predict_from_neighbors(indices, neighbors.distances[i])!
	}
	return predictions
}

fn (regressor &KNNRegressor) predict_from_neighbors(indices []int, distances []f64) !f64 {
	if regressor.config.weighting == .uniform {
		mut values := []f64{cap: indices.len}
		for index in indices {
			values << regressor.targets[index]
		}
		return stable_uniform_mean(values)
	}

	mut exact_indices := []int{}
	for i, distance in distances {
		if distance == 0.0 {
			exact_indices << indices[i]
		}
	}
	// Exact matches take precedence over every nonzero-distance neighbor.
	if exact_indices.len > 0 {
		mut values := []f64{cap: exact_indices.len}
		for index in exact_indices {
			values << regressor.targets[index]
		}
		return stable_uniform_mean(values)
	}

	mut min_distance := distances[0]
	for distance in distances {
		if distance < min_distance {
			min_distance = distance
		}
	}
	mut scale := 0.0
	for index in indices {
		target_scale := math.abs(regressor.targets[index])
		if target_scale > scale {
			scale = target_scale
		}
	}
	if scale == 0.0 {
		return 0.0
	}

	mut weighted_sum := 0.0
	mut weight_sum := 0.0
	for i, index in indices {
		weight := min_distance / distances[i]
		weighted_sum += (regressor.targets[index] / scale) * weight
		weight_sum += weight
	}
	return finite_prediction((weighted_sum / weight_sum) * scale)!
}

fn stable_uniform_mean(values []f64) !f64 {
	mut scale := 0.0
	for value in values {
		value_scale := math.abs(value)
		if value_scale > scale {
			scale = value_scale
		}
	}
	if scale == 0.0 {
		return 0.0
	}
	mut scaled_sum := 0.0
	for value in values {
		scaled_sum += value / scale
	}
	return finite_prediction((scaled_sum / f64(values.len)) * scale)!
}

fn finite_prediction(value f64) !f64 {
	if math.is_nan(value) || math.is_inf(value, 0) {
		return errors.error('prediction must be finite', .einval)
	}
	return value
}
