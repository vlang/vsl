module main

import vsl.ml
import internal.dataset

// data
mut data := ml.data_from_raw_x(dataset.raw_dataset.map([it[0], it[1]]))!

// model
nb_classes := 3
mut model := ml.new_kmeans(mut data, nb_classes, 'kmeans')
model.set_centroids([
	// class 0
	[3.0, 3],
	// class 1
	[6.0, 2],
	// class 2
	[8.0, 5],
])

// initial classes
model.find_closest_centroids()

// initial computation of centroids
model.compute_centroids()

// train
model.train(epochs: 6)

// Plot the results using the new plot method
model.plot()!
