module ml

import rand

pub struct RandomForest {
pub mut:
	trees               []DecisionTree
	n_trees             int
	max_depth           int
	min_samples_split   int
	feature_subset_size int
}

pub fn RandomForest.new(n_trees int, max_depth int, min_samples_split int, feature_subset_size int) &RandomForest {
	return &RandomForest{
		trees: []DecisionTree{}
		n_trees: n_trees
		max_depth: max_depth
		min_samples_split: min_samples_split
		feature_subset_size: feature_subset_size
	}
}

fn bootstrap_sample(dataset &Dataset) &Dataset {
	mut bootstrap := create_dataset(dataset.n_features, dataset.n_classes)
	for _ in 0 .. dataset.samples.len {
		sample_index := rand.intn(dataset.samples.len) or { 0 }
		sample := dataset.samples[sample_index]
		bootstrap.add_sample(sample.features, sample.label)
	}
	return bootstrap
}

fn select_feature_subset(n_features int, subset_size int) []int {
	mut features := []int{len: n_features, init: index}
	rand.shuffle(mut features) or { return features[..subset_size] }
	return features[..subset_size]
}

pub fn (mut rf RandomForest) train(dataset &Dataset) {
	for _ in 0 .. rf.n_trees {
		mut tree := DecisionTree.new(rf.max_depth, rf.min_samples_split)
		bootstrap := bootstrap_sample(dataset)

		feature_subset := select_feature_subset(dataset.n_features, rf.feature_subset_size)

		tree.train_with_feature_subset(bootstrap, feature_subset)
		rf.trees << tree
	}
}

pub fn (rf &RandomForest) predict(features []f64) int {
	if rf.trees.len == 0 {
		return -1
	}

	mut votes := []int{len: rf.trees[0].root.label + 1, init: 0}
	for tree in rf.trees {
		prediction := tree.predict(features)
		if prediction >= 0 && prediction < votes.len {
			votes[prediction]++
		}
	}
	return index_of_max(votes)
}

pub fn (mut dt DecisionTree) train_with_feature_subset(dataset &Dataset, feature_subset []int) {
	dt.root = build_tree_with_feature_subset(dataset, dt.max_depth, dt.min_samples_split,
		feature_subset)
}

fn build_tree_with_feature_subset(dataset &Dataset, max_depth int, min_samples_split int, feature_subset []int) &Node {
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

	best_feature, best_threshold, best_gain := find_best_split_with_subset(dataset, feature_subset)

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

	left_subtree := build_tree_with_feature_subset(left, max_depth - 1, min_samples_split,
		feature_subset)
	right_subtree := build_tree_with_feature_subset(right, max_depth - 1, min_samples_split,
		feature_subset)

	return &Node{
		feature: best_feature
		threshold: best_threshold
		label: -1
		left: left_subtree
		right: right_subtree
	}
}

fn find_best_split_with_subset(dataset &Dataset, feature_subset []int) (int, f64, f64) {
	mut best_gain := -1.0
	mut best_feature := 0
	mut best_threshold := 0.0

	for feature in feature_subset {
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
