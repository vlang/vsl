module ml

import vsl.float.float64 { l2_distance_unitary }
import vsl.errors
import vsl.plot

// KNN is the struct defining a K-Nearest Neighbors classifier.
[heap]
pub struct KNN {
mut:
	name    string // name of this "observer"
	data    &Data[f64]
	weights map[f64]f64 // weights[class] = weight
pub mut:
	neighbors []Neighbor
	trained   bool
}

// Neighbor is a support struct to help organizing the code
// and calculating distances, as well as sorting using array.sort.
struct Neighbor {
mut:
	point    []f64
	class    f64
	distance f64
}

// new_knn accepts a `vml.ml.Data` parameter called `data`, that will be used
// to predict values with `KNN.predict`. You can use the following piece of code to
// make your life easier:
// ```mut knn := new_knn(mut data_from_raw_xy_sep([[0.0, 0.0], [10.0, 10.0]], [0.0, 1.0]))```
// If you predict with `knn.predict(1, [9.0, 9.0])`, it should return 1.0 as it is the closest
// to [10.0, 10.0] (which is class 1.0).
pub fn new_knn(mut data Data[f64], name string) !&KNN {
	if data.x.data.len == 0 {
		return errors.error('with name ${name} expects `data.x` to have at least one element.',
			.einval)
	}
	if data.y.len == 0 {
		return errors.error('with name ${name} expects `data.y` to have at least one element.',
			.einval)
	}
	mut knn := &KNN{
		name: name
		data: data
	}
	data.add_observer(knn) // need to recompute neighbors upon data changes
	knn.update() // compute first neighbors
	return knn
}

// name returns the name of this KNN object (thus defining the Observer interface)
pub fn (o &KNN) name() string {
	return o.name
}

// set_weights will set the weights for the KNN. They default to
// 1.0 for every class when this function is not called.
pub fn (mut knn KNN) set_weights(weights map[f64]f64) ! {
	mut new_weights := map[f64]f64{}
	for k, v in weights {
		if k !in knn.data.y {
			return errors.error('expects weights (map[f64]f64) to have ' +
				"all its keys present in the KNN's classes.", .einval)
		}
		if v == 0.0 {
			return errors.error('expects weights (map[f64]f64) to not have ' +
				'zeroes, as it cannot divide by zero.', .ezerodiv)
		}
		new_weights[k] = v
	}
	for class in knn.data.y {
		if class !in new_weights {
			new_weights[class] = 1.0
		}
	}
	knn.weights = new_weights.clone()
}

// update perform updates after data has been changed (as an Observer)
pub fn (mut knn KNN) update() {
	knn.train()
}

// train computes the neighbors and weights during training
pub fn (mut knn KNN) train() {
	if knn.data.x.data.len == 0 {
		return
	}
	if knn.data.y.len == 0 {
		return
	}

	mut x := knn.data.x.get_deep2()
	knn.neighbors = []Neighbor{cap: x.len}
	for i := 0; i < x.len; i++ {
		knn.neighbors << Neighbor{
			point: x[i]
			class: knn.data.y[i]
		}
	}
	mut weights := map[f64]f64{}
	for class in knn.data.y {
		weights[class] = 1.0
	}
	knn.weights = weights.clone()
	knn.trained = true
}

// data needed for KNN.predict
pub struct PredictConfig {
	max_iter int
	k        int
mut:
	to_pred []f64
}

// predict will find the `k` points nearest to the specified `to_pred`.
// If the value of `k` results in a draw - that is, a tie when determining
// the most frequent class in those k nearest neighbors (example:
// class 1 has 10 occurrences, class 2 has 5 and class 3 has 10) -,
// `k` will be decreased until there are no more ties. The worst case
// scenario is `k` ending up as 1. Also, it makes sure that if we do
// have a tie when k = 1, we select the first closest neighbor.
pub fn (mut knn KNN) predict(config PredictConfig) !f64 {
	k := config.k
	to_pred := config.to_pred

	if k <= 0 {
		return errors.error('expects k (int) to be >= 1.', .einval)
	}
	if to_pred.len <= 0 {
		return errors.error('expects to_pred ([]f64) to have at least 1 element.', .einval)
	}
	mut x := knn.data.x.get_deep2()
	for i := 0; i < x.len; i++ {
		knn.neighbors[i].distance = l2_distance_unitary(to_pred, x[i]) / knn.weights[knn.neighbors[i].class]
	}
	mut neighbors := knn.neighbors.clone()
	neighbors.sort(a.distance < b.distance)

	// Break ties
	mut new_k := k
	mut tied := true
	mut most_shown := knn.data.y[0]
	mut iter_number := 0
	for tied {
		if config.max_iter != 0 {
			if iter_number >= config.max_iter {
				break
			}
		}

		tied = false
		mut tmp_neighbors := neighbors[0..new_k].clone()
		mut freq := map[f64]int{}
		for n in tmp_neighbors {
			if n.class !in freq {
				freq[n.class] = 0
			}
			freq[n.class]++
		}
		most_shown = freq.keys()[0]
		mut most_times := 0
		for key, v in freq {
			if v > most_times {
				most_times = v
				most_shown = key
			}
		}
		for key, v in freq {
			if key != most_shown && v == most_times {
				tied = true
			}
		}
		if tied {
			new_k--
			if new_k < 0 {
				break
			}
		} else {
			break
		}

		// Avoids overflow if for some reason this loop
		// runs enough times to make iter_number go above
		// int's max value.
		if config.max_iter != 0 {
			iter_number++
		}
	}

	return most_shown
}

// str is a custom str function for observers to avoid printing data
pub fn (o &KNN) str() string {
	mut res := []string{}
	res << 'vsl.ml.KNN{'
	res << '    name: ${o.name}'
	res << '    weights: ${o.weights}'
	res << '    neighbors: ${o.neighbors}'
	res << '}'
	return res.join('\n')
}

// plot method for visualizing the KNN model
pub fn (o &KNN) plot() ! {
	mut plt := plot.new_plot()
	plt.set_layout(
		title: 'K-Nearest Neighbors'
	)

	x := o.data.x.get_col(0)
	y := o.data.x.get_col(1)

	// Plot data points with different colors for each class
	for i in o.data.y {
		mut x_for_class := []f64{cap: o.data.nb_samples}
		mut y_for_class := []f64{cap: o.data.nb_samples}
		for j in 0 .. o.data.nb_samples {
			if o.data.y[j] == i {
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
				size: []f64{len: x_for_class.len, init: 8.0} // Adjust size as needed
			}
		)
	}

	plt.show()!
}
