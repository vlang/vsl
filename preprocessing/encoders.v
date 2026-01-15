module preprocessing

import vsl.errors

// LabelEncoder encodes categorical labels with values between 0 and n_classes-1.
@[heap]
pub struct LabelEncoder {
mut:
	fitted bool
pub mut:
	classes_     []string       // unique classes in order
	class_to_idx map[string]int // mapping from class to index
}

// LabelEncoder.new creates a new LabelEncoder
pub fn LabelEncoder.new() &LabelEncoder {
	return &LabelEncoder{}
}

// fit learns the unique classes from the data
pub fn (mut e LabelEncoder) fit(y []string) ! {
	if y.len == 0 {
		return errors.error('cannot fit on empty data', .einval)
	}

	e.classes_ = []string{}
	e.class_to_idx = map[string]int{}

	for label in y {
		if label !in e.class_to_idx {
			e.class_to_idx[label] = e.classes_.len
			e.classes_ << label
		}
	}

	e.fitted = true
}

// transform encodes labels to integers
pub fn (e &LabelEncoder) transform(y []string) ![]int {
	if !e.fitted {
		return errors.error('LabelEncoder must be fitted before transform', .efailed)
	}

	mut result := []int{len: y.len}
	for i, label in y {
		if label !in e.class_to_idx {
			return errors.error('unknown label: ${label}', .einval)
		}
		result[i] = e.class_to_idx[label]
	}
	return result
}

// fit_transform fits and transforms in one step
pub fn (mut e LabelEncoder) fit_transform(y []string) ![]int {
	e.fit(y)!
	return e.transform(y)
}

// inverse_transform converts integer labels back to original labels
pub fn (e &LabelEncoder) inverse_transform(y []int) ![]string {
	if !e.fitted {
		return errors.error('LabelEncoder must be fitted before inverse_transform', .efailed)
	}

	mut result := []string{len: y.len}
	for i, idx in y {
		if idx < 0 || idx >= e.classes_.len {
			return errors.error('invalid label index: ${idx}', .einval)
		}
		result[i] = e.classes_[idx]
	}
	return result
}

// OneHotEncoder encodes categorical features as a one-hot (or dummy) numeric array.
@[heap]
pub struct OneHotEncoder {
mut:
	fitted bool
pub mut:
	categories_ [][]string // categories for each feature
	n_features  int
	drop_first  bool // whether to drop the first category (for dummy encoding)
}

// OneHotEncoder.new creates a new OneHotEncoder
pub fn OneHotEncoder.new(drop_first bool) &OneHotEncoder {
	return &OneHotEncoder{
		drop_first: drop_first
	}
}

// fit learns the categories for each feature
pub fn (mut e OneHotEncoder) fit(x [][]string) ! {
	if x.len == 0 {
		return errors.error('cannot fit on empty data', .einval)
	}

	e.n_features = x[0].len
	e.categories_ = [][]string{len: e.n_features}

	for j in 0 .. e.n_features {
		mut unique := map[string]bool{}
		mut cats := []string{}
		for i in 0 .. x.len {
			if x[i][j] !in unique {
				unique[x[i][j]] = true
				cats << x[i][j]
			}
		}
		e.categories_[j] = cats
	}

	e.fitted = true
}

// transform applies one-hot encoding to the data
pub fn (e &OneHotEncoder) transform(x [][]string) ![][]f64 {
	if !e.fitted {
		return errors.error('OneHotEncoder must be fitted before transform', .efailed)
	}

	// Calculate total output columns
	mut n_output_cols := 0
	for j in 0 .. e.n_features {
		n_cats := e.categories_[j].len
		if e.drop_first {
			n_output_cols += n_cats - 1
		} else {
			n_output_cols += n_cats
		}
	}

	mut result := [][]f64{len: x.len}
	for i in 0 .. x.len {
		mut row := []f64{len: n_output_cols}
		mut col_idx := 0
		for j in 0 .. e.n_features {
			cats := e.categories_[j]
			start_idx := if e.drop_first { 1 } else { 0 }
			for k := start_idx; k < cats.len; k++ {
				if x[i][j] == cats[k] {
					row[col_idx] = 1.0
				}
				col_idx++
			}
		}
		result[i] = row
	}
	return result
}

// fit_transform fits and transforms in one step
pub fn (mut e OneHotEncoder) fit_transform(x [][]string) ![][]f64 {
	e.fit(x)!
	return e.transform(x)
}

// get_feature_names returns the names of the output features
pub fn (e &OneHotEncoder) get_feature_names(input_names []string) ![]string {
	if !e.fitted {
		return errors.error('OneHotEncoder must be fitted before get_feature_names', .efailed)
	}

	mut names := []string{}
	for j in 0 .. e.n_features {
		prefix := if j < input_names.len { input_names[j] } else { 'x${j}' }
		cats := e.categories_[j]
		start_idx := if e.drop_first { 1 } else { 0 }
		for k := start_idx; k < cats.len; k++ {
			names << '${prefix}_${cats[k]}'
		}
	}
	return names
}

// OrdinalEncoder encodes categorical features as ordinal integers.
@[heap]
pub struct OrdinalEncoder {
mut:
	fitted bool
pub mut:
	categories_ [][]string // categories for each feature
	n_features  int
}

// OrdinalEncoder.new creates a new OrdinalEncoder
pub fn OrdinalEncoder.new() &OrdinalEncoder {
	return &OrdinalEncoder{}
}

// fit learns the categories for each feature
pub fn (mut e OrdinalEncoder) fit(x [][]string) ! {
	if x.len == 0 {
		return errors.error('cannot fit on empty data', .einval)
	}

	e.n_features = x[0].len
	e.categories_ = [][]string{len: e.n_features}

	for j in 0 .. e.n_features {
		mut unique := map[string]bool{}
		mut cats := []string{}
		for i in 0 .. x.len {
			if x[i][j] !in unique {
				unique[x[i][j]] = true
				cats << x[i][j]
			}
		}
		e.categories_[j] = cats
	}

	e.fitted = true
}

// transform applies ordinal encoding to the data
pub fn (e &OrdinalEncoder) transform(x [][]string) ![][]f64 {
	if !e.fitted {
		return errors.error('OrdinalEncoder must be fitted before transform', .efailed)
	}

	mut result := [][]f64{len: x.len}
	for i in 0 .. x.len {
		mut row := []f64{len: e.n_features}
		for j in 0 .. e.n_features {
			// Find the index of the category
			mut found := false
			for k, cat in e.categories_[j] {
				if x[i][j] == cat {
					row[j] = f64(k)
					found = true
					break
				}
			}
			if !found {
				return errors.error('unknown category: ${x[i][j]}', .einval)
			}
		}
		result[i] = row
	}
	return result
}

// fit_transform fits and transforms in one step
pub fn (mut e OrdinalEncoder) fit_transform(x [][]string) ![][]f64 {
	e.fit(x)!
	return e.transform(x)
}
