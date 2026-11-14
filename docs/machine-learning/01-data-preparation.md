# Data Preparation for ML

Learn how to prepare data for machine learning in VSL.

## What You'll Learn

- Creating Data objects
- Splitting data
- Feature engineering
- Data normalization
- Missing-value imputation

## Creating Data

```v ignore
import vsl.ml

x_matrix := [][]f64{}  // Assume populated
y_vector := []f64{}    // Assume populated
mut data := ml.Data.from_raw_xy_sep(x_matrix, y_vector)!
```

## Splitting Data

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_xy_sep([][]f64{}, []f64{})!  // Assume populated
mut train_data, test_data := data.split(0.8)!
println('Training samples: ${train_data.nb_samples}')
println('Test samples: ${test_data.nb_samples}')
```

## Missing-Value Imputation

Fit the imputer on training data, then reuse the learned replacement values
for inference data. Only NaN values are considered missing.

```v
import math
import vsl.preprocessing

missing := math.nan()
training := [[1.0, missing], [3.0, 4.0]]
mut imputer := preprocessing.SimpleImputer.new(.mean, 0.0)
_ := imputer.fit_transform(training)!

inference := imputer.transform([[missing, 10.0]])!
assert inference == [[2.0, 10.0]]
```

Mean and median strategies return an error for a feature with no observed
training values. Use `.constant` to fill even an all-missing feature.

## Next Steps

- [Clustering](02-clustering.md)
- [Examples](../../examples/ml_kmeans/) - Working examples

