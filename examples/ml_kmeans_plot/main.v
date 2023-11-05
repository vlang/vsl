module main

import vsl.ml
import internal.dataset

fn main() {
	// data
	x := dataset.raw_dataset.map([it[0], it[1]])
	mut data := ml.Data.from_raw_x(x)!

	// model
	nb_classes := 3
	mut model := ml.Kmeans.new(mut data, nb_classes, 'kmeans')
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
}
