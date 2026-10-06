module ml

import math
import vsl.plot

// Kmeans implements the K-means model (Observer of Data)

// Kmeans defines a public data structure for this module.

// Kmeans defines a public data structure for this module.
@[heap]
pub struct Kmeans {
mut:
	name       string // name of this "observer"
	data       &Data[f64] = unsafe { nil } // x data
	nb_classes int // expected number of classes
	nb_iter    int // number of iterations
pub mut:
	classes    []int   // [nb_samples] indices of classes of each sample
	centroids  [][]f64 // [nb_classes][nb_features] coordinates of centroids
	nb_members []int   // [nb_classes] number of members in each class
}

// Kmeans.new returns a new K-means model
pub fn Kmeans.new(mut data Data[f64], nb_classes int, name string) &Kmeans {
	// classes
	classes := []int{len: data.nb_samples}
	nb_members := []int{len: nb_classes}

	mut centroids := [][]f64{len: nb_classes}
	for i in 0 .. nb_classes {
		centroids[i] = []f64{len: data.nb_features}
	}
	mut o := Kmeans{
		name:       name
		data:       data
		nb_classes: nb_classes
		classes:    classes
		centroids:  centroids
		nb_members: nb_members
	}
	data.add_observer(o)
	o.update()
	return &o
}

// new_checked validates dimensions and class count before creating a model.
pub fn Kmeans.new_checked(mut data Data[f64], nb_classes int, name string) !&Kmeans {
	if data.nb_features == 0 || data.nb_samples == 0 {
		return error('K-means requires non-empty samples and features')
	}
	if nb_classes <= 0 || nb_classes > data.nb_samples {
		return error('K-means class count must be between 1 and the sample count')
	}
	return Kmeans.new(mut data, nb_classes, name)
}

// name returns the name of this Kmeans object (thus defining the Observer interface)
pub fn (o &Kmeans) name() string {
	return o.name
}

