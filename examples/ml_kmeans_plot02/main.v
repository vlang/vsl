module main

import vsl.ml
import vsl.plot
import dataset

fn color_from_class(i int) string {
	return match i {
		0 { 'red' }
		1 { 'blue' }
		2 { 'green' }
		3 { 'yellow' }
		4 { 'orange' }
		5 { 'purple' }
		6 { 'pink' }
		7 { 'brown' }
		8 { 'black' }
		9 { 'grey' }
		else { 'white' }
	}
}

// data
mut data := ml.data_from_raw_x(dataset.raw_dataset.map([it[0], it[1]]))?

// model
nb_classes := 3
mut model := ml.new_kmeans(mut data, nb_classes, 'kmeans')
model.set_centroids([
	[3.0, 3] /* class 0 */,
	[6.0, 2] /* class 1 */,
	[8.0, 5] /* class 2 */,
])

// initial classes
model.find_closest_centroids()

// initial computation of centroids
model.compute_centroids()

// train
model.train(epochs: 6)

mut plt := plot.new_plot()
plt.set_layout(
	title: 'Clustering K-means Example'
)

for i, c in model.centroids {
	plt.add_trace(
		name: 'centroid for class #${i}'
		trace_type: .scatter
		x: [c[0]]
		y: [c[1]]
		mode: 'markers'
		marker: plot.Marker{
			size: [12.0]
			color: [color_from_class(i + 4)]
		}
	)
}

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
		marker: plot.Marker{
			size: []f64{len: data.nb_samples, init: 12.0}
			color: []string{len: data.nb_samples, init: color_from_class(i)}
		}
	)
}

plt.show()?
