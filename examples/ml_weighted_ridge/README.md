# Weighted Ridge Regression

This example fits a Ridge regression model with per-sample weights. A zero
weight excludes that training row from the fit.

## Run

From `~/.vmodules`, run:

```sh
v run vsl/examples/ml_weighted_ridge/main.v
```

The program prints the fitted coefficient, intercept, and prediction.
