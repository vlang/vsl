# Regression

VSL includes linear regression and a fixed-k nearest-neighbor regressor.

## K-Nearest Neighbors Regression

Construct `ml.KNNRegressor` from feature rows and one finite target per row.
The default configuration uses `k: 5`, Euclidean distance, and uniform
weighting. Distance weighting uses inverse distance; if selected neighbors
include exact matches, only those targets are averaged.

```v ignore
import vsl.ml

training := [[0.0], [2.0], [4.0]]
targets := [0.0, 20.0, 40.0]
model := ml.KNNRegressor.new(training, targets, k: 2, weighting: .distance)!
prediction := model.predict([1.0])!
batch_predictions := model.predict_batch([[1.0], [3.0]])!
```

`predict_batch` returns results in query order. The estimator requires a
nonempty training set, matching feature and target row counts, a valid `k`,
and finite training targets and query features. Since this estimator always
selects a fixed number of neighbors, it has no empty-neighborhood case;
radius-based APIs are out of scope.

See the [KNN regression example](../../examples/ml_knn_regression/README.md)
for a runnable program.

## Linear Regression

See the [linear regression examples](../../examples/ml_linreg_plot/).

## Next Steps

- [Classification](04-classification.md)
- [Examples](../../examples/) - Working examples

