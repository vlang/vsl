module ml

import math

pub struct Sample {
pub mut:
	features []f64
pub:
	label int
}

pub struct Dataset {
pub mut:
	samples []Sample
pub:
	n_features int
	n_classes  int
}

struct Node {
mut:
	feature   int
	threshold f64
	label     int
	left      &Node
	right     &Node
}

pub struct DecisionTree {
mut:
	root              &Node
	max_depth         int
	min_samples_split int
}

pub fn DecisionTree.new(max_depth int, min_samples_split int) &DecisionTree {
	return &DecisionTree{
		root: &Node(unsafe { nil })
		max_depth: max_depth
		min_samples_split: min_samples_split
	}
}

pub fn index_of_max(arr []int) int {
	mut max_index := 0
	for i := 1; i < arr.len; i++ {
		if arr[i] > arr[max_index] {
			max_index = i
		}
	}
	return max_index
}

pub fn create_dataset(n_features int, n_classes int) &Dataset {
	return &Dataset{
		samples: []Sample{}
		n_features: n_features
		n_classes: n_classes
	}
}

pub fn (mut dataset Dataset) add_sample(features []f64, label int) bool {
	if label < 0 || label >= dataset.n_classes {
		return false
	}
	dataset.samples << Sample{
		features: features.clone()
		label: label
	}
	return true
}

pub fn (dataset &Dataset) calculate_entropy() f64 {
	mut class_counts := []int{len: dataset.n_classes, init: 0}
	for sample in dataset.samples {
		class_counts[sample.label]++
	}

	mut entropy := 0.0
	for count in class_counts {
		if count > 0 {
			p := f64(count) / f64(dataset.samples.len)
			entropy -= p * math.log2(p)
		}
	}
	return entropy
}

fn find_best_split(dataset &Dataset) (int, f64, f64) {
	mut best_gain := -1.0
	mut best_feature := 0
	mut best_threshold := 0.0

	for feature in 0 .. dataset.n_features {
		for sample in dataset.samples {
			threshold := sample.features[feature]
			mut left := create_dataset(dataset.n_features, dataset.n_classes)
			mut right := create_dataset(dataset.n_features, dataset.n_classes)

			for s in dataset.samples {
				if s.features[feature] <= threshold {
					left.add_sample(s.features, s.label)
				} else {
					right.add_sample(s.features, s.label)
				}
			}

			if left.samples.len > 0 && right.samples.len > 0 {
				p_left := f64(left.samples.len) / f64(dataset.samples.len)
				p_right := f64(right.samples.len) / f64(dataset.samples.len)
				gain := dataset.calculate_entropy() - (p_left * left.calculate_entropy() +
					p_right * right.calculate_entropy())

				if gain > best_gain {
					best_gain = gain
					best_feature = feature
					best_threshold = threshold
				}
			}
		}
	}

	return best_feature, best_threshold, best_gain
}

fn build_tree(dataset &Dataset, max_depth int, min_samples_split int) &Node {
	if dataset.samples.len < min_samples_split || max_depth == 0 {
		mut class_counts := []int{len: dataset.n_classes, init: 0}
		for sample in dataset.samples {
			class_counts[sample.label]++
		}
		label := index_of_max(class_counts)
		return &Node{
			feature: -1
			threshold: 0
			label: label
			left: &Node(unsafe { nil })
			right: &Node(unsafe { nil })
		}
	}

	best_feature, best_threshold, best_gain := find_best_split(dataset)

	if best_gain <= 0 {
		mut class_counts := []int{len: dataset.n_classes, init: 0}
		for sample in dataset.samples {
			class_counts[sample.label]++
		}
		label := index_of_max(class_counts)
		return &Node{
			feature: -1
			threshold: 0
			label: label
			left: &Node(unsafe { nil })
			right: &Node(unsafe { nil })
		}
	}

	mut left := create_dataset(dataset.n_features, dataset.n_classes)
	mut right := create_dataset(dataset.n_features, dataset.n_classes)

	for sample in dataset.samples {
		if sample.features[best_feature] <= best_threshold {
			left.add_sample(sample.features, sample.label)
		} else {
			right.add_sample(sample.features, sample.label)
		}
	}

	left_subtree := build_tree(left, max_depth - 1, min_samples_split)
	right_subtree := build_tree(right, max_depth - 1, min_samples_split)

	return &Node{
		feature: best_feature
		threshold: best_threshold
		label: -1
		left: left_subtree
		right: right_subtree
	}
}

pub fn (mut dt DecisionTree) train(dataset &Dataset) {
	dt.root = build_tree(dataset, dt.max_depth, dt.min_samples_split)
}

pub fn (dt &DecisionTree) predict(features []f64) int {
	return predict_recursive(dt.root, features)
}

fn predict_recursive(node &Node, features []f64) int {
	if node.left == unsafe { nil } && node.right == unsafe { nil } {
		return node.label
	}

	if features[node.feature] <= node.threshold {
		return predict_recursive(node.left, features)
	} else {
		return predict_recursive(node.right, features)
	}
}

pub fn calculate_information_gain(parent &Dataset, left &Dataset, right &Dataset) f64 {
	p_left := f64(left.samples.len) / f64(parent.samples.len)
	p_right := f64(right.samples.len) / f64(parent.samples.len)
	return parent.calculate_entropy() - (p_left * left.calculate_entropy() +
		p_right * right.calculate_entropy())
}
