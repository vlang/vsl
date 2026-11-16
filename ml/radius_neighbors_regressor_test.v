module ml

import math

fn test_radius_neighbors_regressor_uniform_and_inverse_distance_weights() {
	training := [[1.0], [2.0]]
	targets := [0.0, 10.0]
	uniform := RadiusNeighborsRegressor.new(training, targets, RadiusNeighborsRegressorConfig{
		radius:  3.0
		metric:  .euclidean
		weights: .uniform
	})!
	inverse := RadiusNeighborsRegressor.new(training, targets, RadiusNeighborsRegressorConfig{
		radius:  3.0
		metric:  .euclidean
		weights: .inverse_distance
	})!

	assert uniform.predict([0.0])! == 5.0
	assert math.abs(inverse.predict([0.0])! - (10.0 / 3.0)) < 1e-12
}

fn test_radius_neighbors_regressor_exact_matches_are_averaged_uniformly() {
	model := RadiusNeighborsRegressor.new([[0.0], [0.0], [0.25]], [2.0, 4.0, 100.0],
		RadiusNeighborsRegressorConfig{
			radius:  1.0
			metric:  .manhattan
			weights: .inverse_distance
		})!

	assert model.predict([0.0])! == 3.0
}

fn test_radius_neighbors_regressor_batch_preserves_query_order() {
	model := RadiusNeighborsRegressor.new([[0.0], [10.0]], [10.0, -1.0],
		RadiusNeighborsRegressorConfig{
			radius:  0.5
			metric:  .euclidean
			weights: .uniform
		})!

	assert model.predict_batch([[10.0], [0.0], [10.0]])! == [-1.0, 10.0, -1.0]
}

fn test_radius_neighbors_regressor_empty_neighborhood_returns_error() {
	model := RadiusNeighborsRegressor.new([[0.0]], [1.0], RadiusNeighborsRegressorConfig{
		radius:  0.5
		metric:  .euclidean
		weights: .uniform
	})!

	_ := model.predict([2.0]) or { return }
	assert false
}

fn test_radius_neighbors_regressor_validates_shapes_radius_and_targets() {
	assert_radius_neighbors_regressor_errors([], [], RadiusNeighborsRegressorConfig{
		radius:  1.0
		metric:  .euclidean
		weights: .uniform
	})
	assert_radius_neighbors_regressor_errors([[0.0]], [], RadiusNeighborsRegressorConfig{
		radius:  1.0
		metric:  .euclidean
		weights: .uniform
	})
	assert_radius_neighbors_regressor_errors([[0.0], [1.0]], [0.0], RadiusNeighborsRegressorConfig{
		radius:  1.0
		metric:  .euclidean
		weights: .uniform
	})
	assert_radius_neighbors_regressor_errors([[0.0], [1.0, 2.0]], [0.0, 1.0],
		RadiusNeighborsRegressorConfig{
			radius:  1.0
			metric:  .euclidean
			weights: .uniform
		})
	assert_radius_neighbors_regressor_errors([[]], [0.0], RadiusNeighborsRegressorConfig{
		radius:  1.0
		metric:  .euclidean
		weights: .uniform
	})
	assert_radius_neighbors_regressor_errors([[0.0]], [math.nan()], RadiusNeighborsRegressorConfig{
		radius:  1.0
		metric:  .euclidean
		weights: .uniform
	})
	assert_radius_neighbors_regressor_errors([[0.0]], [math.inf(1)],
		RadiusNeighborsRegressorConfig{
			radius:  1.0
			metric:  .euclidean
			weights: .uniform
		})
	assert_radius_neighbors_regressor_errors([[math.inf(1)]], [0.0],
		RadiusNeighborsRegressorConfig{
			radius:  1.0
			metric:  .euclidean
			weights: .uniform
		})
	assert_radius_neighbors_regressor_errors([[0.0]], [0.0], RadiusNeighborsRegressorConfig{
		radius:  -1.0
		metric:  .euclidean
		weights: .uniform
	})
	assert_radius_neighbors_regressor_errors([[0.0]], [0.0], RadiusNeighborsRegressorConfig{
		radius:  math.nan()
		metric:  .manhattan
		weights: .inverse_distance
	})
	assert_radius_neighbors_regressor_errors([[0.0]], [0.0], RadiusNeighborsRegressorConfig{
		radius:  math.inf(1)
		metric:  .manhattan
		weights: .inverse_distance
	})
}

fn test_radius_neighbors_regressor_rejects_bad_queries_and_overflow_distances() {
	model := RadiusNeighborsRegressor.new([[0.0]], [1.0], RadiusNeighborsRegressorConfig{
		radius:  math.max_f64
		metric:  .manhattan
		weights: .uniform
	})!
	assert_radius_neighbors_regressor_predict_errors(model, [math.nan()])
	assert_radius_neighbors_regressor_predict_errors(model, [0.0, 1.0])

	overflow_model := RadiusNeighborsRegressor.new([[-math.max_f64]], [1.0],
		RadiusNeighborsRegressorConfig{
			radius:  math.max_f64
			metric:  .manhattan
			weights: .uniform
		})!
	assert_radius_neighbors_regressor_predict_errors(overflow_model, [math.max_f64])
}

fn test_radius_neighbors_regressor_owns_copies_of_training_data() {
	mut training := [[0.0], [1.0]]
	mut targets := [2.0, 99.0]
	model := RadiusNeighborsRegressor.new(training, targets, RadiusNeighborsRegressorConfig{
		radius:  0.1
		metric:  .euclidean
		weights: .uniform
	})!

	training[0][0] = 10.0
	targets[0] = -99.0
	assert model.predict([0.0])! == 2.0
}

fn test_radius_neighbors_regressor_stable_averages_large_targets() {
	model := RadiusNeighborsRegressor.new([[0.0], [0.0]], [math.max_f64, math.max_f64],
		RadiusNeighborsRegressorConfig{
			radius:  0.0
			metric:  .euclidean
			weights: .uniform
		})!
	assert model.predict([0.0])! == math.max_f64

	cancelling := RadiusNeighborsRegressor.new([[0.0], [0.0]], [math.max_f64, -math.max_f64],
		RadiusNeighborsRegressorConfig{
			radius:  0.0
			metric:  .euclidean
			weights: .uniform
		})!
	assert cancelling.predict([0.0])! == 0.0
}

fn test_radius_neighbors_regressor_stable_inverse_weights_for_tiny_distances() {
	model := RadiusNeighborsRegressor.new([[1e-300], [2e-300]], [math.max_f64, -math.max_f64],
		RadiusNeighborsRegressorConfig{
			radius:  3e-300
			metric:  .manhattan
			weights: .inverse_distance
		})!

	prediction := model.predict([0.0])!
	assert !math.is_nan(prediction)
	assert !math.is_inf(prediction, 0)
	assert prediction > 0.0
}

fn assert_radius_neighbors_regressor_errors(training [][]f64, targets []f64, config RadiusNeighborsRegressorConfig) {
	_ := RadiusNeighborsRegressor.new(training, targets, config) or { return }
	assert false
}

fn assert_radius_neighbors_regressor_predict_errors(model &RadiusNeighborsRegressor, query []f64) {
	_ := model.predict(query) or { return }
	assert false
}
