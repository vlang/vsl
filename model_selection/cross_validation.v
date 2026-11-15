module model_selection

import math
import vsl.errors

// Fold represents a single fold in cross-validation
pub struct Fold {
pub mut:
	train_indices []int
	test_indices  []int
}

// FoldPredictor fits a fresh estimator from one fold's training data and
// returns predictions for that fold's test features.
pub type FoldPredictor = fn (x_train [][]f64, y_train []f64, x_test [][]f64) ![]f64

// FoldScorer computes one score from test labels and corresponding predictions.
pub type FoldScorer = fn (y_true []f64, y_pred []f64) !f64

// FoldPrediction predicts test labels using a model fitted for one fold.
pub type FoldPrediction = fn (x_test [][]f64) ![]f64

// FoldEstimatorFactory fits and returns a predictor using only one fold's
// training data. It is called once per fold and must not reuse fitted state.
pub type FoldEstimatorFactory = fn (x_train [][]f64, y_train []f64) !FoldPrediction

// CrossValCandidate names one estimator configuration for bounded comparison.
// Capture its hyperparameters in factory; the factory must fit fresh state.
pub struct CrossValCandidate {
pub:
	name    string
	factory FoldEstimatorFactory @[required]
}

// CrossValCandidateScore contains fold-ordered scores and their unweighted
// arithmetic mean for one candidate.
pub struct CrossValCandidateScore {
pub:
	name        string
	fold_scores []f64
	mean_score  f64
}

// CrossValScoreDirection specifies how a scorer's mean should be optimized.
pub enum CrossValScoreDirection {
	maximize
	minimize
}

// CrossValSearchResult contains all evaluations and the selected candidate's
// index in candidate_scores.
pub struct CrossValSearchResult {
pub:
	candidate_scores     []CrossValCandidateScore
	best_candidate_index int
}

// KFold generates train/test indices for k-fold cross-validation

// KFold defines a public data structure for this module.

// KFold defines a public data structure for this module.
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

// StratifiedKFold defines a public data structure for this module.

