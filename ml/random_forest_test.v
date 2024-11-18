module ml

import rand

fn test_random_forest_creation() {
	rf := RandomForest.new(10, 5, 2, 3)
	assert rf.n_trees == 10
	assert rf.max_depth == 5
	assert rf.min_samples_split == 2
	assert rf.feature_subset_size == 3
	assert rf.trees.len == 0
}

fn test_bootstrap_sample() {
	mut dataset := create_dataset(5, 2)
	for i in 0 .. 100 {
		dataset.add_sample([f64(i), f64(i * 2), f64(i * 3), f64(i * 4), f64(i * 5)], i % 2)
	}

	bootstrap := bootstrap_sample(dataset)
	assert bootstrap.samples.len == dataset.samples.len
	assert bootstrap.n_features == dataset.n_features
	assert bootstrap.n_classes == dataset.n_classes
}

fn test_select_feature_subset() {
	n_features := 10
	subset_size := 5
	subset := select_feature_subset(n_features, subset_size)
	assert subset.len == subset_size
	assert subset.all(it >= 0 && it < n_features)
}

fn test_random_forest_train_and_predict() {
	mut dataset := create_dataset(4, 2)
	for i in 0 .. 1000 {
		if i % 2 == 0 {
			dataset.add_sample([f64(i), f64(i * 2), f64(i * 3), f64(i * 4)], 0)
		} else {
			dataset.add_sample([f64(i), f64(i * 2), f64(i * 3), f64(i * 4)], 1)
		}
	}

	mut rf := RandomForest.new(10, 5, 5, 2)
	rf.train(dataset)

	assert rf.trees.len == 10

	for i in 0 .. 100 {
		features := [f64(i * 10), f64(i * 20), f64(i * 30), f64(i * 40)]
		prediction := rf.predict(features)
		assert prediction == 0 || prediction == 1
	}
}

fn main() {
	test_random_forest_creation()
	test_bootstrap_sample()
	test_select_feature_subset()
	test_random_forest_train_and_predict()
	println('All Random Forest tests passed successfully!')
}
