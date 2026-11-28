module ml

import vsl.plot

fn test_kmeans_implements_plottable() {
	mut data := Data.from_raw_x([
		[0.1, 0.7],
		[0.3, 0.8],
		[0.7, 0.2],
		[0.9, 0.3],
	])!
	mut model := Kmeans.new(mut data, 2, 'kmeans')
	model.set_centroids_checked([[0.2, 0.75], [0.8, 0.25]])!
	model.find_closest_centroids()

	plt := plot.render(model)
	assert plt.layout.title == 'K-means Clustering'
	assert plt.traces.len >= 2
}

fn test_knn_implements_plottable() {
	mut data := Data.from_raw_xy_sep([
		[0.1, 0.7],
		[0.3, 0.8],
		[0.7, 0.2],
		[0.9, 0.3],
	], [f64(0.0), 0.0, 1.0, 1.0])!
	mut model := KNN.new(mut data, 'knn')!

	plt := plot.render(model)
	assert plt.layout.title == 'K-Nearest Neighbors'
	assert plt.traces.len >= 2
}

fn test_linreg_implements_plottable() {
	mut data := Data.from_raw_xy_sep([[0.1], [0.3], [0.6], [0.9]], [f64(1.0), 2.0, 3.0, 4.0])!
	mut model := LinReg.new(mut data, 'linreg')

	plt := plot.render(model)
	assert plt.layout.title == 'Linear Regression Example'
	assert plt.traces.len == 2
}

fn test_logreg_implements_plottable() {
	mut data := Data.from_raw_xy_sep([[0.1], [0.3], [0.6], [0.9]], [f64(0.0), 0.0, 1.0, 1.0])!
	mut model := LogReg.new(mut data, 'logreg')

	plt := plot.render(model)
	assert plt.layout.title.len > 0
	assert plt.traces.len > 0
}
