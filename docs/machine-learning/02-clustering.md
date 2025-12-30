# Clustering

Learn clustering algorithms in VSL.

## What You'll Learn

- K-means clustering
- Data preparation
- Evaluating clusters
- Visualization

## K-Means

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_x([][]f64{})!  // Assume populated
nb_classes := 3
mut model := ml.Kmeans.new(mut data, nb_classes, 'clustering')
model.train(epochs: 10)
// Access cluster assignments via model.classes
```

## Next Steps

- [Regression](03-regression.md)
- [Examples](../../examples/ml_kmeans/) - Working examples

