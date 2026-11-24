module model_selection

import math
import vsl.errors

// PermutationImportanceConfig controls repeated feature permutation.
pub struct PermutationImportanceConfig {
pub:
	n_repeats   int = 5
	random_seed u32 = 42
	// Each group is permuted together. An empty list means one group per feature.
	feature_groups [][]int
}

// PermutationImportanceResult contains score decreases caused by permutation.
// Positive values indicate that the estimator relied on the corresponding
// feature group for the supplied data and scorer.
pub struct PermutationImportanceResult {
pub:
	importances_mean []f64
	importances_std  []f64
	baseline_score   f64
	n_repeats        int
	random_seed      u32
	feature_groups   [][]int
}

// permutation_importance estimates predictive reliance on held-out data.
// The predictor and scorer are supplied by the caller so this utility works
// with any fitted estimator and with either classification or regression.
pub fn permutation_importance(x [][]f64, y []f64, predictor FoldPrediction, scorer FoldScorer,
	config PermutationImportanceConfig) !PermutationImportanceResult {
	validate_permutation_inputs(x, y, config)!
	groups := normalized_feature_groups(x[0].len, config.feature_groups)!
	y_pred := predictor(x)!
	baseline := score_permutation(y, y_pred, scorer)!

	mut drops := [][]f64{len: groups.len, init: []f64{len: config.n_repeats}}
	for repeat in 0 .. config.n_repeats {
		for group_index, group in groups {
			mut permuted := clone_rows(x)
			indices := shuffled_indices(x.len, config.random_seed + u32(repeat * groups.len + group_index))
			for feature in group {
				for row_index, source_index in indices {
					mut row := permuted[row_index].clone()
					row[feature] = x[source_index][feature]
					permuted[row_index] = row
				}
			}
			permuted_pred := predictor(permuted)!
			permuted_score := score_permutation(y, permuted_pred, scorer)!
			drops[group_index][repeat] = baseline - permuted_score
		}
	}

	mut means := []f64{len: groups.len}
	mut stds := []f64{len: groups.len}
	for group_index, values in drops {
		mut sum := 0.0
		for value in values {
			sum += value
		}
		mean := sum / f64(values.len)
		mut variance := 0.0
		for value in values {
			delta := value - mean
			variance += delta * delta
		}
		means[group_index] = mean
		stds[group_index] = math.sqrt(variance / f64(values.len))
	}

	return PermutationImportanceResult{
		importances_mean: means
		importances_std: stds
		baseline_score: baseline
		n_repeats: config.n_repeats
		random_seed: config.random_seed
		feature_groups: groups
	}
}

fn validate_permutation_inputs(x [][]f64, y []f64, config PermutationImportanceConfig) ! {
	if x.len == 0 {
		return errors.error('permutation importance requires at least one sample', .einval)
	}
	if x.len != y.len {
		return errors.error('features and labels must have the same number of samples', .einval)
	}
	if x[0].len == 0 {
		return errors.error('permutation importance requires at least one feature', .einval)
	}
	for row in x {
		if row.len != x[0].len {
			return errors.error('feature rows must have a consistent width', .einval)
		}
	}
	if config.n_repeats < 1 {
		return errors.error('n_repeats must be at least 1', .einval)
	}
}

fn normalized_feature_groups(feature_count int, requested [][]int) ![][]int {
	if requested.len == 0 {
		mut groups := [][]int{cap: feature_count}
		for feature in 0 .. feature_count {
			groups << [feature]
		}
		return groups
	}
	mut seen := map[int]bool{}
	mut groups := [][]int{cap: requested.len}
	for group_index, group in requested {
		if group.len == 0 {
			return errors.error('feature group ${group_index} must not be empty', .einval)
		}
		mut normalized := []int{cap: group.len}
		for feature in group {
			if feature < 0 || feature >= feature_count {
				return errors.error('feature index ${feature} is out of bounds', .einval)
			}
			if feature in seen {
				return errors.error('feature index ${feature} occurs in multiple groups', .einval)
			}
			seen[feature] = true
			normalized << feature
		}
		groups << normalized
	}
	return groups
}

fn clone_rows(x [][]f64) [][]f64 {
	mut clone := [][]f64{cap: x.len}
	for row in x {
		clone << row.clone()
	}
	return clone
}

fn shuffled_indices(n int, seed u32) []int {
	mut indices := []int{len: n, init: index}
	mut state := u64(seed)
	for i := n - 1; i > 0; i-- {
		state = state * 6364136223846793005 + 1442695040888963407
		j := int(state % u64(i + 1))
		indices[i], indices[j] = indices[j], indices[i]
	}
	return indices
}

fn score_permutation(y_true []f64, y_pred []f64, scorer FoldScorer) !f64 {
	if y_pred.len != y_true.len {
		return errors.error('predictor returned ${y_pred.len} predictions, expected ${y_true.len}', .einval)
	}
	return scorer(y_true, y_pred)
}
