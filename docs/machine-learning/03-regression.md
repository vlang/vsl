# Regression

Learn linear regression and other regression methods.

## What You'll Learn

- Linear regression
- Model training
- Prediction
- Evaluation

## Linear Regression

```v
import vsl.ml

mut data := ml.Data.from_raw_xy_sep[f64]([[0.0], [1.0], [2.0]], [1.0, 2.0, 4.0])!
mut model := ml.LinReg.new(mut data, 'linreg')
model.train()
prediction := model.predict([1.5])
println(prediction)
```

## Weighted Ridge Regression

`Ridge.train_with_sample_weights` accepts one finite, non-negative weight per
training sample. Zero-weight samples are ignored; an empty weight slice assigns
unit weight to every sample, and the total weight must be positive.

```v
import vsl.ml

mut data := ml.Data.from_raw_xy_sep[f64]([[0.0], [1.0], [2.0]], [1.0, 2.0, 4.0])!
mut model := ml.Ridge.new(mut data, 'weighted_ridge', 0.25)
model.train_with_sample_weights([1.0, 3.0, 0.0])!
println(model.predict([1.5]))
```

## Next Steps

- [Classification](04-classification.md)
- [Examples](../../examples/ml_linreg_plot/) - Working examples

