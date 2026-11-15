module model_selection

import math

fn predict_first_feature(_x_train [][]f64, _y_train []f64, x_test [][]f64) ![]f64 {
	mut predictions := []f64{cap: x_test.len}
	for row in x_test {
		predictions << row[0]
	}
	return predictions
}

fn exact_match_score(y_true []f64, y_pred []f64) !f64 {
	if y_true.len != y_pred.len || y_true.len == 0 {
		return error('score inputs must have equal non-zero lengths')
	}
	mut correct := 0
	for i, value in y_true {
		if value == y_pred[i] {
			correct++
		}
	}
	return f64(correct) / f64(y_true.len)
}

fn predict_no_values(_x_train [][]f64, _y_train []f64, _x_test [][]f64) ![]f64 {
	return []f64{}
}

fn failing_score(_y_true []f64, _y_pred []f64) !f64 {
	return error('scorer failed')
}

fn mean_prediction_factory(_x_train [][]f64, y_train []f64) !FoldPrediction {
	mut sum := 0.0
	for value in y_train {
		sum += value
	}
	mean := sum / f64(y_train.len)
	return fn [mean] (x_test [][]f64) ![]f64 {
		mut predictions := []f64{cap: x_test.len}
		for _ in x_test {
			predictions << mean
		}
		return predictions
	}
}

fn mean_prediction_score(_y_true []f64, y_pred []f64) !f64 {
	mut sum := 0.0
	for value in y_pred {
		sum += value
	}
	return sum / f64(y_pred.len)
}

fn nan_score(_y_true []f64, _y_pred []f64) !f64 {
	return math.nan()
}

fn offset_mean_factory(offset f64) FoldEstimatorFactory {
	return fn [offset] (_x_train [][]f64, y_train []f64) !FoldPrediction {
		mut sum := 0.0
		for value in y_train {
			sum += value
		}
		prediction := sum / f64(y_train.len) + offset
		return fn [prediction] (x_test [][]f64) ![]f64 {
			mut predictions := []f64{cap: x_test.len}
			for _ in x_test {
				predictions << prediction
			}
			return predictions
		}
	}
}

fn test_kfold_basic() {
	kf := KFold.new(5, false, 42)
	folds := kf.split(100)!

	assert folds.len == 5

	// Each fold should have 20 test samples
	for fold in folds {
		assert fold.test_indices.len == 20
		assert fold.train_indices.len == 80
	}
}

fn test_kfold_uneven() {
	kf := KFold.new(3, false, 42)
	folds := kf.split(10)!

	assert folds.len == 3

	// 10 / 3 = 3 with remainder 1
	// First fold gets 4, others get 3
	mut total_test := 0
	for fold in folds {
		total_test += fold.test_indices.len
	}
	assert total_test == 10
}

fn test_kfold_no_overlap() {
	kf := KFold.new(5, false, 42)
	folds := kf.split(50)!

	// Test indices should not overlap between folds
	mut all_test_indices := map[int]bool{}
	for fold in folds {
		for idx in fold.test_indices {
			assert idx !in all_test_indices, 'overlap detected'
			all_test_indices[idx] = true
		}
	}

	// All indices should be covered
	assert all_test_indices.len == 50
}

fn test_kfold_train_test_disjoint() {
	kf := KFold.new(3, false, 42)
	folds := kf.split(30)!

	for fold in folds {
		test_set := array_to_set(fold.test_indices)
		for train_idx in fold.train_indices {
			assert train_idx !in test_set, 'train and test overlap'
		}
	}
}

fn test_stratified_kfold_basic() {
	y := [0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0]

	skf := StratifiedKFold.new(5, false, 42)
	folds := skf.split(y)!

	assert folds.len == 5

	// Each fold should maintain class balance in test set
	for fold in folds {
		mut class_0 := 0
		mut class_1 := 0
		for idx in fold.test_indices {
			if y[idx] == 0.0 {
				class_0++
			} else {
				class_1++
			}
		}
		// With 10 samples and 5 folds, each fold gets 1 sample per class
		assert class_0 == 1
		assert class_1 == 1
	}
}

fn test_stratified_kfold_keeps_fractional_labels_distinct() ! {
	y := [0.25, 0.25, 0.25, 0.25, 0.75, 0.75, 0.75, 0.75]
	skf := StratifiedKFold.new(2, false, 42)
	folds := skf.split(y)!

	for fold in folds {
		mut lower_class := 0
		mut upper_class := 0
		for index in fold.test_indices {
			if y[index] == 0.25 {
				lower_class++
			} else if y[index] == 0.75 {
				upper_class++
			}
		}
		assert lower_class == 2
		assert upper_class == 2
	}
}

