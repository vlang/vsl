# Weighted Lasso

This example fits a Lasso regression model with a sample weight for each
observation. Finite, non-negative weights scale the squared-error contribution;
zero-weight observations are ignored. Weights are normalized by their positive
sum, and the L1 threshold scales with that sum so integer weights match fitting
duplicated observations. An empty weight slice assigns unit weight to every
observation. The solver centers features by their weighted means and fits the
intercept from the weighted feature and target means.

Run from the repository root with:

```sh
v run examples/ml_weighted_lasso/main.v
```

See the [Lasso sample-weight documentation](../../ml/README.md#lasso-sample-weights).
