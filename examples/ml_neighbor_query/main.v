import vsl.ml

fn main() {
	training := [
		[0.0, 0.0],
		[2.0, 1.0],
		[5.0, 4.0],
	]
	queries := [
		[1.0, 1.0],
		[4.0, 3.0],
	]
	result := ml.query_neighbors(training, queries, 2, .euclidean) or { panic(err) }

	for i, query in queries {
		println('query ${query}: indices=${result.indices[i]}, distances=${result.distances[i]}')
	}
}
