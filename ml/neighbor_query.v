module ml

import vsl.errors
import vsl.float.float64 { l2_distance_unitary }
import math

// NeighborMetric selects the exact distance measure for a neighbor query.
pub enum NeighborMetric {
	euclidean
	manhattan
}

// NeighborQueryResult stores the sorted neighbors for each query row.
// The outer arrays follow query order; each inner row is ordered by distance,
// then by original training-row index.
pub struct NeighborQueryResult {
pub:
	indices   [][]int
	distances [][]f64
}

struct NeighborCandidate {
	index    int
	distance f64
}

// query_neighbors returns the exact top-k training rows for every query row.
// This is a brute-force search, not a classifier, regressor, or indexed
// nearest-neighbor backend. It computes distances one training row at a time
// and does not allocate a query-by-training distance matrix.
pub fn query_neighbors(training [][]f64, queries [][]f64, k int, metric NeighborMetric) !NeighborQueryResult {
	if training.len == 0 {
		return errors.error('training data must contain at least one row', .einval)
	}
	feature_count := training[0].len
	if feature_count == 0 {
		return errors.error('training rows must contain at least one feature', .einval)
	}
	if k < 1 || k > training.len {
		return errors.error('k must be between 1 and the number of training rows', .einval)
	}
	for row_index, row in training {
		if row.len != feature_count {
			return errors.error('training row ${row_index} has an inconsistent feature width', .einval)
		}
		for value in row {
			if math.is_nan(value) || math.is_inf(value, 0) {
				return errors.error('training features must be finite', .einval)
			}
		}
	}
	for row_index, row in queries {
		if row.len != feature_count {
			return errors.error('query row ${row_index} must have ${feature_count} features', .einval)
		}
		for value in row {
			if math.is_nan(value) || math.is_inf(value, 0) {
				return errors.error('query features must be finite', .einval)
			}
		}
	}

	mut indices := [][]int{cap: queries.len}
	mut distances := [][]f64{cap: queries.len}
	mut candidates := []NeighborCandidate{len: training.len}
	for query in queries {
		for index, row in training {
			distance := neighbor_distance(query, row, metric)
			if math.is_nan(distance) || math.is_inf(distance, 0) {
				return errors.error('computed neighbor distances must be finite', .einval)
			}
			candidates[index] = NeighborCandidate{
				index:    index
				distance: distance
			}
		}
		candidates.sort_with_compare(compare_neighbor_candidates)

		mut neighbor_indices := []int{cap: k}
		mut neighbor_distances := []f64{cap: k}
		for candidate in candidates[..k] {
			neighbor_indices << candidate.index
			neighbor_distances << candidate.distance
		}
		indices << neighbor_indices
		distances << neighbor_distances
	}
	return NeighborQueryResult{
		indices:   indices
		distances: distances
	}
}

fn neighbor_distance(query []f64, training []f64, metric NeighborMetric) f64 {
	return match metric {
		.euclidean { l2_distance_unitary(query, training) }
		.manhattan {
			mut distance := 0.0
			for index, value in query {
				distance += math.abs(value - training[index])
			}
			distance
		}
	}
}

fn compare_neighbor_candidates(a &NeighborCandidate, b &NeighborCandidate) int {
	if a.distance < b.distance {
		return -1
	}
	if a.distance > b.distance {
		return 1
	}
	if a.index < b.index {
		return -1
	}
	if a.index > b.index {
		return 1
	}
	return 0
}
