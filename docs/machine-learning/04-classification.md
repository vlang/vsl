# Classification

Learn classification algorithms in VSL.

## What You'll Learn

- K-Nearest Neighbors
- Classification metrics
- Model evaluation

## KNN

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_x([][]f64{})!  // Assume populated
mut model := ml.KNN.new(mut data, 'knn_model')
model.fit()
// Use model to make predictions (check ML module API for specific prediction methods)
```

## Next Steps

- [Examples](../../examples/ml_knn_plot/) - Working examples

