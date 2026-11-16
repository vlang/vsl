import vsl.ml

fn main() {
	model := ml.RadiusNeighborsClassifier.new(
		[[0.0, 0.0], [2.0, 1.0], [5.0, 4.0]],
		[0.0, 0.0, 1.0],
		ml.RadiusNeighborsClassifierConfig{
			radius:  2.0
			metric:  .euclidean
			weights: .inverse_distance
		},
	) or { panic(err) }

	queries := [[1.0, 1.0], [5.0, 4.0]]
	predictions := model.predict_batch(queries) or { panic(err) }
	for i, query in queries {
		println('query ${query}: class=${predictions[i]}')
	}
}
