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
	mut model := ml.Kmeans.new_checked(mut data, nb_classes, 'kmeans')!

	// Seeded K-means++ chooses data-backed starting centers reproducibly.
	model.initialize_kmeans_plus_plus(42)!

	// Run the iterative training process
	// The algorithm alternates between assigning points and updating centroids
	// until convergence or maximum epochs reached
	model.train(epochs: 100, tol_norm_change: 1e-8)

	// Verify each group is consistent without relying on arbitrary label order.
	first_group := model.classes[0]
	second_group := model.classes[4]
	assert first_group != second_group

	// Display the final cluster assignments
	println('K-means clustering results:')
	println('Point -> Cluster Assignment')
	for i, c in model.classes {
		assert c == if i < 4 { first_group } else { second_group }
		println('Point ${i}: Cluster ${c}')
	}
	println('Within-cluster sum of squares: ${model.inertia()}')

	println('\nClustering completed successfully! ✅')
}
