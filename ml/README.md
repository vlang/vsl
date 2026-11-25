# VSL Machine Learning (vsl.ml)

VSL aims to provide a robust set of tools for scientific computing with an emphasis
on performance and ease of use. In the `vsl.ml` module, some machine learning
models are designed as observers of data, meaning they re-train automatically when
data changes, while others do not require this functionality.

## Key Features

- **Observers of Data**: Some machine learning models in VSL act as observers,
  re-training automatically when data changes.
- **High Performance**: Leverages V’s performance optimizations and can integrate
  with C and Fortran libraries like Open BLAS and LAPACK.
- **Versatile Algorithms**: Supports a variety of machine learning algorithms and
  models.

## Usage

### Loading Data

The `Data` struct in `vsl.ml` is designed to hold data in matrix format for machine
learning tasks. Here's a brief overview of how to use it:

#### Creating a Data Object

You can create a `Data` object using the following methods:

- `Data.new`: Creates a new `Data` object with specified dimensions.
- `Data.from_raw_x`: Creates a `Data` object from raw x values (without y values).
- `Data.from_raw_xy`: Creates a `Data` object from raw x and y values combined in a single matrix.
- `Data.from_raw_xy_sep`: Creates a `Data` object from separate x and y raw values.

### Data Methods

The `Data` struct has several key methods to manage and manipulate data:

- `set(x, y)`: Sets the x matrix and y vector and notifies observers.
- `set_y(y)`: Sets the y vector and notifies observers.
- `set_x(x)`: Sets the x matrix and notifies observers.
- `split(ratio)`: Splits the data into two parts based on the given ratio.
- `clone()`: Returns a deep copy of the Data object without observers.
- `clone_with_same_x()`: Returns a deep copy of the Data object but shares the same x reference.
- `add_observer(obs)`: Adds an observer to the data object.
- `notify_update()`: Notifies observers of data changes.

### Stat Observer

The `Stat` struct is an observer of `Data`, providing statistical analysis of the
data it observes. It automatically updates its statistics when the underlying data
changes.

## Observer Models

The following machine learning models in VSL are compatible with the `Observer`
pattern. This means they can observe data changes and automatically update
themselves.

### K-Means Clustering

K-Means Clustering is used for unsupervised learning to group data points into
clusters. As an observer model, it re-trains automatically when the data changes,
which is useful for dynamic datasets that require continuous updates.

### K-Nearest Neighbors (KNN)

K-Nearest Neighbors (KNN) is used for classification tasks where the target
variable is categorical. As an observer model, it re-trains automatically when the
data changes, which is beneficial for datasets that are frequently updated.

### Exact Neighbor Queries

`query_neighbors(training, queries, k, metric)` returns each query row's top-k
training-row indices and distances, ordered by distance and then by original
training index. Euclidean and Manhattan metrics are supported; identical rows
remain distinct neighbors. `KNNRegressor` uses this exact query primitive for
fixed-k regression; it is not an indexed backend.

```v ignore
result := query_neighbors([[0.0, 0.0], [2.0, 1.0]], [[1.0, 1.0]], 1, .euclidean)!
println(result.indices)
println(result.distances)
```

See the [exact neighbor query example](../examples/ml_neighbor_query/README.md).

### K-Nearest Neighbors Regression

`KNNRegressor.new(training, targets, k: 5, metric: .euclidean)` constructs a
fixed-k regressor using `KNNRegressorConfig`; `.euclidean` and `.manhattan`
metrics are supported. Uniform weighting averages selected targets; distance
weighting uses inverse distance, averaging only exact-match targets when any
selected neighbor has zero distance. Use `predict` for one row or
`predict_batch` to preserve the order of multiple query rows.

The constructor requires nonempty, well-formed training data, one finite target
per feature row, and `1 <= k <= training row count`. Queries must match the
training feature width and contain finite values. Because this estimator always
selects `k` neighbors, there is no empty-neighborhood case; radius APIs are out
of scope. See the [KNN regression example](../examples/ml_knn_regression/README.md).

