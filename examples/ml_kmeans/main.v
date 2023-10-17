module main

import vsl.ml

// data
mut data := ml.Data.from_raw_x([
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
mut model := ml.Kmeans.new(mut data, nb_classes, 'kmeans')
model.set_centroids([
	// class 0
	[0.4, 0.6],
	// class 1
	[0.6, 0.4],
])

// initial classes
model.find_closest_centroids()

// initial computation of centroids
model.compute_centroids()

// train
model.train(epochs: 6)

// test
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
	println('class ${i}: ${c}')
}
