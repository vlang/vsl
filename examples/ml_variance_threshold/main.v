module main

import vsl.model_selection
import vsl.preprocessing

fn main() {
	x := [[1.0, 7.0], [3.0, 7.0], [5.0, 7.0], [7.0, 7.0], [9.0, 7.0]]
	y := [0.0, 0.0, 1.0, 1.0, 1.0]
	split := model_selection.train_test_split(x, y, model_selection.TrainTestSplitConfig{
		test_size:   0.4
		random_seed: 42
	})!

	mut pipeline := preprocessing.Pipeline.new([
		preprocessing.PipelineStep{
			name:        'variance_filter'
			transformer: preprocessing.VarianceThreshold.new(0.0)
		},
	])!
	x_train := pipeline.fit_transform(split.x_train, ['signal', 'constant'])!
	x_test := pipeline.transform(split.x_test)!

	println('Selected features: ${pipeline.get_feature_names_out()!}')
	println('Training rows after selection: ${x_train}')
	println('Held-out rows after selection: ${x_test}')
}
