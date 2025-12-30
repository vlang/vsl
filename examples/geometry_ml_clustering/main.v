module main

import vsl.gm
import vsl.ml
import vsl.plot
import rand

fn main() {
	// Generate 3D points using geometry module
	n_samples := 60

	mut points := []gm.Point{cap: n_samples}
	mut labels := []f64{cap: n_samples}

	println('Generating 3D geometric data...')

	// Seed random number generator
	rand.seed([u32(12345), u32(67890)])

	// Create two clusters in 3D space
	// Cluster 1: Points around (0, 0, 0)
	// Cluster 2: Points around (3, 3, 3)
	for i in 0 .. n_samples {
		if i < n_samples / 2 {
			// Cluster 1
			x := (rand.f64() - 0.5) * 2.0
			y := (rand.f64() - 0.5) * 2.0
			z := (rand.f64() - 0.5) * 2.0
			points << gm.Point.new(x, y, z)
			labels << 0.0
		} else {
			// Cluster 2
			x := 3.0 + (rand.f64() - 0.5) * 2.0
			y := 3.0 + (rand.f64() - 0.5) * 2.0
			z := 3.0 + (rand.f64() - 0.5) * 2.0
			points << gm.Point.new(x, y, z)
			labels << 1.0
		}
	}

	println('Generated ${points.len} 3D points')

	// Convert geometry points to feature matrix for ML
	// Use 2D projection (x, y) for Kmeans compatibility
	mut feature_matrix := [][]f64{cap: points.len}
	for p in points {
		feature_matrix << [p.x, p.y] // 2D projection
	}

	// Prepare data for ML
	mut data := ml.Data.from_raw_xy_sep(feature_matrix, labels)!

	// Split into train and test
	mut train_data, test_data := data.split(0.8)!

	println('Training samples: ${train_data.nb_samples}')
	println('Test samples: ${test_data.nb_samples}')

	// Train K-means clustering
	nb_classes := 2
	mut model := ml.Kmeans.new(mut train_data, nb_classes, 'geometry_kmeans')

	// Initialize centroids (2D)
	model.set_centroids([
		[0.0, 0.0], // Near cluster 1
		[3.0, 3.0], // Near cluster 2
	])

	model.find_closest_centroids()
	model.compute_centroids()
	model.train(epochs: 10)

	println('\nClustering Results:')
	println('Classes assigned: ${model.classes}')
	println('Centroids: ${model.centroids}')
	println('Members per class: ${model.nb_members}')

	// Visualize in 3D
	mut x_coords := []f64{}
	mut y_coords := []f64{}
	mut z_coords := []f64{}
	mut colors := []string{}

	// Use original 3D points for visualization
	for i in 0 .. points.len {
		x_coords << points[i].x
		y_coords << points[i].y
		z_coords << points[i].z

		// Color by true label
		if labels[i] == 0.0 {
			colors << '#FF0000'
		} else {
			colors << '#0000FF'
		}
	}

	// Plot clusters in 3D
	mut plt := plot.Plot.new()
	plt.scatter3d(
		x:      x_coords
		y:      y_coords
		z:      z_coords
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: x_coords.len, init: 10.0}
			color: colors
		}
		name:   '3D Clusters'
	)

	// Add centroids (projected to 3D by adding z=0)
	centroids := model.centroids
	mut centroid_x := []f64{}
	mut centroid_y := []f64{}
	mut centroid_z := []f64{}

	for c in centroids {
		centroid_x << c[0]
		centroid_y << c[1]
		centroid_z << 0.0 // Add z=0 for 3D visualization
	}

	plt.scatter3d(
		x:      centroid_x
		y:      centroid_y
		z:      centroid_z
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: centroid_x.len, init: 20.0}
			color: []string{len: centroid_x.len, init: '#00FF00'}
		}
		name:   'Centroids'
	)

	plt.layout(
		title: '3D Geometric Clustering (Geometry + ML) - 2D Clustering on 3D Data'
	)
	plt.show()!

	println('\nPlot displayed!')
	println('Red = Cluster 1, Blue = Cluster 2, Green Diamonds = Centroids')
}
