module ml

fn test_kmeans_01() {
	// data
	mut data := Data.from_raw_x([
		[0.1, 0.7],
		[0.3, 0.7],
		[0.1, 0.9],
		[0.3, 0.9],
		[0.7, 0.1],
		[0.9, 0.1],
		[0.7, 0.3],
		[0.9, 0.3],
	])!

	// model
	nb_classes := 2
	mut model := Kmeans.new(mut data, nb_classes, 'kmeans')
	model.set_centroids_checked([
		// class 0
		[0.4, 0.6],
		// class 1
		[0.6, 0.4],
	])!

	// train
	model.find_closest_centroids()
	expected_classes := [
		0,
		0,
		0,
		0,
		1,
		1,
		1,
		1,
	]
	for i, c in model.classes {
		assert c == expected_classes[i]
	}
}

fn test_kmeans_supports_arbitrary_feature_counts_and_inertia() {
	mut data := Data.from_raw_x([
		[0.0, 0, 0],
		[0, 2, 2],
		[10, 10, 10],
		[12, 10, 10],
	])!
	mut model := Kmeans.new_checked(mut data, 2, 'three_features')!
	model.set_centroids_checked([
		[0.0, 1, 1],
		[11, 10, 10],
	])!
	model.find_closest_centroids()
	assert model.classes == [0, 0, 1, 1]
	assert model.inertia() == 6
	model.compute_centroids()
	assert model.centroids == [[0.0, 1, 1], [11, 10, 10]]
}

fn test_kmeans_preserves_empty_cluster_centroid_and_converges() {
	mut data := Data.from_raw_x([[0.0, 0], [0, 2], [10, 10], [12, 10]])!
	mut model := Kmeans.new(mut data, 3, 'empty_cluster')
	model.set_centroids_checked([[0.0, 1], [11, 10], [100, 100]])!
	model.train(epochs: 50, tol_norm_change: 1e-9)
	assert model.centroids[0] == [0.0, 1]
	assert model.centroids[1] == [11, 10]
	assert model.centroids[2] == [100, 100]
	assert model.inertia() == 4
}

fn test_kmeans_checked_constructor_rejects_invalid_cluster_count() {
	mut data := Data.from_raw_x([[0.0, 0], [1, 1]])!
	if _ := Kmeans.new_checked(mut data, 3, 'invalid') {
		assert false, 'K-means must reject more clusters than observations'
	}
}

fn test_kmeans_checked_centroids_reject_invalid_shapes() ! {
	mut data := Data.from_raw_x([[0.0, 1], [2, 3]])!
	mut model := Kmeans.new_checked(mut data, 2, 'bad_centroids')!
	if _ := model.set_centroids_checked([[0.0], [2.0]]) {
		assert false, 'K-means must reject centroids with the wrong feature count'
	}
}

fn test_kmeans_plus_plus_is_reproducible_and_selects_data_points() ! {
	values := [
		[0.0, 0],
		[0, 1],
		[10, 10],
		[11, 10],
	]
	mut data_a := Data.from_raw_x(values)!
	mut data_b := Data.from_raw_x(values)!
	mut model_a := Kmeans.new_checked(mut data_a, 2, 'seeded_a')!
	mut model_b := Kmeans.new_checked(mut data_b, 2, 'seeded_b')!
	model_a.initialize_kmeans_plus_plus(42)!
	model_b.initialize_kmeans_plus_plus(42)!
	assert model_a.centroids == model_b.centroids
	for centroid in model_a.centroids {
		assert centroid in values
	}
	model_a.train(epochs: 20, tol_norm_change: 1e-8)
	assert model_a.inertia() <= 1.0
}

fn test_kmeans_plus_plus_rejects_more_clusters_than_samples() ! {
	mut data := Data.from_raw_x([[0.0, 1], [2, 3]])!
	mut model := Kmeans.new(mut data, 3, 'too_many')
	if _ := model.initialize_kmeans_plus_plus(1) {
		assert false, 'K-means++ must reject more clusters than observations'
	}
}