// update resets assignments after the observed data changes.
pub fn (mut o Kmeans) update() {
	o.classes = []int{len: o.data.nb_samples}
	o.nb_members = []int{len: o.nb_classes}
	mut dimensions_match := o.centroids.len == o.nb_classes
	if dimensions_match {
		for centroid in o.centroids {
			if centroid.len != o.data.nb_features {
				dimensions_match = false
				break
			}
		}
	}
	if !dimensions_match {
		o.centroids = [][]f64{len: o.nb_classes}
		for i in 0 .. o.nb_classes {
			o.centroids[i] = []f64{len: o.data.nb_features}
		}
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

// set_centroids_checked validates centroid count and feature dimensions.
pub fn (mut o Kmeans) set_centroids_checked(xc [][]f64) ! {
	if xc.len != o.nb_classes {
		return error('centroid count must equal the configured class count')
	}
	for centroid in xc {
		if centroid.len != o.data.nb_features {
			return error('each centroid must match the dataset feature count')
		}
	}
	o.set_centroids(xc)
}

// initialize_kmeans_plus_plus selects initial centroids with the K-means++
// distance-weighted strategy. The explicit seed keeps the operation
// reproducible without changing V's process-global random generator.
pub fn (mut o Kmeans) initialize_kmeans_plus_plus(seed u64) ! {
	if o.data.nb_samples == 0 || o.data.nb_features == 0 {
		return error('K-means++ requires non-empty samples and features')
	}
	if o.nb_classes <= 0 || o.nb_classes > o.data.nb_samples {
		return error('K-means++ class count must be between 1 and the sample count')
	}
	mut state := if seed == 0 { u64(1) } else { seed }
	next_state, first_random := kmeans_next_random(state)
	state = next_state
	mut centroids := [][]f64{cap: o.nb_classes}
	centroids << o.data.x.get_row(int(first_random % u64(o.data.nb_samples)))
	mut min_distances := []f64{len: o.data.nb_samples, init: math.max_f64}
	for _ in 1 .. o.nb_classes {
		last_centroid := centroids[centroids.len - 1]
		mut distance_sum := 0.0
		for sample in 0 .. o.data.nb_samples {
			mut distance := 0.0
			for feature in 0 .. o.data.nb_features {
				delta := o.data.x.get(sample, feature) - last_centroid[feature]
				distance += delta * delta
			}
			if distance < min_distances[sample] {
				min_distances[sample] = distance
			}
			distance_sum += min_distances[sample]
		}
		mut selected := 0
		if distance_sum == 0 {
			zero_next_state, random := kmeans_next_random(state)
			state = zero_next_state
			selected = int(random % u64(o.data.nb_samples))
		} else {
			weighted_next_state, random := kmeans_next_random(state)
			state = weighted_next_state
			threshold := f64(random & u64(0x1fffffffffffff)) / 9007199254740992.0 * distance_sum
			mut cumulative := 0.0
			selected = o.data.nb_samples - 1
			for sample, distance in min_distances {
				cumulative += distance
				if cumulative > threshold {
					selected = sample
					break
				}
			}
		}
		centroids << o.data.x.get_row(selected)
	}
	o.set_centroids(centroids)
}

fn kmeans_next_random(state u64) (u64, u64) {
	mut next := state
	next = next ^ (next << 13)
	next = next ^ (next >> 7)
	next = next ^ (next << 17)
	return next, next
}

// find_closest_centroids finds closest centroids to each sample
pub fn (mut o Kmeans) find_closest_centroids() {
	if o.nb_classes == 0 || o.data.nb_features == 0 {
		return
	}
	for i := 0; i < o.data.nb_samples; i++ {
		mut dist_min := math.max_f64
		mut closest := 0
		for j := 0; j < o.nb_classes; j++ {
			mut dist := 0.0
			for feature in 0 .. o.data.nb_features {
				delta := o.data.x.get(i, feature) - o.centroids[j][feature]
				dist += delta * delta
			}
			if dist < dist_min {
				dist_min = dist
				closest = j
			}
		}
		o.classes[i] = closest
	}
}

// compute_centroids update centroids based on new classes information (from find_closest_centroids)
pub fn (mut o Kmeans) compute_centroids() {
	previous_centroids := o.centroids.map(it.clone())
	// Clear sums and member counts before accumulating the new assignment.
	for k := 0; k < o.nb_classes; k++ {
		o.centroids[k] = []f64{len: o.centroids[k].len}
		o.nb_members[k] = 0
	}
	// add contributions to centroids and nb_members
	for i := 0; i < o.data.nb_samples; i++ {
		k := o.classes[i]
		if k < 0 || k >= o.nb_classes {
			continue
		}
		for feature in 0 .. o.data.nb_features {
			o.centroids[k][feature] += o.data.x.get(i, feature)
		}
		o.nb_members[k]++
	}
	// Keep the previous centroid for empty clusters instead of producing NaNs.
	for k := 0; k < o.nb_classes; k++ {
		if o.nb_members[k] == 0 {
			o.centroids[k] = previous_centroids[k]
			continue
		}
		den := f64(o.nb_members[k])
		for j := 0; j < o.data.nb_features; j++ {
			o.centroids[k][j] /= den
		}
	}
}

// TrainConfig defines a public data structure for this module.
pub struct TrainConfig {
pub:
	epochs          int
	tol_norm_change f64
}

// train runs at most epochs iterations. A positive tol_norm_change stops when
// the Euclidean norm of the centroid update is small enough.
pub fn (mut o Kmeans) train(config TrainConfig) {
	mut nb_iter := 0
	for nb_iter < config.epochs {
		previous_centroids := o.centroids.map(it.clone())
		o.find_closest_centroids()
		o.compute_centroids()
		nb_iter++
		if config.tol_norm_change > 0 {
			mut squared_change := 0.0
			for cluster, centroid in o.centroids {
				for feature, value in centroid {
					delta := value - previous_centroids[cluster][feature]
					squared_change += delta * delta
				}
			}
			if math.sqrt(squared_change) <= config.tol_norm_change {
				break
			}
		}
	}
	o.nb_iter = o.nb_iter + nb_iter
}

// inertia returns the sum of squared distances from samples to their assigned
// centroids. Call find_closest_centroids after changing centroids or data.
pub fn (o &Kmeans) inertia() f64 {
	mut total := 0.0
	for sample, cluster in o.classes {
		if cluster < 0 || cluster >= o.centroids.len {
			continue
		}
		for feature in 0 .. o.data.nb_features {
			delta := o.data.x.get(sample, feature) - o.centroids[cluster][feature]
			total += delta * delta
		}
	}
	return total
}

// str is a custom str function for observers to avoid printing data
pub fn (o &Kmeans) str() string {
	mut res := []string{}
	res << 'vsl.ml.Kmeans{'
	res << '	name: ${o.name}'
	res << '    nb_classes: ${o.nb_classes}'
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
			name:       'class #${i}'
			x:          x_for_class
			y:          y_for_class
			mode:       'markers'
			colorscale: 'smoker'
			marker:     plot.Marker{
				size: []f64{len: x_for_class.len, init: 8.0} // Adjust size as needed
			}
		)
	}

	// Plot centroids
	plt.scatter(
		name:       'centroids'
		x:          o.centroids.map(it[0])
		y:          o.centroids.map(it[1])
		mode:       'markers'
		colorscale: 'smoker'
		marker:     plot.Marker{
			size: []f64{len: o.centroids.len, init: 12.0} // Adjust size as needed
		}
	)

	return plt
}
