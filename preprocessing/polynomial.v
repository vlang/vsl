module preprocessing

import vsl.errors

// PolynomialFeatures generates all polynomial combinations up to degree.
// Interaction-only mode uses each input feature at most once per term.
@[params]
pub struct PolynomialFeatures {
pub:
	degree           int = 2
	interaction_only bool
	include_bias     bool = true
}

// transform expands each row into polynomial features. Output columns are
// ordered by degree, then lexicographically by input feature index.
pub fn (p PolynomialFeatures) transform(data [][]f64) ![][]f64 {
	if p.degree < 0 {
		return errors.error('degree must be non-negative', .einval)
	}
	if data.len == 0 {
		return errors.error('cannot transform an empty dataset', .einval)
	}
	n_features := data[0].len
	for row in data {
		if row.len != n_features {
			return errors.error('all rows must have the same number of features', .einval)
		}
	}
	mut terms := [][]int{}
	if p.include_bias {
		terms << []int{}
	}
	for current_degree in 1 .. p.degree + 1 {
		mut prefix := []int{cap: current_degree}
		polynomial_terms(n_features, current_degree, p.interaction_only, 0, mut prefix, mut terms)
	}
	mut result := [][]f64{cap: data.len}
	for row in data {
		mut expanded := []f64{cap: terms.len}
		for term in terms {
			mut value := 1.0
			for feature in term {
				value *= row[feature]
			}
			expanded << value
		}
		result << expanded
	}
	return result
}

fn polynomial_terms(n_features int, degree int, interaction_only bool, start int, mut prefix []int, mut terms [][]int) {
	if prefix.len == degree {
		terms << prefix.clone()
		return
	}
	for feature in start .. n_features {
		prefix << feature
		next_start := if interaction_only { feature + 1 } else { feature }
		polynomial_terms(n_features, degree, interaction_only, next_start, mut prefix, mut terms)
		prefix.pop()
	}
}
