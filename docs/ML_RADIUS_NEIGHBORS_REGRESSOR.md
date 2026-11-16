# Radius-neighbor regression

`RadiusNeighborsRegressor` predicts a numeric target by averaging every
training target whose feature row is within the configured radius. Its
`RadiusNeighborsRegressorConfig` takes a finite non-negative `radius`, a
`.euclidean` or `.manhattan` metric, and `.uniform` or `.inverse_distance`
`RadiusNeighborsWeighting`. Construction validates and deep-copies finite
feature rows and targets.

Uniform weighting gives each matching row equal influence. Inverse-distance
weighting uses the reciprocal of each distance, normalized internally to avoid
overflow. If any matching rows have exactly zero distance, only those rows are
used and their targets are averaged uniformly. An empty neighborhood, invalid
query, or non-finite/overflowing distance returns an error. Batch predictions
retain query order.

The averaging implementation scales targets and weights before accumulation,
so large finite target magnitudes and tiny positive distances do not overflow
intermediate sums. A non-finite intermediate or result is returned as an
explicit error.

```v ignore
model := RadiusNeighborsRegressor.new(
	[[0.0, 0.0], [2.0, 1.0], [5.0, 4.0]],
	[1.5, 3.0, 8.0],
	RadiusNeighborsRegressorConfig{
		radius:  2.0
		metric:  .euclidean
		weights: .inverse_distance
	},
)!
println(model.predict([1.0, 1.0])!)
```

See the [radius-neighbor regressor example](../examples/ml_radius_neighbors_regressor/README.md).