// StratifiedKFold defines a public data structure for this module.
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

	groups := stratified_class_groups(y)!

	// Initialize folds
	mut folds := []Fold{len: skf.n_splits, init: Fold{
		train_indices: []int{}
		test_indices:  []int{}
	}}

	// Distribute each class across folds
	mut fold_offset := 0
	for key in groups.keys {
		mut class_idx := groups.indices[key].clone()
		if skf.shuffle {
			shuffle_array(mut class_idx, skf.random_seed)
		}
		n_class := class_idx.len
		fold_size := n_class / skf.n_splits
		remainder := n_class % skf.n_splits

		mut start := 0
		for i in 0 .. skf.n_splits {
			fold_order := (i + skf.n_splits - fold_offset) % skf.n_splits
			end := start + fold_size + if fold_order < remainder { 1 } else { 0 }

			// Add to test indices for this fold
			for j in start .. end {
				folds[i].test_indices << class_idx[j]
			}

			start = end
		}
		fold_offset = (fold_offset + remainder) % skf.n_splits
	}

	// Build train indices (everything not in test)
	for i in 0 .. skf.n_splits {
		if !skf.shuffle {
			folds[i].test_indices.sort()
		}
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

// LeaveOneOut defines a public data structure for this module.

// LeaveOneOut defines a public data structure for this module.
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

// ShuffleSplit defines a public data structure for this module.

// ShuffleSplit defines a public data structure for this module.
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

// cross_val_score evaluates a predictor independently on each supplied fold.
// The predictor receives training labels but only test features, avoiding
// target leakage; create an unfitted estimator inside each invocation.
// Scores are returned in fold order without aggregation or direction changes;
// label and higher-is-better conventions belong to the supplied scorer.
pub fn cross_val_score(x [][]f64, y []f64, folds []Fold, predictor FoldPredictor, scorer FoldScorer) ![]f64 {
	validate_cross_val_inputs(x, y, folds)!

	mut scores := []f64{cap: folds.len}
	for fold_index, fold in folds {
		x_train, y_train, x_test, y_test := get_fold_data(x, y, fold)
		y_pred := predictor(x_train, y_train, x_test)!
		scores << score_fold(y_test, y_pred, fold_index, scorer)!
	}
	return scores
}

// cross_val_score_with_factory calls a model factory once for every fold with
// only that fold's training data, then scores predictions on held-out features.
// The factory must return a predictor backed by new, independently fitted state.
pub fn cross_val_score_with_factory(x [][]f64, y []f64, folds []Fold, factory FoldEstimatorFactory, scorer FoldScorer) ![]f64 {
	validate_cross_val_inputs(x, y, folds)!
	return cross_val_score_with_factory_validated(x, y, folds, factory, scorer)
}

fn cross_val_score_with_factory_validated(x [][]f64, y []f64, folds []Fold, factory FoldEstimatorFactory, scorer FoldScorer) ![]f64 {
	mut scores := []f64{cap: folds.len}
	for fold_index, fold in folds {
		x_train, y_train, x_test, y_test := get_fold_data(x, y, fold)
		predict := factory(x_train, y_train)!
		y_pred := predict(x_test)!
		scores << score_fold(y_test, y_pred, fold_index, scorer)!
	}
	return scores
}

// cross_val_compare evaluates each named factory sequentially on the same
// validated folds. max_candidates bounds the number of candidate fits; scores
// remain in candidate/fold order and are not ranked or direction-transformed.
// mean_score is the unweighted arithmetic mean of that candidate's fold scores.
pub fn cross_val_compare(x [][]f64, y []f64, folds []Fold, candidates []CrossValCandidate, max_candidates int, scorer FoldScorer) ![]CrossValCandidateScore {
	validate_cross_val_inputs(x, y, folds)!
	if max_candidates < 1 {
		return errors.error('max_candidates must be positive', .einval)
	}
	if candidates.len == 0 {
		return errors.error('cross-validation comparison requires at least one candidate', .einval)
	}
	if candidates.len > max_candidates {
		return errors.error('candidate count ${candidates.len} exceeds max_candidates ${max_candidates}',
			.einval)
	}
	mut candidate_names := map[string]bool{}
	for candidate in candidates {
		if candidate.name.trim_space() == '' {
			return errors.error('candidate names must not be empty', .einval)
		}
		if candidate.name in candidate_names {
			return errors.error('duplicate cross-validation candidate name: ${candidate.name}', .einval)
		}
		candidate_names[candidate.name] = true
	}

	mut results := []CrossValCandidateScore{cap: candidates.len}
	for candidate in candidates {
		scores := cross_val_score_with_factory_validated(x, y, folds, candidate.factory,
			scorer)!
		mut mean_score := 0.0
		for score in scores {
			mean_score += score
		}
		mean_score /= f64(scores.len)
		results << CrossValCandidateScore{
			name:        candidate.name
			fold_scores: scores
			mean_score:  mean_score
		}
	}
	return results
}

// cross_val_search evaluates a bounded caller-supplied candidate list and
// selects the highest or lowest unweighted mean score. Ties keep the earliest
// candidate. Scorers that return NaN cannot define a reliable ordering.
pub fn cross_val_search(x [][]f64, y []f64, folds []Fold, candidates []CrossValCandidate, max_candidates int, direction CrossValScoreDirection, scorer FoldScorer) !CrossValSearchResult {
	scores := cross_val_compare(x, y, folds, candidates, max_candidates, scorer)!
	mut best_candidate_index := 0
	for index, score in scores {
		if math.is_nan(score.mean_score) {
			return errors.error('candidate ${score.name} has a NaN mean score', .einval)
		}
		if index == 0 {
			continue
		}
		is_better := match direction {
			.maximize { score.mean_score > scores[best_candidate_index].mean_score }
			.minimize { score.mean_score < scores[best_candidate_index].mean_score }
		}
		if is_better {
			best_candidate_index = index
		}
	}
	return CrossValSearchResult{
		candidate_scores:     scores
		best_candidate_index: best_candidate_index
	}
}

fn validate_cross_val_inputs(x [][]f64, y []f64, folds []Fold) ! {
	if x.len != y.len {
		return errors.error('features and labels must have the same number of samples', .einval)
	}
	if x.len == 0 {
		return errors.error('cross-validation requires at least one sample', .einval)
	}
	if folds.len == 0 {
		return errors.error('cross-validation requires at least one fold', .einval)
	}
	feature_count := x[0].len
	for row in x {
		if row.len != feature_count {
			return errors.error('feature rows must have a consistent width', .einval)
		}
	}
	for fold_index, fold in folds {
		validate_fold_indices(fold, x.len, fold_index)!
	}
}

fn score_fold(y_true []f64, y_pred []f64, fold_index int, scorer FoldScorer) !f64 {
	if y_pred.len != y_true.len {
		return errors.error('predictor returned ${y_pred.len} predictions for fold ${fold_index}, expected ${y_true.len}',
			.einval)
	}
	return scorer(y_true, y_pred)
}

fn validate_fold_indices(fold Fold, n_samples int, fold_index int) ! {
	if fold.train_indices.len == 0 || fold.test_indices.len == 0 {
		return errors.error('fold ${fold_index} must have non-empty train and test indices', .einval)
	}
	mut seen := map[int]bool{}
	for index in fold.train_indices {
		if index < 0 || index >= n_samples {
			return errors.error('training index ${index} is out of bounds in fold ${fold_index}', .einval)
		}
		if index in seen {
			return errors.error('duplicate sample index ${index} in fold ${fold_index}', .einval)
		}
		seen[index] = true
	}
	for index in fold.test_indices {
		if index < 0 || index >= n_samples {
			return errors.error('test index ${index} is out of bounds in fold ${fold_index}', .einval)
		}
		if index in seen {
			return errors.error('sample index ${index} occurs more than once in fold ${fold_index}',
				.einval)
		}
		seen[index] = true
	}
}
