# Regression

Learn linear regression and other regression methods.

## What You'll Learn

- Linear regression
- Model training
- Prediction
- Evaluation

## Linear Regression

```v ignore
import vsl.ml

mut data := ml.Data.from_raw_xy_sep([][]f64{}, []f64{})!  // Assume populated
mut model := ml.LinReg.new(mut data, 'linreg')
model.fit()
// Use model to make predictions (check ML module API for specific prediction methods)
```

## Next Steps

- [Classification](04-classification.md)
- [Examples](../../examples/ml_linreg_plot/) - Working examples

