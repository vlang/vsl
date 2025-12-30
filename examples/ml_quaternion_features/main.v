module main

import vsl.quaternion
import vsl.ml
import vsl.plot
import math

fn main() {
	// Generate synthetic orientation data using quaternions
	// Simulate objects with different orientations
	n_samples := 50

	mut quaternion_data := []quaternion.Quaternion{}
	mut labels := []f64{}

	println('Generating quaternion orientation data...')

	// Create two groups of orientations
	// Group 1: Rotations around x-axis (label 0)
	// Group 2: Rotations around y-axis (label 1)
	for i in 0 .. n_samples {
		if i < n_samples / 2 {
			// Group 1: x-axis rotations
			angle := math.pi * f64(i) / f64(n_samples / 2)
			q := quaternion.from_axis_anglef3(angle, 1.0, 0.0, 0.0)
			quaternion_data << q
			labels << 0.0
		} else {
			// Group 2: y-axis rotations
			angle := math.pi * f64(i - n_samples / 2) / f64(n_samples / 2)
			q := quaternion.from_axis_anglef3(angle, 0.0, 1.0, 0.0)
			quaternion_data << q
			labels << 1.0
		}
	}

	// Extract quaternion components as features
	// Use x, y components as 2D features (Kmeans works with 2D)
	mut feature_matrix := [][]f64{cap: n_samples}
	for q in quaternion_data {
		feature_matrix << [q.x, q.y] // Use 2D for Kmeans compatibility
	}

	println('Extracted ${feature_matrix.len} samples with 2 features each')
	println('Features: [x, y] quaternion components (2D projection)')

	// Prepare data for ML
	mut data := ml.Data.from_raw_xy_sep(feature_matrix, labels)!

	// Split into train and test sets
	mut train_data, test_data := data.split(0.8)!

	println('Training samples: ${train_data.nb_samples}')
	println('Test samples: ${test_data.nb_samples}')

	// Train K-means clustering
	nb_classes := 2
	mut model := ml.Kmeans.new(mut train_data, nb_classes, 'quaternion_kmeans')

	// Initialize centroids (2D)
	model.set_centroids([
		[0.5, 0.0], // Near x-axis rotations
		[0.0, 0.5], // Near y-axis rotations
	])

	model.find_closest_centroids()
	model.compute_centroids()
	model.train(epochs: 10)

	// Get cluster assignments from training
	println('\nClustering Results:')
	println('Classes assigned: ${model.classes}')
	println('Centroids: ${model.centroids}')
	println('Members per class: ${model.nb_members}')

	// Visualize quaternion features
	mut plt := plot.Plot.new()

	// Extract features for visualization (using 2D features)
	mut x_vals := []f64{}
	mut y_vals := []f64{}
	mut colors := []string{}

	for i in 0 .. feature_matrix.len {
		x_vals << feature_matrix[i][0] // x component
		y_vals << feature_matrix[i][1] // y component

		// Color by label
		if labels[i] == 0.0 {
			colors << '#FF0000'
		} else {
			colors << '#0000FF'
		}
	}

	// Plot x vs y components (2D projection)
	plt.scatter(
		x:      x_vals
		y:      y_vals
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: x_vals.len, init: 10.0}
			color: colors
		}
		name:   'Quaternion Features'
	)

	plt.layout(
		title: 'Quaternion Features for ML Clustering'
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'X Component'
			}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Y Component'
			}
		}
	)
	plt.show()!

	println('\nPlot displayed! Red = x-axis rotations, Blue = y-axis rotations')
}
