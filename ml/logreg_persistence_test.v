module ml

import math
import os

fn test_logreg_json_artifact_round_trip_predicts_without_training_data() ! {
	mut data := Data.from_raw_xy_sep([
		[0.0],
		[1.0],
		[2.0],
		[3.0],
	], [0.0, 0.0, 1.0, 1.0])!
	mut model := LogReg.new(mut data, 'logreg_persistence_test')
	model.params.set_lambda(0.1)
	model.train(epochs: 100, learning_rate: 0.1)
	expected := model.predict([1.5])

	path := os.join_path(os.dir(@FILE), '.logreg_persistence_${os.getpid()}.json')
	defer {
		os.rm(path) or {}
	}
	model.save_json(path)!

	artifact := load_logreg_artifact(path)!
	actual := artifact.predict([1.5])!
	assert artifact.n_features() == 1
	assert math.abs(actual - expected) < 1e-14
}

fn test_logreg_json_artifact_rejects_malformed_and_unsupported_content() ! {
	valid := '{"schema":"vsl.ml.model","version":1,"model":"logistic_regression","feature_count":2,"weights":[0.5,-1.0],"bias":0.25,"lambda":0.1}'
	unsupported_version := '{"schema":"vsl.ml.model","version":2,"model":"logistic_regression","feature_count":2,"weights":[0.5,-1.0],"bias":0.25,"lambda":0.1}'
	unsupported_schema := '{"schema":"other.model","version":1,"model":"logistic_regression","feature_count":2,"weights":[0.5,-1.0],"bias":0.25,"lambda":0.1}'
	unsupported_model := '{"schema":"vsl.ml.model","version":1,"model":"random_forest","feature_count":2,"weights":[0.5,-1.0],"bias":0.25,"lambda":0.1}'
	missing_field := '{"schema":"vsl.ml.model","version":1,"model":"logistic_regression","feature_count":2,"weights":[0.5,-1.0],"bias":0.25}'
	extra_field := '{"schema":"vsl.ml.model","version":1,"model":"logistic_regression","feature_count":2,"weights":[0.5,-1.0],"bias":0.25,"lambda":0.1,"payload":"ignored"}'
	wrong_feature_count := '{"schema":"vsl.ml.model","version":1,"model":"logistic_regression","feature_count":3,"weights":[0.5,-1.0],"bias":0.25,"lambda":0.1}'
	wrong_parameter_type := '{"schema":"vsl.ml.model","version":1,"model":"logistic_regression","feature_count":2,"weights":[0.5,"-1.0"],"bias":0.25,"lambda":0.1}'
	negative_lambda := '{"schema":"vsl.ml.model","version":1,"model":"logistic_regression","feature_count":2,"weights":[0.5,-1.0],"bias":0.25,"lambda":-0.1}'

	_ := LogRegArtifact.from_json(valid)!
	assert_invalid_logreg_artifact('not JSON', 'invalid logistic-regression JSON')
	assert_invalid_logreg_artifact(unsupported_version, 'unsupported logistic-regression artifact version')
	assert_invalid_logreg_artifact(unsupported_schema, 'unsupported logistic-regression artifact schema')
	assert_invalid_logreg_artifact(unsupported_model, 'unsupported logistic-regression model')
	assert_invalid_logreg_artifact(missing_field, 'invalid field set')
	assert_invalid_logreg_artifact(extra_field, 'invalid field set')
	assert_invalid_logreg_artifact(wrong_feature_count, 'feature_count must match')
	assert_invalid_logreg_artifact(wrong_parameter_type, 'weights[1]` must be a number')
	assert_invalid_logreg_artifact(negative_lambda, 'lambda must be non-negative')
}

fn test_logreg_json_artifact_prediction_checks_input_shape_and_values() ! {
	artifact := LogRegArtifact.from_json('{"schema":"vsl.ml.model","version":1,"model":"logistic_regression","feature_count":1,"weights":[0.5],"bias":0.25,"lambda":0.0}')!
	if _ := artifact.predict([1.0, 2.0]) {
		assert false, 'prediction with the wrong feature count must fail'
	} else {
		assert err.msg().contains('expected 1 features')
	}
	if _ := artifact.predict([math.nan()]) {
		assert false, 'prediction with a non-finite feature must fail'
	} else {
		assert err.msg().contains('must be finite')
	}
}

fn assert_invalid_logreg_artifact(text string, message string) {
	if _ := LogRegArtifact.from_json(text) {
		assert false, 'invalid artifact must be rejected: ${text}'
	} else {
		assert err.msg().contains(message), 'got error: ${err.msg()}'
	}
}
