module model_selection

import math
import vsl.errors

// Fold represents a single fold in cross-validation
pub struct Fold {
pub mut:
	train_indices []int
	test_indices  []int
}

// KFold generates train/test indices for k-fold cross-validation
@[heap]
pub struct KFold {
pub:
	n_splits    int  = 5
	shuffle     bool = true
	random_seed u32  = 42
}

// KFold.new creates a new KFold cross-validator
pub fn KFold.new(n_splits int, shuffle bool, random_seed u32) &KFold {
	return &KFold{
		n_splits:    n_splits
		shuffle:     shuffle
		random_seed: random_seed
	}
}

// split generates indices to split data into training and test sets
pub fn (kf &KFold) split(n_samples int) ![]Fold {
	if n_samples < kf.n_splits {
		return errors.error('cannot have more splits than samples', .einval)
	}
	if kf.n_splits < 2 {
		return errors.error('n_splits must be at least 2', .einval)
	}

	mut indices := []int{len: n_samples, init: index}

	if kf.shuffle {
		shuffle_array(mut indices, kf.random_seed)
	}

	// Calculate fold sizes
	fold_size := n_samples / kf.n_splits
	remainder := n_samples % kf.n_splits

	mut folds := []Fold{}
	mut start := 0

	for i in 0 .. kf.n_splits {
		// Distribute remainder across first folds
		end := start + fold_size + if i < remainder { 1 } else { 0 }

		test_indices := indices[start..end].clone()
		mut train_indices := []int{}

		// Train indices are everything except test
		for j, idx in indices {
			if j < start || j >= end {
				train_indices << idx
			}
		}

		folds << Fold{
			train_indices: train_indices
			test_indices:  test_indices
		}

		start = end
	}

	return folds
}

// StratifiedKFold generates stratified train/test indices
@[heap]
pub struct StratifiedKFold {
pub:
	n_splits    int  = 5
	shuffle     bool = true
	random_seed u32  = 42
}

// StratifiedKFold.new creates a new StratifiedKFold cross-validator
pub fn StratifiedKFold.new(n_splits int, shuffle bool, random_seed u32) &StratifiedKFold {
	return &StratifiedKFold{
		n_splits:    n_splits
		shuffle:     shuffle
		random_seed: random_seed
	}
}

// split generates stratified indices to split data
pub fn (skf &StratifiedKFold) split(y []f64) ![]Fold {
	n_samples := y.len

	if n_samples < skf.n_splits {
		return errors.error('cannot have more splits than samples', .einval)
	}
	if skf.n_splits < 2 {
		return errors.error('n_splits must be at least 2', .einval)
	}

	// Group indices by class
	mut class_indices := map[int][]int{}
	for i, val in y {
		class_key := int(val)
		if class_key !in class_indices {
			class_indices[class_key] = []int{}
		}
		class_indices[class_key] << i
	}

	// Shuffle within each class if requested
	if skf.shuffle {
		for _, mut indices in class_indices {
			shuffle_array(mut indices, skf.random_seed)
		}
	}

	// Initialize folds
	mut folds := []Fold{len: skf.n_splits, init: Fold{
		train_indices: []int{}
		test_indices:  []int{}
	}}

	// Distribute each class across folds
	for _, class_idx in class_indices {
		n_class := class_idx.len
		fold_size := n_class / skf.n_splits
		remainder := n_class % skf.n_splits

		mut start := 0
		for i in 0 .. skf.n_splits {
			end := start + fold_size + if i < remainder { 1 } else { 0 }

			// Add to test indices for this fold
			for j in start .. end {
				folds[i].test_indices << class_idx[j]
			}

			start = end
		}
	}

	// Build train indices (everything not in test)
	for i in 0 .. skf.n_splits {
		test_set := array_to_set(folds[i].test_indices)
		for j in 0 .. n_samples {
			if j !in test_set {
				folds[i].train_indices << j
			}
		}
	}

	return folds
}

// LeaveOneOut implements leave-one-out cross-validation
@[heap]
pub struct LeaveOneOut {
}

// LeaveOneOut.new creates a new LeaveOneOut cross-validator
pub fn LeaveOneOut.new() &LeaveOneOut {
	return &LeaveOneOut{}
}

// split generates indices for leave-one-out CV
pub fn (loo &LeaveOneOut) split(n_samples int) []Fold {
	mut folds := []Fold{}

	for i in 0 .. n_samples {
		mut train_indices := []int{}
		for j in 0 .. n_samples {
			if j != i {
				train_indices << j
			}
		}

		folds << Fold{
			train_indices: train_indices
			test_indices:  [i]
		}
	}

	return folds
}

// ShuffleSplit generates random permutation cross-validator
@[heap]
pub struct ShuffleSplit {
pub:
	n_splits    int = 5
	test_size   f64 = 0.2
	random_seed u32 = 42
}

// ShuffleSplit.new creates a new ShuffleSplit cross-validator
pub fn ShuffleSplit.new(n_splits int, test_size f64, random_seed u32) &ShuffleSplit {
	return &ShuffleSplit{
		n_splits:    n_splits
		test_size:   test_size
		random_seed: random_seed
	}
}

// split generates random train/test indices
pub fn (ss &ShuffleSplit) split(n_samples int) ![]Fold {
	if ss.test_size <= 0.0 || ss.test_size >= 1.0 {
		return errors.error('test_size must be between 0 and 1', .einval)
	}

	n_test := int(math.round(f64(n_samples) * ss.test_size))
	n_train := n_samples - n_test

	if n_train == 0 || n_test == 0 {
		return errors.error('split would result in empty train or test set', .einval)
	}

	mut folds := []Fold{}

	for split_idx in 0 .. ss.n_splits {
		mut indices := []int{len: n_samples, init: index}
		shuffle_array(mut indices, ss.random_seed + u32(split_idx))

		folds << Fold{
			train_indices: indices[..n_train].clone()
			test_indices:  indices[n_train..].clone()
		}
	}

	return folds
}

// Helper functions

fn shuffle_array(mut arr []int, seed u32) {
	// Use a simple linear congruential generator for deterministic shuffle
	mut rng_state := u64(seed)
	for i := arr.len - 1; i > 0; i-- {
		// LCG: state = state * a + c
		rng_state = rng_state * 6364136223846793005 + 1442695040888963407
		j := int(rng_state % u64(i + 1))
		arr[i], arr[j] = arr[j], arr[i]
	}
}

fn array_to_set(arr []int) map[int]bool {
	mut result := map[int]bool{}
	for val in arr {
		result[val] = true
	}
	return result
}

// get_fold_data extracts the actual data for a fold
pub fn get_fold_data(x [][]f64, y []f64, fold Fold) ([][]f64, []f64, [][]f64, []f64) {
	mut x_train := [][]f64{len: fold.train_indices.len}
	mut y_train := []f64{len: fold.train_indices.len}
	mut x_test := [][]f64{len: fold.test_indices.len}
	mut y_test := []f64{len: fold.test_indices.len}

	for i, idx in fold.train_indices {
		x_train[i] = x[idx].clone()
		y_train[i] = y[idx]
	}

	for i, idx in fold.test_indices {
		x_test[i] = x[idx].clone()
		y_test[i] = y[idx]
	}

	return x_train, y_train, x_test, y_test
}
