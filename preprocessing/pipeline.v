module preprocessing

import vsl.errors

// MatrixTransformer is a fitted transform for numeric feature matrices.
pub interface MatrixTransformer {
	// transform applies the learned transformation without mutating its state.
	transform(data [][]f64) ![][]f64

	// get_feature_names_out returns names for the transformed columns.
	get_feature_names_out(input_features []string) ![]string
	// fit learns transform state from the supplied training matrix.
mut:
	fit(data [][]f64) !
}

// PipelineStep names one transformer in a numeric preprocessing pipeline.
pub struct PipelineStep {
pub:
	name        string
	transformer MatrixTransformer
}

// Pipeline fits and applies numeric transformers in sequence.
@[heap]
pub struct Pipeline {
mut:
	steps                  []PipelineStep
	n_features_out_by_step []int
	fitted                 bool
pub mut:
	n_features_in_     int
	n_features_out_    int
	feature_names_in_  []string
	feature_names_out_ []string
}

// Pipeline.new creates a pipeline from named numeric transformers.
pub fn Pipeline.new(steps []PipelineStep) !&Pipeline {
	if steps.len == 0 {
		return errors.error('pipeline must contain at least one step', .einval)
	}
	mut names := map[string]bool{}
	for step in steps {
		if step.name.len == 0 {
			return errors.error('pipeline step names must not be empty', .einval)
		}
		if step.name in names {
			return errors.error('duplicate pipeline step name: ${step.name}', .einval)
		}
		names[step.name] = true
	}
	return &Pipeline{
		steps: steps.clone()
	}
}

// fit learns each transform in sequence. An empty feature-name slice generates x0, x1, ...
pub fn (mut p Pipeline) fit(data [][]f64, feature_names []string) ! {
	p.fit_apply(data, feature_names)!
}

// fit_transform fits each step on its input and returns the transformed data.
pub fn (mut p Pipeline) fit_transform(data [][]f64, feature_names []string) ![][]f64 {
	return p.fit_apply(data, feature_names)
}

fn (mut p Pipeline) fit_apply(data [][]f64, feature_names []string) ![][]f64 {
	p.fitted = false
	p.n_features_in_ = 0
	p.n_features_out_ = 0
	p.feature_names_in_ = []string{}
	p.feature_names_out_ = []string{}
	p.n_features_out_by_step = []int{}

	n_features := validate_pipeline_matrix(data, -1, false)!
	mut names := feature_names.clone()
	if names.len == 0 {
		for feature in 0 .. n_features {
			names << 'x${feature}'
		}
	} else if names.len != n_features {
		return errors.error('expected ${n_features} input feature names, got ${names.len}',
			.einval)
	}

	mut current := data.clone()
	mut current_names := names.clone()
	mut step_feature_counts := []int{cap: p.steps.len}
	for mut step in p.steps {
		step.transformer.fit(current) or {
			return errors.error('pipeline step `${step.name}` fit failed: ${err.msg()}', .efailed)
		}
		next := step.transformer.transform(current) or {
			return errors.error('pipeline step `${step.name}` transform failed: ${err.msg()}',
				.efailed)
		}
		output_features := validate_pipeline_output(next, current.len, step.name)!
		next_names := step.transformer.get_feature_names_out(current_names) or {
			return errors.error('pipeline step `${step.name}` feature names failed: ${err.msg()}',
				.efailed)
		}
		if next_names.len != output_features {
			return errors.error('pipeline step `${step.name}` returned ${output_features} features but ${next_names.len} names',
				.einval)
		}
		current = next.clone()
		current_names = next_names.clone()
		step_feature_counts << output_features
	}

	p.n_features_in_ = n_features
	p.n_features_out_ = current_names.len
	p.feature_names_in_ = names
	p.feature_names_out_ = current_names
	p.n_features_out_by_step = step_feature_counts
	p.fitted = true
	return current
}

// transform applies the fitted steps without changing their learned state.
pub fn (p &Pipeline) transform(data [][]f64) ![][]f64 {
	if !p.fitted {
		return errors.error('Pipeline must be fitted before transform', .efailed)
	}
	validate_pipeline_matrix(data, p.n_features_in_, true)!
	if data.len == 0 {
		return [][]f64{}
	}

	mut current := data.clone()
	for i, step in p.steps {
		next := step.transformer.transform(current) or {
			return errors.error('pipeline step `${step.name}` transform failed: ${err.msg()}',
				.efailed)
		}
		output_features := validate_pipeline_output(next, current.len, step.name)!
		if output_features != p.n_features_out_by_step[i] {
			return errors.error('pipeline step `${step.name}` returned ${output_features} features; expected ${p.n_features_out_by_step[i]}',
				.einval)
		}
		current = next.clone()
	}
	return current
}

// get_feature_names_out returns the output feature names learned during fit.
pub fn (p &Pipeline) get_feature_names_out() ![]string {
	if !p.fitted {
		return errors.error('Pipeline must be fitted before requesting feature names', .efailed)
	}
	return p.feature_names_out_.clone()
}

fn identity_feature_names(input_features []string, n_features int, transformer_name string) ![]string {
	if input_features.len != n_features {
		return errors.error('${transformer_name} expected ${n_features} feature names, got ${input_features.len}',
			.einval)
	}
	return input_features.clone()
}

fn validate_pipeline_matrix(data [][]f64, expected_features int, allow_empty bool) !int {
	if data.len == 0 {
		if allow_empty {
			return expected_features
		}
		return errors.error('pipeline cannot fit on empty data', .einval)
	}
	n_features := data[0].len
	if n_features == 0 {
		return errors.error('pipeline data must contain at least one feature', .einval)
	}
	if expected_features >= 0 && n_features != expected_features {
		return errors.error('expected ${expected_features} features, got ${n_features}', .einval)
	}
	for row_index, row in data {
		if row.len != n_features {
			return errors.error('row ${row_index} has ${row.len} features; expected ${n_features}',
				.einval)
		}
	}
	return n_features
}

fn validate_pipeline_output(data [][]f64, expected_rows int, step_name string) !int {
	if data.len != expected_rows {
		return errors.error('pipeline step `${step_name}` returned ${data.len} rows; expected ${expected_rows}',
			.einval)
	}
	return validate_pipeline_matrix(data, -1, false)
}
