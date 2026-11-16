# Radius-neighbor classification

`RadiusNeighborsClassifier` predicts from every training row whose distance
from a query is at most the configured radius. Construction accepts feature
rows, one finite numeric class label per row, and a
`RadiusNeighborsClassifierConfig` with a finite non-negative radius, a
`.euclidean` or `.manhattan` metric, and `.uniform` or `.inverse_distance`
voting. The classifier validates and owns copies of its training rows and
labels.

Uniform voting gives each match one vote. Inverse-distance voting sums
distance-based class scores; when one or more exact matches have distance zero,
only those exact matches vote, uniformly. If class scores tie, the numerically
smallest class label wins. A query with no rows in range returns an error
instead of a fallback prediction. Batch predictions keep the query order, and
non-finite or overflowing distances are reported by the underlying radius
query.

```v ignore
model := RadiusNeighborsClassifier.new(
	[[0.0, 0.0], [2.0, 1.0], [5.0, 4.0]],
	[0.0, 0.0, 1.0],
	RadiusNeighborsClassifierConfig{
		radius:  2.0
		metric:  .euclidean
		weights: .inverse_distance
	},
)!
println(model.predict([1.0, 1.0])!)
```

See the [radius-neighbor classifier example](../examples/ml_radius_neighbors_classifier/README.md).

The matching `RadiusNeighborsRegressor` uses the same
`RadiusNeighborsWeighting` options to average numeric targets. See the
[radius-neighbor regression guide](ML_RADIUS_NEIGHBORS_REGRESSOR.md).
