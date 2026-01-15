module model_selection

import math
import vsl.errors

// TrainTestResult holds the result of a train-test split
pub struct TrainTestResult {
pub:
	x_train [][]f64
	x_test  [][]f64
	y_train []f64
	y_test  []f64
}

// train_test_split splits arrays into random train and test subsets
pub fn train_test_split(x [][]f64, y []f64, config TrainTestSplitConfig) !TrainTestResult {
	if x.len != y.len {
		return errors.error('x and y must have the same length', .einval)
	}
	if x.len == 0 {
		return errors.error('cannot split empty data', .einval)
	}
	if config.test_size <= 0.0 || config.test_size >= 1.0 {
		return errors.error('test_size must be between 0 and 1', .einval)
	}

	n := x.len
	n_test := int(math.round(f64(n) * config.test_size))
	n_train := n - n_test

	if n_train == 0 || n_test == 0 {
		return errors.error('split would result in empty train or test set', .einval)
	}

	// Create indices
	mut indices := []int{len: n, init: index}

	// Shuffle if not stratified
	if config.stratify {
		indices = stratified_indices(y, config.test_size, config.random_seed)!
	} else if config.shuffle {
		shuffle_indices(mut indices, config.random_seed)
	}

	// Split
	train_indices := indices[..n_train].clone()
	test_indices := indices[n_train..].clone()

	mut x_train := [][]f64{len: n_train}
	mut y_train := []f64{len: n_train}
	mut x_test := [][]f64{len: n_test}
	mut y_test := []f64{len: n_test}

	for i, idx in train_indices {
		x_train[i] = x[idx].clone()
		y_train[i] = y[idx]
	}

	for i, idx in test_indices {
		x_test[i] = x[idx].clone()
		y_test[i] = y[idx]
	}

	return TrainTestResult{
		x_train: x_train
		x_test:  x_test
		y_train: y_train
		y_test:  y_test
	}
}

// TrainTestSplitConfig holds configuration for train-test split
pub struct TrainTestSplitConfig {
pub:
	test_size   f64  = 0.25 // proportion of data for test set
	shuffle     bool = true // whether to shuffle before splitting
	stratify    bool // whether to preserve class proportions
	random_seed u32 = 42 // random seed for reproducibility
}

// stratified_indices returns indices that preserve class proportions
fn stratified_indices(y []f64, test_ratio f64, seed u32) ![]int {
	// Group indices by class
	mut class_indices := map[int][]int{}

	for i, val in y {
		class_key := int(val)
		if class_key !in class_indices {
			class_indices[class_key] = []int{}
		}
		class_indices[class_key] << i
	}

	mut train_indices := []int{}
	mut test_indices := []int{}

	// For each class, split proportionally
	for _, indices in class_indices {
		mut class_idx := indices.clone()
		shuffle_indices(mut class_idx, seed)

		n_test := int(math.round(f64(class_idx.len) * test_ratio))
		n_train := class_idx.len - n_test

		for i in 0 .. n_train {
			train_indices << class_idx[i]
		}
		for i in n_train .. class_idx.len {
			test_indices << class_idx[i]
		}
	}

	// Shuffle train and test separately
	shuffle_indices(mut train_indices, seed)
	shuffle_indices(mut test_indices, seed + 1)

	// Combine: train first, then test
	mut result := []int{}
	for idx in train_indices {
		result << idx
	}
	for idx in test_indices {
		result << idx
	}

	return result
}

// shuffle_indices shuffles an array of indices in place
fn shuffle_indices(mut indices []int, seed u32) {
	// Use a simple linear congruential generator for deterministic shuffle
	mut rng_state := u64(seed)
	for i := indices.len - 1; i > 0; i-- {
		// LCG: state = state * a + c
		rng_state = rng_state * 6364136223846793005 + 1442695040888963407
		j := int(rng_state % u64(i + 1))
		indices[i], indices[j] = indices[j], indices[i]
	}
}

// train_val_test_split splits data into train, validation, and test sets
pub fn train_val_test_split(x [][]f64, y []f64, config TrainValTestConfig) !TrainValTestResult {
	if x.len != y.len {
		return errors.error('x and y must have the same length', .einval)
	}
	if config.val_size + config.test_size >= 1.0 {
		return errors.error('val_size + test_size must be less than 1.0', .einval)
	}

	// First split: separate test
	first_split := train_test_split(x, y, TrainTestSplitConfig{
		test_size:   config.test_size
		shuffle:     config.shuffle
		stratify:    config.stratify
		random_seed: config.random_seed
	})!

	// Second split: separate validation from train
	val_ratio := config.val_size / (1.0 - config.test_size)
	second_split := train_test_split(first_split.x_train, first_split.y_train, TrainTestSplitConfig{
		test_size:   val_ratio
		shuffle:     config.shuffle
		stratify:    config.stratify
		random_seed: config.random_seed + 1
	})!

	return TrainValTestResult{
		x_train: second_split.x_train
		x_val:   second_split.x_test
		x_test:  first_split.x_test
		y_train: second_split.y_train
		y_val:   second_split.y_test
		y_test:  first_split.y_test
	}
}

// TrainValTestConfig holds configuration for train-val-test split
pub struct TrainValTestConfig {
pub:
	val_size    f64  = 0.1 // proportion for validation
	test_size   f64  = 0.2 // proportion for test
	shuffle     bool = true
	stratify    bool
	random_seed u32 = 42
}

// TrainValTestResult holds the result of a train-val-test split
pub struct TrainValTestResult {
pub:
	x_train [][]f64
	x_val   [][]f64
	x_test  [][]f64
	y_train []f64
	y_val   []f64
	y_test  []f64
}
