# Data Preparation for ML

Learn how to prepare data for machine learning in VSL.

## What You'll Learn

- Creating Data objects
- Splitting data
- Feature engineering
- Data normalization

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

## Next Steps

- [Clustering](02-clustering.md)
- [Examples](../../examples/ml_kmeans/) - Working examples

