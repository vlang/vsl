# Regression

VSL includes linear regression, regularized regression, and fixed-k
nearest-neighbor regression.

## K-Nearest Neighbors Regression

Construct `ml.KNNRegressor` from feature rows and one finite target per row.
The default configuration uses `k: 5`, Euclidean distance, and uniform
weighting. Distance weighting uses inverse distance; if selected neighbors
include exact matches, only those targets are averaged.

```v
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

```v
import vsl.ml

mut data := ml.Data.from_raw_xy_sep[f64]([[0.0], [1.0], [2.0]], [1.0, 2.0, 4.0])!
mut model := ml.LinReg.new(mut data, 'linreg')
model.train()
prediction := model.predict([1.5])
println(prediction)
```

See the [linear regression examples](../../examples/ml_linreg_plot/).

## Weighted Ridge Regression

`Ridge.train_with_sample_weights` accepts one finite, non-negative weight per
training sample. Zero-weight samples are ignored; an empty weight slice assigns
unit weight to every sample, and the total weight must be positive.

```v
import vsl.ml

mut data := ml.Data.from_raw_xy_sep[f64]([[0.0], [1.0], [2.0]], [1.0, 2.0, 4.0])!
mut model := ml.Ridge.new(mut data, 'weighted_ridge', 0.25)
model.train_with_sample_weights([1.0, 3.0, 0.0])!
println(model.predict([1.5]))
```

## Weighted Lasso Regression

`Lasso.train_with_sample_weights` accepts finite, non-negative sample weights.
Zero-weight samples are ignored, an empty slice uses unit weights, and the
total weight must be positive.

See the [weighted Lasso example](../../examples/ml_weighted_lasso/README.md).

## Next Steps

- [Classification](04-classification.md)
- [Examples](../../examples/) - Working examples

