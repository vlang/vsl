module main

import vsl.ml
import vsl.plot

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
mut data := ml.data_from_raw_x([
	[0.1, 0.7],
	[0.3, 0.7],
	[0.1, 0.9],
	[0.3, 0.9],
	[0.7, 0.1],
	[0.9, 0.1],
	[0.7, 0.3],
	[0.9, 0.3],
])?

// model
nb_classes := 2
mut model := ml.new_kmeans(mut data, nb_classes, 'kmeans')
model.set_centroids([
	[0.4, 0.6] /* class 0 */,
	[0.6, 0.4] /* class 1 */,
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
