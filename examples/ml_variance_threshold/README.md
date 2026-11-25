# Variance Threshold Feature Selection

This example splits a small dataset, fits a `VarianceThreshold` pipeline only
on the training subset, and reuses the fitted feature selection for held-out
rows. A constant column is removed while row order and selected feature names
remain stable.

Run from the V modules directory:

```sh
v run vsl/examples/ml_variance_threshold/main.v
```
