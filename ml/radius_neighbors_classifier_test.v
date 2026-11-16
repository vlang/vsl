module ml

import math

fn test_radius_neighbors_classifier_uniform_and_inverse_distance_weights() {
	training := [[0.5], [1.5]]
	labels := [5.0, -2.0]
	uniform := RadiusNeighborsClassifier.new(training, labels, RadiusNeighborsClassifierConfig{
		radius:  2.0
		metric:  .euclidean
		weights: .uniform
	})!
	inverse := RadiusNeighborsClassifier.new(training, labels, RadiusNeighborsClassifierConfig{
		radius:  2.0
		metric:  .euclidean
		weights: .inverse_distance
	})!

	assert uniform.predict([0.0])! == -2.0
	assert inverse.predict([0.0])! == 5.0
}

fn test_radius_neighbors_classifier_exact_duplicates_override_nonzero_distances() {
	model := RadiusNeighborsClassifier.new([[0.0], [0.0], [0.25]], [4.0, 2.0, 100.0],
		RadiusNeighborsClassifierConfig{
			radius:  1.0
			metric:  .manhattan
			weights: .inverse_distance
		})!

	assert model.predict([0.0])! == 2.0
}

fn test_radius_neighbors_classifier_ties_choose_smallest_numeric_label() {
	model := RadiusNeighborsClassifier.new([[1.0], [-1.0]], [9.0, -3.0],
		RadiusNeighborsClassifierConfig{
			radius:  1.0
			metric:  .euclidean
			weights: .uniform
		})!

	assert model.predict([0.0])! == -3.0
}

fn test_radius_neighbors_classifier_batch_preserves_query_order() {
	model := RadiusNeighborsClassifier.new([[0.0], [10.0]], [10.0, -1.0],
		RadiusNeighborsClassifierConfig{
			radius:  0.5
			metric:  .euclidean
			weights: .uniform
		})!

	assert model.predict_batch([[10.0], [0.0], [10.0]])! == [-1.0, 10.0, -1.0]
}

fn test_radius_neighbors_classifier_empty_neighborhood_returns_error() {
	model := RadiusNeighborsClassifier.new([[0.0]], [1.0], RadiusNeighborsClassifierConfig{
		radius:  0.5
		metric:  .euclidean
		weights: .uniform
	})!

	_ := model.predict([2.0]) or { return }
	assert false
}

fn test_radius_neighbors_classifier_validates_configuration_and_training() {
	assert_radius_neighbors_classifier_errors([], [], RadiusNeighborsClassifierConfig{
		radius:  1.0
		metric:  .euclidean
		weights: .uniform
	})
	assert_radius_neighbors_classifier_errors([[0.0]], [], RadiusNeighborsClassifierConfig{
		radius:  1.0
		metric:  .euclidean
		weights: .uniform
	})
	assert_radius_neighbors_classifier_errors([[0.0], [1.0, 2.0]], [0.0, 1.0],
		RadiusNeighborsClassifierConfig{
			radius:  1.0
			metric:  .euclidean
			weights: .uniform
		})
	assert_radius_neighbors_classifier_errors([[]], [0.0], RadiusNeighborsClassifierConfig{
		radius:  1.0
		metric:  .euclidean
		weights: .uniform
	})
	assert_radius_neighbors_classifier_errors([[0.0]], [math.nan()],
		RadiusNeighborsClassifierConfig{
			radius:  1.0
			metric:  .euclidean
			weights: .uniform
		})
	assert_radius_neighbors_classifier_errors([[0.0]], [math.inf(1)],
		RadiusNeighborsClassifierConfig{
			radius:  1.0
			metric:  .euclidean
			weights: .uniform
		})
	assert_radius_neighbors_classifier_errors([[math.inf(1)]], [0.0],
		RadiusNeighborsClassifierConfig{
			radius:  1.0
			metric:  .euclidean
			weights: .uniform
		})
	assert_radius_neighbors_classifier_errors([[0.0]], [0.0], RadiusNeighborsClassifierConfig{
		radius:  -1.0
		metric:  .euclidean
		weights: .uniform
	})
	assert_radius_neighbors_classifier_errors([[0.0]], [0.0], RadiusNeighborsClassifierConfig{
		radius:  math.nan()
		metric:  .manhattan
		weights: .inverse_distance
	})
	assert_radius_neighbors_classifier_errors([[0.0]], [0.0], RadiusNeighborsClassifierConfig{
		radius:  math.inf(1)
		metric:  .manhattan
		weights: .inverse_distance
	})
}

fn test_radius_neighbors_classifier_rejects_nonfinite_queries_and_overflow_distances() {
	model := RadiusNeighborsClassifier.new([[0.0]], [1.0], RadiusNeighborsClassifierConfig{
		radius:  math.max_f64
		metric:  .manhattan
		weights: .uniform
	})!
	assert_radius_neighbors_classifier_predict_errors(model, [math.nan()])
	assert_radius_neighbors_classifier_predict_errors(model, [0.0, 1.0])

	overflow_model := RadiusNeighborsClassifier.new([[-math.max_f64]], [1.0],
		RadiusNeighborsClassifierConfig{
			radius:  math.max_f64
			metric:  .manhattan
			weights: .uniform
		})!
	assert_radius_neighbors_classifier_predict_errors(overflow_model, [math.max_f64])
}

fn test_radius_neighbors_classifier_owns_copies_of_training_data() {
	mut training := [[0.0], [1.0]]
	mut labels := [2.0, 1.0]
	model := RadiusNeighborsClassifier.new(training, labels, RadiusNeighborsClassifierConfig{
		radius:  0.1
		metric:  .euclidean
		weights: .uniform
	})!

	training[0][0] = 10.0
	labels[0] = 99.0
	assert model.predict([0.0])! == 2.0
}

fn assert_radius_neighbors_classifier_errors(training [][]f64, labels []f64, config RadiusNeighborsClassifierConfig) {
	_ := RadiusNeighborsClassifier.new(training, labels, config) or { return }
	assert false
}

fn assert_radius_neighbors_classifier_predict_errors(model &RadiusNeighborsClassifier, query []f64) {
	_ := model.predict(query) or { return }
	assert false
}