### Logistic Regression

Logistic Regression is used for binary classification tasks. As an observer model,
it automatically updates when data changes, recalculating internal statistics and
preparing for retraining.

### Support Vector Machine (SVM)

Support Vector Machine (SVM) is used for binary classification with support for
non-linear decision boundaries through kernel functions. As an observer model, it
marks itself for retraining when data changes.

### Decision Tree

Decision Tree can handle both classification and regression tasks. As an observer
model, it marks itself for retraining when data changes, allowing the tree to be
rebuilt with new data.

### Random Forest

Random Forest is an ensemble method combining multiple decision trees. As an
observer model, it marks itself for retraining when data changes, allowing the
entire forest to be rebuilt.

### Gaussian Naive Bayes

`GaussianNB` estimates Gaussian feature distributions for each class and
returns class predictions or normalized probabilities. `var_smoothing` times
the largest global feature variance is added to every class-feature variance;
a positive smoothing value also provides a variance floor when all features are
constant. Priors default to observed class frequencies and can be overridden
with `set_priors`.

```v ignore
mut data := Data.from_raw_xy_sep([
    [-2.0, -1.0],
    [-1.0, -1.0],
    [1.0, 1.0],
    [2.0, 1.0],
], [0.0, 0.0, 1.0, 1.0])!
model := GaussianNB.new(mut data, 'gaussian_nb')!
println(model.predict([1.5, 1.0])!)
println(model.predict_proba([1.5, 1.0])!)
```

Use `GaussianNB.new_with_smoothing` to choose a different smoothing value. The
model accepts finite `f64` features and finite numeric labels. Probabilities
follow ascending numeric class order. For streaming data, construct an empty
model with `GaussianNB.new_untrained` and call `partial_fit`; declare the full
class set on the first batch. `GaussianNBPartialFitConfig.sample_weights` can
provide finite non-negative sample weights. Incremental fitting retains only
weighted sufficient statistics, not the input batches; use
`class_weight_sums()` to inspect accumulated weight per class.
See the [streaming GaussianNB example](../examples/ml_gaussian_nb_streaming/README.md)
for a complete two-batch program.

## Logistic Regression JSON Persistence

The current persistence slice is limited to the fitted inference state of
`LogReg[f64]`. Save the schema-versioned JSON artifact with `save_json`, then
load an independent `LogRegArtifact` for prediction without the original
training data:

```v ignore
model.save_json('student_model.json')!
loaded := ml.load_logreg_artifact('student_model.json')!
probability := loaded.predict([3.5, 6.0])!
```

The version-1 artifact contains model/schema identifiers, feature count,
weights, bias, and a non-negative regularization parameter. Decoding validates
the exact field set, supported identifiers/version, feature dimensions, and
finite parameters. It uses JSON data decoding only and does not deserialize
executable code. This does not persist training data, observer state, optimizer
configuration, preprocessing pipelines, other estimators, or provide ONNX
export; it is not a general cross-version persistence contract. Artifacts are
limited to 64 MiB, and oversized JSON is rejected before decoding.

## Non-Observer Models

The following machine learning models in VSL do not require the observer pattern
and are trained once on a dataset without continuous updates.

### Linear Regression

Linear Regression is used for predicting a continuous target variable based on one
or more predictor variables. It is typically trained once on a dataset and used to
make predictions without requiring continuous updates. Hence, it is not implemented
as an observer model.

### Lasso Sample Weights

`Lasso.train_with_sample_weights(sample_weights)` fits the model using finite,
non-negative weights, one per sample. Zero-weight samples are ignored; the
weights must have a positive sum. Passing an empty slice assigns unit weight to
every sample. The data terms use the weights, and the L1 threshold scales with
their sum so integer weights match fitting duplicated observations. The
unweighted `train()` method uses the same solver with unit weights. Both methods
center features using the corresponding sample-weighted means and recover the
intercept from the weighted feature and target means.

See the [weighted Lasso example](../examples/ml_weighted_lasso/README.md) for a
complete program.
