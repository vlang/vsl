module model_selection

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
