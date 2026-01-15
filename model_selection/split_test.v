module model_selection

import math

fn test_train_test_split_basic() {
	x := [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0], [7.0, 8.0], [9.0, 10.0]]
	y := [0.0, 1.0, 0.0, 1.0, 0.0]

	result := train_test_split(x, y, TrainTestSplitConfig{
		test_size: 0.2
		shuffle:   false
	})!

	assert result.x_train.len == 4
	assert result.x_test.len == 1
	assert result.y_train.len == 4
	assert result.y_test.len == 1
}

fn test_train_test_split_shuffle() {
	x := [[1.0], [2.0], [3.0], [4.0], [5.0], [6.0], [7.0], [8.0],
		[9.0], [10.0]]
	y := [0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0]

	result := train_test_split(x, y, TrainTestSplitConfig{
		test_size:   0.3
		shuffle:     true
		random_seed: 42
	})!

	assert result.x_train.len == 7
	assert result.x_test.len == 3
}

fn test_train_test_split_stratified() {
	x := [[1.0], [2.0], [3.0], [4.0], [5.0], [6.0], [7.0], [8.0],
		[9.0], [10.0]]
	y := [0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0]

	result := train_test_split(x, y, TrainTestSplitConfig{
		test_size:   0.4
		stratify:    true
		random_seed: 42
	})!

	// Count classes in train and test
	mut train_class_1 := 0
	for val in result.y_train {
		if val == 1.0 {
			train_class_1++
		}
	}

	mut test_class_1 := 0
	for val in result.y_test {
		if val == 1.0 {
			test_class_1++
		}
	}

	// Should maintain roughly 50% of each class
	train_ratio := f64(train_class_1) / f64(result.y_train.len)
	test_ratio := f64(test_class_1) / f64(result.y_test.len)

	assert math.abs(train_ratio - 0.5) < 0.2
	assert math.abs(test_ratio - 0.5) < 0.3
}

fn test_train_val_test_split() {
	x := [][]f64{len: 100, init: [f64(index)]}
	y := []f64{len: 100, init: f64(index % 2)}

	result := train_val_test_split(x, y, TrainValTestConfig{
		val_size:  0.1
		test_size: 0.2
	})!

	// 70% train, 10% val, 20% test
	assert result.x_train.len == 70
	assert result.x_val.len == 10
	assert result.x_test.len == 20
}

fn test_split_preserves_data() {
	x := [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0], [7.0, 8.0]]
	y := [1.0, 2.0, 3.0, 4.0]

	result := train_test_split(x, y, TrainTestSplitConfig{
		test_size: 0.25
		shuffle:   false
	})!

	// All original values should be in either train or test
	mut all_y := result.y_train.clone()
	for val in result.y_test {
		all_y << val
	}
	all_y.sort(a < b)

	assert all_y == [1.0, 2.0, 3.0, 4.0]
}

fn test_split_error_invalid_test_size() {
	x := [[1.0], [2.0]]
	y := [0.0, 1.0]

	if _ := train_test_split(x, y, TrainTestSplitConfig{ test_size: 1.5 }) {
		assert false, 'should have returned error'
	}

	if _ := train_test_split(x, y, TrainTestSplitConfig{ test_size: 0.0 }) {
		assert false, 'should have returned error'
	}
}

fn test_split_error_length_mismatch() {
	x := [[1.0], [2.0], [3.0]]
	y := [0.0, 1.0]

	if _ := train_test_split(x, y, TrainTestSplitConfig{}) {
		assert false, 'should have returned error'
	}
}

fn test_split_reproducibility() {
	x := [[1.0], [2.0], [3.0], [4.0], [5.0], [6.0], [7.0], [8.0],
		[9.0], [10.0]]
	y := [0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0]

	result1 := train_test_split(x, y, TrainTestSplitConfig{
		test_size:   0.3
		shuffle:     true
		random_seed: 123
	})!

	result2 := train_test_split(x, y, TrainTestSplitConfig{
		test_size:   0.3
		shuffle:     true
		random_seed: 123
	})!

	assert result1.y_train == result2.y_train
	assert result1.y_test == result2.y_test
}
