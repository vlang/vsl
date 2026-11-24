# Sample Weights for Binary Logistic Regression

`LogRegTrainConfig.sample_weights` lets you give each training row a
non-negative importance weight:

```v ignore
model.train(
	epochs: 1000
	learning_rate: 0.1
	sample_weights: [1.0, 3.0, 1.0, 3.0]
)
```

The slice must contain exactly one weight per sample. Every value must be
finite and non-negative, and the total must be finite and greater than zero.
An invalid slice causes the existing `LogReg` API to panic with a VSL
`einval` error; invalid input is not replaced with unit weights. An empty slice
(the default) gives every sample weight `1.0`, preserving the usual mean loss.

The data loss, gradient, and Hessian are normalized by the sum of weights:

```text
J = Σᵢ wᵢ · cross_entropyᵢ / Σᵢ wᵢ
    + λ · Σⱼ θⱼ² / (2 · Σᵢ wᵢ)
```

Thus a zero-weight row is ignored, and integer weights have the same effect as
repeating rows. The L2 term uses the same denominator. The configured weights
remain in effect for `cost()`, `gradients()`, and `hessian()` after training.
If an observed data update changes the sample count, positional weights are
cleared and the model returns to unit weights; updates that preserve the row
count retain the existing weights.

For data loss and derivatives, each row is scaled by its fraction
`wᵢ / Σw` before its contribution is accumulated. This avoids overflowing an
intermediate weighted sum for large finite weights and supports positive
subnormal weights. L2 regularization is not rescaled this way: it retains the
documented `λ / Σw` derivative/Hessian coefficient (and half that coefficient
in the objective). If that coefficient cannot be represented as a finite,
nonzero `f64`, `cost()`, `gradients()`, and `hessian()` panic with a VSL
`einval` error instead of returning corrupted values. With `λ = 0`, even very
large or subnormal positive weights remain supported.

Run the worked example from the V modules directory:

```sh
v run vsl/examples/ml_logreg_sample_weights/main.v
```

The example source is in
[`examples/ml_logreg_sample_weights/main.v`](../../examples/ml_logreg_sample_weights/main.v).
