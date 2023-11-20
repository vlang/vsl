module ml

import math
import vsl.gm
import vsl.la
import vsl.plot

// Kmeans implements the K-means model (Observer of Data)
@[heap]
pub struct Kmeans {
mut:
	name       string     // name of this "observer"
	data       &Data[f64] // x data
	stat       &Stat[f64] // statistics about x (data)
	nb_classes int        // expected number of classes
	bins       &gm.Bins   // "bins" to speed up searching for data points given their coordinates (2D or 3D only at the moment)
	nb_iter    int        // number of iterations
pub mut:
	classes    []int   // [nb_samples] indices of classes of each sample
	centroids  [][]f64 // [nb_classes][nb_features] coordinates of centroids
	nb_members []int   // [nb_classes] number of members in each class
}

// Kmeans.new returns a new K-means model
pub fn Kmeans.new(mut data Data[f64], nb_classes int, name string) &Kmeans {
	// classes
	classes := []int{len: data.nb_samples}
	centroids := [][]f64{len: nb_classes}
	nb_members := []int{len: nb_classes}

	// stat
	mut stat := Stat.from_data(mut data, 'stat_${name}')
	stat.update()

	// bins
	ndiv := [10, 10] // TODO: make this a parameter
	bins := gm.Bins.new(stat.min_x, stat.max_x, ndiv) // TODO: make sure minx and maxx are 2D or 3D; i.e. nb_features ≤ 2
	mut o := Kmeans{
		name: name
		data: data
		stat: stat
		nb_classes: nb_classes
		classes: classes
		centroids: centroids
		nb_members: nb_members
		bins: bins
	}
	data.add_observer(o) // need to recompute bins upon data changes
	o.update() // compute first bins
	return &o
}

// name returns the name of this Kmeans object (thus defining the Observer interface)
pub fn (o &Kmeans) name() string {
	return o.name
}

// update perform updates after data has been changed (as an Observer)
pub fn (mut o Kmeans) update() {
	for i in 0 .. o.data.nb_samples {
		o.bins.append([o.data.x.get(i, 0), o.data.x.get(i, 1)], i, unsafe { nil })
	}
}

// nb_classes returns the number of classes
pub fn (o &Kmeans) nb_classes() int {
	return o.nb_classes
}

// set_centroids sets centroids; e.g. trial centroids
//   xc -- [nb_class][nb_features]
pub fn (mut o Kmeans) set_centroids(xc [][]f64) {
	for i := 0; i < o.nb_classes; i++ {
		o.centroids[i] = xc[i].clone()
	}
}

// find_closest_centroids finds closest centroids to each sample
pub fn (mut o Kmeans) find_closest_centroids() {
	// loop over all samples
	mut del := []f64{len: o.data.nb_features}
	for i := 0; i < o.data.nb_samples; i++ {
		// set min distance to max value possible
		mut dist_min := math.max_f64
		xi := o.data.x.get_row(i)
		// for each class
		for j := 0; j < o.nb_classes; j++ {
			xc := o.centroids[j]
			del = la.vector_add(1.0, xi, -1.0, xc) // del := xi - xc
			dist := la.vector_norm(del)
			if dist < dist_min {
				dist_min = dist
				o.classes[i] = j
			}
		}
	}
}

// compute_centroids update centroids based on new classes information (from find_closest_centroids)
pub fn (mut o Kmeans) compute_centroids() {
	// clear centroids and number of nb_members
	for k := 0; k < o.nb_classes; k++ {
		o.centroids[k] = []f64{len: o.centroids[k].len}
		o.nb_members[k] = 0
	}
	// add contributions to centroids and nb_members
	for i := 0; i < o.data.nb_samples; i++ {
		xi := o.data.x.get_row(i)
		k := o.classes[i]
		o.centroids[k] = la.vector_add(1.0, o.centroids[k], 1.0, xi)
		o.nb_members[k]++
	}
	// scale centroids based on number of members
	for k := 0; k < o.nb_classes; k++ {
		den := f64(o.nb_members[k])
		for j := 0; j < o.data.nb_features; j++ {
			o.centroids[k][j] /= den
		}
	}
}

pub struct TrainConfig {
	epochs          int
	tol_norm_change f64
}

// train trains model
pub fn (mut o Kmeans) train(config TrainConfig) {
	mut nb_iter := 0
	for nb_iter < config.epochs {
		o.find_closest_centroids()
		o.compute_centroids()
		nb_iter++
	}
	o.nb_iter = o.nb_iter + nb_iter
}

// str is a custom str function for observers to avoid printing data
pub fn (o &Kmeans) str() string {
	mut res := []string{}
	res << 'vsl.ml.Kmeans{'
	res << '	name: ${o.name}'
	res << '    nb_classes: ${o.nb_classes}'
	res << '    bins: ${o.bins}'
	res << '    classes: ${o.classes}'
	res << '    centroids: ${o.centroids}'
	res << '    nb_members: ${o.nb_members}'
	res << '}'
	return res.join('\n')
}

// get_plotter returns a plot.Plot struct for plotting
pub fn (o &Kmeans) get_plotter() &plot.Plot {
	mut plt := plot.Plot.new()
	plt.layout(
		title: 'K-means Clustering'
	)

	x := o.data.x.get_col(0)
	y := o.data.x.get_col(1)

	// Plot data points with different colors for each class
	for i in 0 .. o.nb_classes {
		mut x_for_class := []f64{}
		mut y_for_class := []f64{}
		for j in 0 .. o.data.nb_samples {
			if o.classes[j] == i {
				x_for_class << x[j]
				y_for_class << y[j]
			}
		}

		plt.scatter(
			name: 'class #${i}'
			x: x_for_class
			y: y_for_class
			mode: 'markers'
			colorscale: 'smoker'
			marker: plot.Marker{
				size: []f64{len: x_for_class.len, init: 8.0} // Adjust size as needed
			}
		)
	}

	// Plot centroids
	plt.scatter(
		name: 'centroids'
		x: o.centroids.map(it[0])
		y: o.centroids.map(it[1])
		mode: 'markers'
		colorscale: 'smoker'
		marker: plot.Marker{
			size: []f64{len: o.centroids.len, init: 12.0} // Adjust size as needed
		}
	)

	return plt
}
