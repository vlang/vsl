module ml

import math

fn test_decision_tree_creation() {
	max_depth := 3
	min_samples_split := 2
	dt := DecisionTree.new(max_depth, min_samples_split)
	assert dt.max_depth == max_depth
	assert dt.min_samples_split == min_samples_split
}

fn test_dataset_creation() {
	n_features := 3
	n_classes := 4
	dataset := create_dataset(n_features, n_classes)
	assert dataset.n_features == n_features
	assert dataset.n_classes == n_classes
	assert dataset.samples.len == 0
}

fn test_add_sample() {
	mut dataset := create_dataset(3, 4)
	features := [1.0, 2.0, 3.0]
	label := 2
	assert dataset.add_sample(features, label) == true
	assert dataset.samples.len == 1
	assert dataset.samples[0].features == features
	assert dataset.samples[0].label == label

	// Test invalid label
	assert dataset.add_sample(features, 5) == false
	assert dataset.samples.len == 1
}

fn test_entropy_calculation() {
	mut dataset := create_dataset(3, 4)
	dataset.add_sample([1.0, 2.0, 0.5], 0)
	dataset.add_sample([2.0, 3.0, 1.0], 1)
	dataset.add_sample([3.0, 4.0, 1.5], 2)
	dataset.add_sample([4.0, 5.0, 2.0], 3)
	dataset.add_sample([2.5, 3.5, 1.2], 1)

	entropy := dataset.calculate_entropy()
	expected_entropy := 1.9219280948873623 // Manually calculated
	assert math.abs(entropy - expected_entropy) < 1e-6
}

fn test_decision_tree_training_and_prediction() {
	mut dataset := create_dataset(3, 4)
	dataset.add_sample([1.0, 2.0, 0.5], 0)
	dataset.add_sample([2.0, 3.0, 1.0], 1)
	dataset.add_sample([3.0, 4.0, 1.5], 2)
	dataset.add_sample([4.0, 5.0, 2.0], 3)
	dataset.add_sample([2.5, 3.5, 1.2], 1)

	mut dt := DecisionTree.new(3, 2)
	dt.train(dataset)

	// Test predictions
	assert dt.predict([2.5, 3.5, 1.3]) == 1 // Manually calculated
}

fn test_information_gain() {
	mut parent := create_dataset(3, 3)
	parent.add_sample([2.0, 3.5, 1.1], 0)
	parent.add_sample([3.0, 4.0, 1.5], 1)
	parent.add_sample([1.5, 2.0, 0.5], 0)
	parent.add_sample([2.5, 3.0, 1.0], 1)
	parent.add_sample([4.0, 5.0, 2.0], 2)

	mut left := create_dataset(3, 3)
	left.add_sample([2.0, 3.5, 1.1], 0)
	left.add_sample([1.5, 2.0, 0.5], 0)

	mut right := create_dataset(3, 3)
	right.add_sample([3.0, 4.0, 1.5], 1)
	right.add_sample([2.5, 3.0, 1.0], 1)
	right.add_sample([4.0, 5.0, 2.0], 2)

	info_gain := calculate_information_gain(parent, left, right)
	expected_gain := 0.9709505944546686 // Manually calculated
	assert math.abs(info_gain - expected_gain) < 1e-6
}

fn main() {
	test_decision_tree_creation()
	test_dataset_creation()
	test_add_sample()
	test_entropy_calculation()
	test_decision_tree_training_and_prediction()
	test_information_gain()
}

