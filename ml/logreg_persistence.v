module ml

import json2
import math
import os
import rand
import strings
import vsl.errors
import vsl.fun

const logreg_artifact_schema = 'vsl.ml.model'
const logreg_artifact_model = 'logistic_regression'
const logreg_artifact_version = 1
const logreg_artifact_max_size = 64 * 1024 * 1024
const logreg_artifact_read_buffer_size = 16 * 1024
const logreg_artifact_fields = ['schema', 'version', 'model', 'feature_count', 'weights', 'bias',
	'lambda']

struct LogRegJSONArtifact {
pub:
	schema        string
	version       int
	model         string
	feature_count int
	weights       []f64
	bias          f64
	lambda        f64
}

// LogRegArtifact stores validated inference state without retaining training data.
pub struct LogRegArtifact {
	feature_count int
	weights       []f64
	bias          f64
	lambda        f64
}

// n_features returns the feature count expected by this fitted model.
pub fn (artifact &LogRegArtifact) n_features() int {
	return artifact.feature_count
}

// predict returns the probability of the positive class for one feature row.
pub fn (artifact &LogRegArtifact) predict(x []f64) !f64 {
	artifact.validate()!
	if x.len != artifact.feature_count {
		return errors.error('LogRegArtifact expected ${artifact.feature_count} features, got ${x.len}',
			.einval)
	}
	mut score := artifact.bias
	for feature, value in x {
		if math.is_nan(value) || math.is_inf(value, 0) {
			return errors.error('prediction feature ${feature} must be finite', .einval)
		}
		score += value * artifact.weights[feature]
	}
	if math.is_nan(score) || math.is_inf(score, 0) {
		return errors.error('LogRegArtifact prediction score is not finite', .einval)
	}
	return fun.logistic(score)
}

// save_json writes the fitted parameters and schema metadata as JSON.
pub fn (model &LogReg) save_json(path string) ! {
	artifact := model.to_logreg_artifact()!
	json_artifact := LogRegJSONArtifact{
		schema:        logreg_artifact_schema
		version:       logreg_artifact_version
		model:         logreg_artifact_model
		feature_count: artifact.feature_count
		weights:       artifact.weights.clone()
		bias:          artifact.bias
		lambda:        artifact.lambda
	}
	write_logreg_artifact(path, json2.encode(json_artifact, prettify: true))!
}

// from_json validates and decodes a logistic-regression inference artifact.
// JSON is parsed as data only; no code or executable object is deserialized.
pub fn LogRegArtifact.from_json(text string) !LogRegArtifact {
	validate_logreg_artifact_size(u64(text.len))!
	fields := json2.decode[map[string]json2.Any](text, json2.DecoderOptions{
		strict: true
	}) or {
		return errors.error('invalid logistic-regression JSON: ${err.msg()}', .einval)
	}
	if fields.len != logreg_artifact_fields.len {
		return errors.error('logistic-regression artifact has an invalid field set', .einval)
	}
	for field in logreg_artifact_fields {
		if field !in fields {
			return errors.error('logistic-regression artifact is missing `${field}`', .einval)
		}
	}
	for field in fields.keys() {
		if field !in logreg_artifact_fields {
			return errors.error('logistic-regression artifact contains unsupported field `${field}`',
				.einval)
		}
	}

	schema := logreg_json_string(fields, 'schema')!
	if schema != logreg_artifact_schema {
		return errors.error('unsupported logistic-regression artifact schema `${schema}`', .einval)
	}
	version := logreg_json_number(fields, 'version')!
	if math.floor(version) != version {
		return errors.error('logistic-regression artifact version must be an integer', .einval)
	}
	if version != f64(logreg_artifact_version) {
		return errors.error('unsupported logistic-regression artifact version ${version}', .einval)
	}
	model := logreg_json_string(fields, 'model')!
	if model != logreg_artifact_model {
		return errors.error('unsupported logistic-regression model `${model}`', .einval)
	}

	feature_count := logreg_json_number(fields, 'feature_count')!
	if feature_count <= 0.0 || math.floor(feature_count) != feature_count {
		return errors.error('logistic-regression feature_count must be a positive integer', .einval)
	}
	weights_value := fields['weights'] or {
		return errors.error('logistic-regression artifact is missing `weights`', .einval)
	}
	if weights_value !is []json2.Any {
		return errors.error('logistic-regression artifact `weights` must be an array', .einval)
	}
	weight_values := weights_value as []json2.Any
	if weight_values.len == 0 || feature_count != f64(weight_values.len) {
		return errors.error('logistic-regression feature_count must match the non-empty weights array',
			.einval)
	}
	mut weights := []f64{cap: weight_values.len}
	for index, value in weight_values {
		weight := logreg_json_number_value(value, 'weights[${index}]')!
		weights << weight
	}
	bias := logreg_json_number(fields, 'bias')!
	lambda := logreg_json_number(fields, 'lambda')!
	if lambda < 0.0 {
		return errors.error('logistic-regression lambda must be non-negative', .einval)
	}

	artifact := LogRegArtifact{
		feature_count: weights.len
		weights:       weights
		bias:          bias
		lambda:        lambda
	}
	artifact.validate()!
	return artifact
}

// load_logreg_artifact reads a validated inference artifact from a JSON file.
pub fn load_logreg_artifact(path string) !LogRegArtifact {
	text := read_logreg_artifact(path)!
	return LogRegArtifact.from_json(text)
}

