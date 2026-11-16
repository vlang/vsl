module ml

import math
import vsl.errors

// RadiusNeighborsWeighting selects how matching rows contribute to a prediction.
pub enum RadiusNeighborsWeighting {
	uniform
	inverse_distance
}

// RadiusNeighborsVoteWeights remains available for existing classifier callers.
pub type RadiusNeighborsVoteWeights = RadiusNeighborsWeighting

// RadiusNeighborsClassifierConfig controls a radius-neighbor classifier.
pub struct RadiusNeighborsClassifierConfig {
pub:
	radius  f64
	metric  NeighborMetric
	weights RadiusNeighborsWeighting
}

// RadiusNeighborsClassifier predicts a numeric class from all training rows
// within a configured radius. It owns copies of its training rows and labels.
@[heap]
pub struct RadiusNeighborsClassifier {
	training [][]f64
	labels   []f64
	config   RadiusNeighborsClassifierConfig
}

// RadiusNeighborsClassifier.new validates and copies training rows and labels.
pub fn RadiusNeighborsClassifier.new(training [][]f64, labels []f64, config RadiusNeighborsClassifierConfig) !&RadiusNeighborsClassifier {
	if labels.len != training.len {
		return errors.error('labels must have the same number of entries as training rows',
			.einval)
	}
	for label in labels {
		if math.is_nan(label) || math.is_inf(label, 0) {
			return errors.error('class labels must be finite', .einval)
		}
	}
	// Reuse the query primitive's radius, shape, and feature validation without
	// computing pairwise training distances during construction.
	radius_neighbors(training, [][]f64{}, config.radius, config.metric)!

	mut training_copy := [][]f64{cap: training.len}
	for row in training {
		training_copy << row.clone()
	}
	return &RadiusNeighborsClassifier{
		training: training_copy
		labels:   labels.clone()
		config:   config
	}
}

// predict returns the winning class for one query row.
pub fn (classifier &RadiusNeighborsClassifier) predict(query []f64) !f64 {
	return classifier.predict_batch([query])![0]
}

// predict_batch predicts each query row in input order. A query with no
// training rows inside the configured radius returns an error.
pub fn (classifier &RadiusNeighborsClassifier) predict_batch(queries [][]f64) ![]f64 {
	neighbors := radius_neighbors(classifier.training, queries, classifier.config.radius,
		classifier.config.metric)!
	mut predictions := []f64{cap: queries.len}
	for query_index, indices in neighbors.indices {
		predictions << classifier.vote(indices, neighbors.distances[query_index])!
	}
	return predictions
}

fn (classifier &RadiusNeighborsClassifier) vote(indices []int, distances []f64) !f64 {
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

	mut scores := map[f64]f64{}
	for neighbor_index, training_index in indices {
		distance := distances[neighbor_index]
		if classifier.config.weights == .inverse_distance && exact_match_count > 0
			&& distance != 0.0 {
			continue
		}
		weight := match classifier.config.weights {
			.uniform { 1.0 }
			.inverse_distance {
				if exact_match_count > 0 {
					1.0
				} else {
					// Scaling every inverse-distance weight by the same nearest
					// distance preserves the winner while avoiding reciprocal overflow.
					nearest_nonzero_distance / distance
				}
			}
		}
		label := classifier.labels[training_index]
		scores[label] += weight
	}

	mut best_label := math.max_f64
	mut best_score := -1.0
	for label, score in scores {
		if score > best_score || (score == best_score && label < best_label) {
			best_label = label
			best_score = score
		}
	}
	return best_label
}
