module ml

import math

fn test_query_neighbors_returns_exact_euclidean_results() {
	result := query_neighbors([
		[0.0, 0.0],
		[3.0, 4.0],
		[1.0, 0.0],
	], [[0.0, 0.0], [2.0, 4.0]], 2, .euclidean)!

	assert result.indices == [[0, 2], [1, 2]]
	assert result.distances[0] == [0.0, 1.0]
	assert math.abs(result.distances[1][0] - 1.0) < 1e-12
	assert math.abs(result.distances[1][1] - math.sqrt(17.0)) < 1e-12
}

fn test_query_neighbors_supports_manhattan_distance() {
	result := query_neighbors([
		[0.0, 0.0],
		[2.0, 2.0],
		[3.0, 0.0],
	], [[0.0, 0.0]], 2, .manhattan)!

	assert result.indices == [[0, 2]]
	assert result.distances == [[0.0, 3.0]]
}

fn test_query_neighbors_orders_ties_by_training_index_and_keeps_duplicates() {
	result := query_neighbors([
		[1.0, 0.0],
		[-1.0, 0.0],
		[1.0, 0.0],
		[0.0, 0.0],
	], [[0.0, 0.0]], 4, .euclidean)!

	assert result.indices == [[3, 0, 1, 2]]
	assert result.distances == [[0.0, 1.0, 1.0, 1.0]]
}

fn test_query_neighbors_validates_shapes_and_k() {
	assert_neighbor_query_errors([], [[0.0]], 1, .euclidean)
	assert_neighbor_query_errors([[]], [[]], 1, .euclidean)
	assert_neighbor_query_errors([[0.0], [1.0, 2.0]], [[0.0]], 1, .euclidean)
	assert_neighbor_query_errors([[0.0]], [[0.0]], 0, .euclidean)
	assert_neighbor_query_errors([[0.0]], [[0.0]], 2, .euclidean)
	assert_neighbor_query_errors([[0.0, 1.0]], [[0.0]], 1, .euclidean)
	assert_neighbor_query_errors([[0.0]], [[0.0], [1.0, 2.0]], 1, .manhattan)
	assert_neighbor_query_errors([[math.nan()]], [[0.0]], 1, .euclidean)
}

fn test_query_neighbors_rejects_overflowing_distances() {
	assert_neighbor_query_errors([[-math.max_f64]], [[math.max_f64]], 1, .euclidean)
	assert_neighbor_query_errors([[-math.max_f64]], [[math.max_f64]], 1, .manhattan)
	assert_neighbor_query_errors([[0.0, 0.0]], [[math.max_f64, math.max_f64]], 1, .manhattan)
}

fn test_query_neighbors_accepts_empty_query_batch() {
	result := query_neighbors([[1.0], [2.0]], [][]f64{}, 1, .euclidean)!
	assert result.indices.len == 0
	assert result.distances.len == 0
}

fn test_query_neighbors_handles_large_query_batch() {
	mut queries := [][]f64{cap: 512}
	for i in 0 .. 512 {
		queries << [f64(i)]
	}
	result := query_neighbors([[0.0], [10.0], [1000.0]], queries, 2, .manhattan)!

	assert result.indices.len == 512
	assert result.distances.len == 512
	assert result.indices[0] == [0, 1]
	assert result.indices[511] == [2, 1]
	assert result.distances[511] == [489.0, 501.0]
}

fn assert_neighbor_query_errors(training [][]f64, queries [][]f64, k int, metric NeighborMetric) {
	_ := query_neighbors(training, queries, k, metric) or { return }
	assert false
}
