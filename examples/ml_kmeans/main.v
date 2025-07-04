module main

import vsl.ml

fn main() {
	// Prepare training data for K-means clustering
	// We create 8 data points representing 2 distinct clusters:
	// - Cluster 1: Points around bottom-left (0.1-0.3, 0.7-0.9)
	// - Cluster 2: Points around top-right (0.7-0.9, 0.1-0.3)
	mut data := ml.Data.from_raw_x([
		// Group 1: Lower-left cluster (should become class 0)
		[0.1, 0.7], // Point 1 in cluster 1
		[0.3, 0.7], // Point 2 in cluster 1
		[0.1, 0.9], // Point 3 in cluster 1
		[0.3, 0.9], // Point 4 in cluster 1
		// Group 2: Upper-right cluster (should become class 1)
		[0.7, 0.1], // Point 1 in cluster 2
		[0.9, 0.1], // Point 2 in cluster 2
		[0.7, 0.3], // Point 3 in cluster 2
		[0.9, 0.3], // Point 4 in cluster 2
	])!

	// Initialize K-means model configuration
	nb_classes := 2 // We expect 2 clusters in our data
	mut model := ml.Kmeans.new(mut data, nb_classes, 'kmeans')

	// Set initial centroid positions manually for this example
	// In practice, these could be randomly initialized or use K-means++
	model.set_centroids([
		// Centroid for class 0 (positioned near first cluster)
		[0.4, 0.6], // Between points in lower-left region
		// Centroid for class 1 (positioned near second cluster)
		[0.6, 0.4], // Between points in upper-right region
	])

	// Step 1: Assign each data point to the nearest centroid
	// This creates initial cluster assignments based on Euclidean distance
	model.find_closest_centroids()

	// Step 2: Recalculate centroid positions based on current assignments
	// Each centroid moves to the mean position of its assigned points
	model.compute_centroids()

	// Run the iterative training process
	// The algorithm alternates between assigning points and updating centroids
	// until convergence or maximum epochs reached
	model.train(epochs: 6)

	// Verify the clustering results against expected classifications
	// We expect points 0-3 to be in class 0, and points 4-7 to be in class 1
	expected_classes := [
		0,
		0,
		0,
		0, // First 4 points should be classified as cluster 0
		1,
		1,
		1,
		1, // Last 4 points should be classified as cluster 1
	]

	// Display the final cluster assignments
	println('K-means clustering results:')
	println('Point -> Cluster Assignment')
	for i, c in model.classes {
		// Verify our expectation matches the algorithm's result
		assert c == expected_classes[i]
		println('Point ${i}: Cluster ${c}')
	}

	println('\nClustering completed successfully! ✅')
}
