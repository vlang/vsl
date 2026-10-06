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

mut data := ml.Data.from_raw_x([[0.0, 1, 2], [0, 2, 3], [10, 9, 8]])!
nb_classes := 3
mut model := ml.Kmeans.new_checked(mut data, nb_classes, 'clustering')!
model.set_centroids_checked([[0.0, 1, 2], [0, 2, 3], [10, 9, 8]])!
model.train(epochs: 100, tol_norm_change: 1e-6)
// Access cluster assignments via model.classes
println('Within-cluster sum of squares: ${model.inertia()}')
```

K-means supports any feature count. `new_checked` reports invalid or empty
datasets; the legacy `new` constructor remains available. Empty clusters keep
their previous centroid, and a positive `tol_norm_change` enables early
stopping based on the total centroid movement.

## Next Steps

- [Regression](03-regression.md)
- [Examples](../../examples/ml_kmeans/) - Working examples
