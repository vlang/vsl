module ml

import math

fn test_knn_regressor_uniform_prediction() {
	model := KNNRegressor.new([[0.0], [2.0], [4.0]], [0.0, 20.0, 40.0], k: 2)!
	assert model.predict([1.0])! == 10.0
}

fn test_knn_regressor_distance_weighting() {
	model := KNNRegressor.new([[0.0], [2.0]], [0.0, 20.0], k: 2, weighting: .distance)!
	assert model.predict([0.5])! == 5.0
}

fn test_knn_regressor_distance_weighting_averages_exact_matches() {
	model := KNNRegressor.new([[1.0], [1.0], [10.0]], [8.0, 12.0, 100.0],
		k:         3
		weighting: .distance
	)!
	assert model.predict([1.0])! == 10.0
}

fn test_knn_regressor_uniform_prediction_preserves_small_mixed_sign_target() {
	model := KNNRegressor.new([[1.0, 0.0], [-1.0, 0.0], [0.0, 1.0]], [
		1e308,
		1.0,
		-1e308,
	], k: 3)!
	assert math.abs(model.predict([0.0, 0.0])! - 1.0 / 3.0) < 1e-15
}

fn test_knn_regressor_distance_weighting_preserves_small_mixed_sign_target() {
	model := KNNRegressor.new([[1.0, 0.0], [-1.0, 0.0], [0.0, 1.0]], [
		1e308,
		1.0,
		-1e308,
	], k: 3, weighting: .distance)!
	assert math.abs(model.predict([0.0, 0.0])! - 1.0 / 3.0) < 1e-15
}

fn test_knn_regressor_predict_batch_preserves_query_order() {
	model := KNNRegressor.new([[0.0], [10.0]], [1.0, 9.0], k: 1)!
	predictions := model.predict_batch([[9.0], [1.0], [10.0]])!
	assert predictions == [9.0, 1.0, 9.0]
	assert model.predict_batch([])! == []
}

fn test_knn_regressor_rejects_invalid_training_data_and_k() {
	if _ := KNNRegressor.new([][]f64{}, []f64{}, k: 1) {
		assert false
	} else {
		assert true
	}
	if _ := KNNRegressor.new([[0.0], [1.0]], [0.0], k: 1) {
		assert false
	} else {
		assert true
	}
	if _ := KNNRegressor.new([[0.0]], [0.0], k: 0) {
		assert false
	} else {
		assert true
	}
	if _ := KNNRegressor.new([[0.0]], [0.0], k: 2) {
		assert false
	} else {
		assert true
	}
	if _ := KNNRegressor.new([[0.0], [1.0, 2.0]], [0.0, 1.0], k: 1) {
		assert false
	} else {
		assert true
	}
	if _ := KNNRegressor.new([[]f64{}], [0.0], k: 1) {
		assert false
	} else {
		assert true
	}
	if _ := KNNRegressor.new([[math.inf(1)]], [0.0], k: 1) {
		assert false
	} else {
		assert true
	}
}

fn test_knn_regressor_rejects_non_finite_training_targets_and_queries() {
	if _ := KNNRegressor.new([[0.0]], [math.nan()], k: 1) {
		assert false
	} else {
		assert true
	}
	if _ := KNNRegressor.new([[0.0]], [math.inf(1)], k: 1) {
		assert false
	} else {
		assert true
	}
	model := KNNRegressor.new([[0.0]], [1.0], k: 1)!
	if _ := model.predict([0.0, 1.0]) {
		assert false
	} else {
		assert true
	}
	if _ := model.predict([math.inf(1)]) {
		assert false
	} else {
		assert true
	}
}

fn test_knn_regressor_stabilizes_large_targets_and_small_distances() {
	large_target_model := KNNRegressor.new([[0.0], [1.0]], [1e308, 1e308], k: 2)!
	assert large_target_model.predict([0.0])! == 1e308
	large_weighted_model := KNNRegressor.new([[0.0], [2.0]], [1e308, 1e308],
		k:         2
		weighting: .distance
	)!
	assert large_weighted_model.predict([0.5])! == 1e308

	small_distance_model := KNNRegressor.new([[0.0], [1e-308]], [0.0, 10.0],
		k:         2
		metric:    .manhattan
		weighting: .distance
	)!
	assert small_distance_model.predict([5e-309])! == 5.0
}
