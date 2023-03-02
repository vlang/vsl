module ml

fn test_kmeans_01() {
	// data
	mut data := data_from_raw_x([
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
	mut model := new_kmeans(mut data, nb_classes, 'kmeans')
	model.set_centroids([
		[0.4, 0.6] /* class 0 */,
		[0.6, 0.4] /* class 1 */,
	])

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
