module model_selection

import vsl.metrics

fn first_feature_predictor(x [][]f64) ![]f64 {
	mut predictions := []f64{cap: x.len}
	for row in x {
		predictions << row[0]
	}
	return predictions
}

fn second_feature_predictor(x [][]f64) ![]f64 {
	mut predictions := []f64{cap: x.len}
	for row in x {
		predictions << row[1]
	}
	return predictions
}

fn test_permutation_importance_regression_is_deterministic() {
	x := [[0.0, 10.0], [1.0, 10.0], [2.0, 10.0], [3.0, 10.0]]
	y := [0.0, 1.0, 2.0, 3.0]
	result := permutation_importance(x, y, first_feature_predictor, metrics.r2_score, PermutationImportanceConfig{
		n_repeats: 4
		random_seed: 7
	})!
	repeated := permutation_importance(x, y, first_feature_predictor, metrics.r2_score, PermutationImportanceConfig{
		n_repeats: 4
		random_seed: 7
	})!

	assert result.baseline_score == 1.0
	assert result.importances_mean[0] == repeated.importances_mean[0]
	assert result.importances_mean[0] > 0.0
	assert result.importances_mean[1] == 0.0
	assert result.importances_std.len == 2
}

fn test_permutation_importance_classification_and_grouped_columns() {
	x := [[0.0, 0.0, 3.0], [0.0, 0.0, 3.0], [1.0, 1.0, 3.0], [1.0, 1.0, 3.0]]
	y := [0.0, 0.0, 1.0, 1.0]
	result := permutation_importance(x, y, second_feature_predictor, metrics.accuracy_score, PermutationImportanceConfig{
		n_repeats: 3
		random_seed: 11
		feature_groups: [[0, 1], [2]]
	})!

	assert result.baseline_score == 1.0
	assert result.feature_groups == [[0, 1], [2]]
	assert result.importances_mean[0] > 0.0
	assert result.importances_mean[1] == 0.0
}

fn test_permutation_importance_does_not_mutate_input() {
	x := [[0.0, 4.0], [1.0, 5.0], [2.0, 6.0]]
	original := x.clone()
	y := [0.0, 1.0, 2.0]
	permutation_importance(x, y, first_feature_predictor, metrics.r2_score, PermutationImportanceConfig{ n_repeats: 2 })!
	assert x == original
}

fn test_permutation_importance_rejects_invalid_groups() {
	x := [[0.0], [1.0]]
	y := [0.0, 1.0]
	assert permutation_fails_for_invalid_group(x, y)
}

fn permutation_fails_for_invalid_group(x [][]f64, y []f64) bool {
	permutation_importance(x, y, first_feature_predictor, metrics.r2_score, PermutationImportanceConfig{
		feature_groups: [[1]]
	}) or {
		return true
	}
	return false
}