fn test_stratified_kfold_balances_folds_when_classes_are_small() ! {
	y := [0.0, 1.0, 2.0, 3.0]
	skf := StratifiedKFold.new(2, false, 42)
	folds := skf.split(y)!

	assert folds[0].test_indices.len == 2
	assert folds[1].test_indices.len == 2
	assert folds[0].test_indices == [0, 2]
	assert folds[1].test_indices == [1, 3]
}

fn test_leave_one_out() {
	loo := LeaveOneOut.new()
	folds := loo.split(5)

	assert folds.len == 5

	for i, fold in folds {
		assert fold.test_indices.len == 1
		assert fold.test_indices[0] == i
		assert fold.train_indices.len == 4
	}
}

fn test_shuffle_split() {
	ss := ShuffleSplit.new(3, 0.2, 42)
	folds := ss.split(100)!

	assert folds.len == 3

	for fold in folds {
		assert fold.test_indices.len == 20
		assert fold.train_indices.len == 80
	}
}

fn test_shuffle_split_different_seeds() {
	ss := ShuffleSplit.new(3, 0.2, 42)
	folds := ss.split(100)!

	// Each split should be different
	assert folds[0].test_indices != folds[1].test_indices
	assert folds[1].test_indices != folds[2].test_indices
}

fn test_get_fold_data() {
	x := [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0], [7.0, 8.0]]
	y := [0.0, 1.0, 0.0, 1.0]

	fold := Fold{
		train_indices: [0, 1, 2]
		test_indices:  [3]
	}

	x_train, y_train, x_test, y_test := get_fold_data(x, y, fold)

	assert x_train.len == 3
	assert y_train.len == 3
	assert x_test.len == 1
	assert y_test.len == 1
	assert x_test[0] == [7.0, 8.0]
	assert y_test[0] == 1.0
}

