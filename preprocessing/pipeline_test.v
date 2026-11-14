module preprocessing

import math

fn test_pipeline_fits_training_data_and_preserves_feature_names() ! {
	missing := math.nan()
	training := [[1.0, missing], [3.0, 4.0]]
	mut pipeline := Pipeline.new([
		PipelineStep{
			name:        'impute'
			transformer: SimpleImputer.new(.mean, 0.0)
		},
		PipelineStep{
			name:        'scale'
			transformer: StandardScaler.new()
		},
		PipelineStep{
			name:        'polynomial'
			transformer: PolynomialFeatures{
				degree: 2
			}
		},
	])!

	fitted := pipeline.fit_transform(training, ['age', 'income'])!
	assert_matrix_near(fitted, [[1.0, -1.0, 0.0, 1.0, 0.0, 0.0], [1.0, 1.0, 0.0, 1.0, 0.0, 0.0]])
	assert pipeline.n_features_in_ == 2
	assert pipeline.n_features_out_ == 6
	assert pipeline.get_feature_names_out()! == ['1', 'age', 'income', 'age^2', 'age*income', 'income^2']

	inference := pipeline.transform([[missing, 10.0]])!
	assert inference == [[1.0, 0.0, 6.0, 0.0, 0.0, 36.0]]
	assert pipeline.feature_names_in_ == ['age', 'income']
}

fn assert_matrix_near(got [][]f64, expected [][]f64) {
	assert got.len == expected.len
	for row_index, row in got {
		assert row.len == expected[row_index].len
		for column, value in row {
			assert math.abs(value - expected[row_index][column]) < 1e-12
		}
	}
}

fn test_pipeline_generates_names_and_accepts_empty_inference() ! {
	mut pipeline := Pipeline.new([
		PipelineStep{
			name:        'scale'
			transformer: MinMaxScaler.new(0.0, 1.0)
		},
	])!
	pipeline.fit([[2.0], [4.0]], [])!
	assert pipeline.feature_names_in_ == ['x0']
	assert pipeline.get_feature_names_out()! == ['x0']
	assert pipeline.transform([])!.len == 0
}

fn test_pipeline_requires_fit_and_validates_input_schema() ! {
	mut pipeline := Pipeline.new([
		PipelineStep{
			name:        'scale'
			transformer: StandardScaler.new()
		},
	])!

	if _ := pipeline.transform([[1.0]]) {
		assert false, 'transform before fit must fail'
	} else {
		assert err.msg().contains('must be fitted')
	}
	if _ := pipeline.fit([[1.0, 2.0]], ['only_one_name']) {
		assert false, 'feature name count must match the input width'
	} else {
		assert err.msg().contains('expected 2 input feature names')
	}
	if _ := pipeline.fit([[1.0, 2.0], [3.0]], []) {
		assert false, 'ragged rows must fail'
	} else {
		assert err.msg().contains('row 1')
	}

	pipeline.fit([[1.0], [3.0]], [])!
	if _ := pipeline.transform([[1.0, 2.0]]) {
		assert false, 'inference width must match the fitted input width'
	} else {
		assert err.msg().contains('expected 1 features')
	}
}

fn test_pipeline_rejects_empty_or_ambiguous_steps() {
	if _ := Pipeline.new([]) {
		assert false, 'a pipeline must contain at least one step'
	} else {
		assert err.msg().contains('at least one step')
	}
	if _ := Pipeline.new([
		PipelineStep{
			name:        'scale'
			transformer: StandardScaler.new()
		},
		PipelineStep{
			name:        'scale'
			transformer: RobustScaler.new()
		},
	]) {
		assert false, 'pipeline step names must be unique'
	} else {
		assert err.msg().contains('duplicate pipeline step name')
	}
}
