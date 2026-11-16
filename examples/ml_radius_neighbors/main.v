import vsl.ml

fn main() {
	training := [
		[0.0, 0.0],
		[1.0, 0.0],
		[-1.0, 0.0],
		[3.0, 4.0],
	]
	queries := [
		[0.0, 0.0],
		[10.0, 10.0],
	]
	result := ml.radius_neighbors(training, queries, 1.0, .euclidean) or {
		panic(err)
	}

	for i, query in queries {
		println('query ${query}: indices=${result.indices[i]}, distances=${result.distances[i]}')
	}
}