fn test_cross_val_score_runs_predictor_and_scorer_for_each_fold() ! {
	x := [[0.0], [1.0], [2.0], [3.0], [4.0], [5.0]]
	y := [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
	folds := KFold.new(3, false, 42).split(y.len)!

	scores := cross_val_score(x, y, folds, predict_first_feature, exact_match_score)!
	assert scores == [1.0, 1.0, 1.0]
}

fn test_cross_val_score_preserves_fold_order_without_aggregation() ! {
	x := [[0.0], [1.0]]
	y := [0.0, 0.0]
	folds := [
		Fold{
			train_indices: [0]
			test_indices:  [1]
		},
		Fold{
			train_indices: [1]
			test_indices:  [0]
		},
	]

	scores := cross_val_score(x, y, folds, predict_first_feature, exact_match_score)!
	assert scores == [0.0, 1.0]
}

fn test_cross_val_score_factory_fits_from_each_training_fold() ! {
	x := [[0.0], [1.0], [2.0], [3.0]]
	y := [0.0, 1.0, 3.0, 7.0]
	folds := [
		Fold{
			train_indices: [2, 3]
			test_indices:  [0, 1]
		},
		Fold{
			train_indices: [0, 1]
			test_indices:  [2, 3]
		},
	]

	scores := cross_val_score_with_factory(x, y, folds, mean_prediction_factory,
		mean_prediction_score)!
	assert scores == [5.0, 0.5]
}

fn test_cross_val_compare_returns_ordered_fold_and_mean_scores() ! {
	x := [[0.0], [1.0], [2.0], [3.0]]
	y := [0.0, 1.0, 3.0, 7.0]
	folds := [
		Fold{
			train_indices: [2, 3]
			test_indices:  [0, 1]
		},
		Fold{
			train_indices: [0, 1]
			test_indices:  [2, 3]
		},
	]
	candidates := [
		CrossValCandidate{
			name:    'mean'
			factory: offset_mean_factory(0.0)
		},
		CrossValCandidate{
			name:    'offset mean'
			factory: offset_mean_factory(1.0)
		},
	]

	results := cross_val_compare(x, y, folds, candidates, 2, mean_prediction_score)!
	assert results.len == 2
	assert results[0].name == 'mean'
	assert results[0].fold_scores == [5.0, 0.5]
	assert results[0].mean_score == 2.75
	assert results[1].name == 'offset mean'
	assert results[1].fold_scores == [6.0, 1.5]
	assert results[1].mean_score == 3.75
}

fn test_cross_val_compare_validates_candidate_limit_and_names() ! {
	x := [[0.0], [1.0]]
	y := [0.0, 1.0]
	folds := [Fold{
		train_indices: [0]
		test_indices:  [1]
	}]
	candidate := CrossValCandidate{
		name:    'candidate'
		factory: offset_mean_factory(0.0)
	}

	if _ := cross_val_compare(x, y, folds, [candidate, candidate], 1, mean_prediction_score) {
		assert false, 'candidate count above the limit must be rejected'
	}
	if _ := cross_val_compare(x, y, folds, [CrossValCandidate{
		name:    ' '
		factory: offset_mean_factory(0.0)
	}], 1, mean_prediction_score) {
		assert false, 'empty candidate names must be rejected'
	}
	if _ := cross_val_compare(x, y, folds, [candidate, candidate], 2, mean_prediction_score) {
		assert false, 'duplicate candidate names must be rejected'
	}
	if _ := cross_val_compare(x, y, folds, [candidate], 0, mean_prediction_score) {
		assert false, 'non-positive candidate limits must be rejected'
	}
}

fn test_cross_val_search_selects_score_direction_and_keeps_first_tie() ! {
	x := [[0.0], [1.0], [2.0], [3.0]]
	y := [0.0, 1.0, 3.0, 7.0]
	folds := [
		Fold{
			train_indices: [2, 3]
			test_indices:  [0, 1]
		},
		Fold{
			train_indices: [0, 1]
			test_indices:  [2, 3]
		},
	]
	candidates := [
		CrossValCandidate{
			name:    'mean'
			factory: offset_mean_factory(0.0)
		},
		CrossValCandidate{
			name:    'offset mean'
			factory: offset_mean_factory(1.0)
		},
	]

	maximized := cross_val_search(x, y, folds, candidates, 2, .maximize,
		mean_prediction_score)!
	assert maximized.best_candidate_index == 1
	assert maximized.candidate_scores[maximized.best_candidate_index].name == 'offset mean'

	minimized := cross_val_search(x, y, folds, candidates, 2, .minimize,
		mean_prediction_score)!
	assert minimized.best_candidate_index == 0

	tie_candidates := [
		CrossValCandidate{
			name:    'first mean'
			factory: offset_mean_factory(0.0)
		},
		CrossValCandidate{
			name:    'second mean'
			factory: offset_mean_factory(0.0)
		},
	]
	tied := cross_val_search(x, y, folds, tie_candidates, 2, .maximize,
		mean_prediction_score)!
	assert tied.best_candidate_index == 0
}

fn test_cross_val_search_rejects_nan_scores() {
	x := [[0.0], [1.0]]
	y := [0.0, 1.0]
	folds := [Fold{
		train_indices: [0]
		test_indices:  [1]
	}]
	candidates := [CrossValCandidate{
		name:    'nan'
		factory: offset_mean_factory(0.0)
	}]
	if _ := cross_val_search(x, y, folds, candidates, 1, .maximize, nan_score) {
		assert false, 'NaN scores do not define a candidate ordering'
	}
}

fn test_cross_val_score_rejects_malformed_data_and_folds() {
	fold := Fold{
		train_indices: [0, 1]
		test_indices:  [1]
	}
	if _ := cross_val_score([[0.0], [1.0]], [0.0, 1.0], [fold], predict_first_feature,
		exact_match_score) {
		assert false, 'overlapping fold indices must be rejected'
	}
	if _ := cross_val_score([[0.0], [1.0]], [0.0, 1.0], [Fold{
		train_indices: [0]
		test_indices:  [2]
	}], predict_first_feature, exact_match_score) {
		assert false, 'out-of-bounds fold indices must be rejected'
	}
	if _ := cross_val_score([[0.0]], [0.0, 1.0], [Fold{
		train_indices: [0]
		test_indices:  [1]
	}], predict_first_feature, exact_match_score) {
		assert false, 'mismatched feature and label counts must be rejected'
	}
	if _ := cross_val_score([[0.0], [1.0]], [0.0, 1.0], [Fold{
		train_indices: [0]
		test_indices:  [1]
	}], predict_no_values, exact_match_score) {
		assert false, 'predictors must return one value per test sample'
	}
	if _ := cross_val_score([[0.0], [1.0]], [0.0, 1.0], [Fold{
		train_indices: [0]
		test_indices:  [1]
	}], predict_first_feature, failing_score) {
		assert false, 'scorer errors must be returned to the caller'
	}
}

fn test_kfold_error_too_few_samples() {
	kf := KFold.new(5, false, 42)

	if _ := kf.split(3) {
		assert false, 'should have returned error'
	}
}

fn test_kfold_error_too_few_splits() {
	kf := KFold.new(1, false, 42)

	if _ := kf.split(10) {
		assert false, 'should have returned error'
	}
}
