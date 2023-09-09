module main

import vsl.ml
import vsl.plot

// data
mut data := ml.data_from_raw_x([
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
mut model := ml.new_kmeans(mut data, nb_classes, 'kmeans')
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

mut plt := plot.new_plot()
plt.set_layout(
	title: 'Clustering K-means Example'
)

plt.add_trace(
	name: 'centroids'
	trace_type: .scatter
	x: model.centroids.map(it[0])
	y: model.centroids.map(it[1])
	mode: 'markers'
	colorscale: 'smoker'
	marker: plot.Marker{
		size: []f64{len: model.centroids.len, init: 12.0}
	}
)

x := data.x.get_col(0)
y := data.x.get_col(1)

for i in 0 .. nb_classes {
	mut x_for_class := []f64{}
	mut y_for_class := []f64{}
	for j in 0 .. data.nb_samples {
		if model.classes[j] == i {
			x_for_class << x[j]
			y_for_class << y[j]
		}
	}

	plt.add_trace(
		name: 'class #${i}'
		trace_type: .scatter
		x: x_for_class
		y: y_for_class
		mode: 'markers'
		colorscale: 'smoker'
		marker: plot.Marker{
			size: []f64{len: data.nb_samples, init: 12.0}
		}
	)
}

plt.show()!