fn write_logreg_artifact(path string, text string) ! {
	validate_logreg_artifact_size(u64(text.len))!
	validate_logreg_destination(path)!
	temp_dir := os.join_path(os.dir(path), '.vsl-logreg-${rand.ulid()}')
	os.mkdir(temp_dir) or {
		return errors.error('cannot create temporary logistic-regression artifact: ${err.msg()}',
			.efailed)
	}
	defer {
		os.rmdir_all(temp_dir) or {
			eprintln('cannot remove temporary logistic-regression artifact directory `${temp_dir}`: ${err.msg()}')
		}
	}
	temp_path := os.join_path(temp_dir, 'artifact.json')
	mut temp_file := os.create(temp_path) or {
		return errors.error('cannot create temporary logistic-regression artifact: ${err.msg()}',
			.efailed)
	}
	defer {
		temp_file.close()
	}
	bytes_written := temp_file.write_string(text) or {
		return errors.error('cannot write temporary logistic-regression artifact: ${err.msg()}',
			.efailed)
	}
	if bytes_written != text.len {
		return errors.error('cannot write complete temporary logistic-regression artifact', .efailed)
	}
	temp_file.flush()
	temp_file.close()
	written_text := os.read_file(temp_path) or {
		return errors.error('cannot verify temporary logistic-regression artifact: ${err.msg()}',
			.efailed)
	}
	if written_text != text {
		return errors.error('temporary logistic-regression artifact failed verification', .efailed)
	}
	replace_logreg_artifact(temp_path, path)!
}

fn validate_logreg_destination(path string) ! {
	if !os.exists(path) {
		return
	}
	file_stat := os.stat(path) or {
		return errors.error('cannot inspect logistic-regression artifact destination: ${err.msg()}',
			.efailed)
	}
	if file_stat.get_filetype() != .regular {
		return errors.error('logistic-regression artifact destination must be a regular file',
			.einval)
	}
}

fn replace_logreg_artifact(source string, destination string) ! {
	$if windows {
		replace_logreg_artifact_windows(source, destination)!
	} $else {
		os.rename_dir(source, destination) or {
			return errors.error('cannot replace logistic-regression artifact: ${err.msg()}',
				.efailed)
		}
	}
}

fn read_logreg_artifact(path string) !string {
	file_stat := os.stat(path) or {
		return errors.error('cannot inspect logistic-regression artifact: ${err.msg()}', .efailed)
	}
	if file_stat.get_filetype() != .regular {
		return errors.error('logistic-regression artifact must be a regular file', .einval)
	}
	validate_logreg_artifact_size(file_stat.size)!
	initial_capacity := if file_stat.size < u64(logreg_artifact_read_buffer_size) {
		int(file_stat.size)
	} else {
		logreg_artifact_read_buffer_size
	}
	mut file := os.open_file(path, 'rb') or {
		return errors.error('cannot read logistic-regression artifact: ${err.msg()}', .efailed)
	}
	defer {
		file.close()
	}
	mut text := strings.new_builder(initial_capacity)
	mut total_size := u64(0)
	mut buffer := []u8{len: logreg_artifact_read_buffer_size}
	for {
		bytes_read := file.read(mut buffer) or {
			if err is os.Eof {
				break
			}
			return errors.error('cannot read logistic-regression artifact: ${err.msg()}',
				.efailed)
		}
		if bytes_read == 0 {
			break
		}
		total_size += u64(bytes_read)
		validate_logreg_artifact_size(total_size)!
		text.write(buffer[..bytes_read])!
	}
	return text.str()
}

fn validate_logreg_artifact_size(size u64) ! {
	if size > u64(logreg_artifact_max_size) {
		return errors.error('logistic-regression artifact exceeds the ${logreg_artifact_max_size}-byte maximum',
			.einval)
	}
}

fn (model &LogReg) to_logreg_artifact() !LogRegArtifact {
	feature_count := model.data.nb_features
	weights := model.params.get_thetas()
	bias := model.params.get_bias()
	lambda := model.params.get_lambda()
	if feature_count <= 0 || weights.len != feature_count {
		return errors.error('LogReg parameters do not match the model feature count', .einval)
	}
	artifact := LogRegArtifact{
		feature_count: feature_count
		weights:       weights
		bias:          bias
		lambda:        lambda
	}
	artifact.validate()!
	return artifact
}

fn (artifact &LogRegArtifact) validate() ! {
	if artifact.feature_count <= 0 || artifact.weights.len != artifact.feature_count {
		return errors.error('LogRegArtifact feature_count must match its non-empty weights', .einval)
	}
	for index, weight in artifact.weights {
		if math.is_nan(weight) || math.is_inf(weight, 0) {
			return errors.error('LogRegArtifact weight ${index} must be finite', .einval)
		}
	}
	if math.is_nan(artifact.bias) || math.is_inf(artifact.bias, 0) {
		return errors.error('LogRegArtifact bias must be finite', .einval)
	}
	if math.is_nan(artifact.lambda) || math.is_inf(artifact.lambda, 0) || artifact.lambda < 0.0 {
		return errors.error('LogRegArtifact lambda must be finite and non-negative', .einval)
	}
}

fn logreg_json_string(fields map[string]json2.Any, name string) !string {
	value := fields[name] or {
		return errors.error('logistic-regression artifact is missing `${name}`', .einval)
	}
	if value !is string {
		return errors.error('logistic-regression artifact `${name}` must be a string', .einval)
	}
	return value as string
}

fn logreg_json_number(fields map[string]json2.Any, name string) !f64 {
	value := fields[name] or {
		return errors.error('logistic-regression artifact is missing `${name}`', .einval)
	}
	return logreg_json_number_value(value, name)
}

fn logreg_json_number_value(value json2.Any, name string) !f64 {
	if value !is f64 {
		return errors.error('logistic-regression artifact `${name}` must be a number', .einval)
	}
	number := value as f64
	if math.is_nan(number) || math.is_inf(number, 0) {
		return errors.error('logistic-regression artifact `${name}` must be finite', .einval)
	}
	return number
}
