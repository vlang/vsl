# Streaming Gaussian Naive Bayes

This example incrementally trains `GaussianNB` from two batches. Declare every
class on the first call; subsequent batches update the model's sufficient
statistics without retaining their input data. Add
`sample_weights` to `GaussianNBPartialFitConfig` when observations should have
different influence.

Run from `~/.vmodules`:

```sh
v -prod -o /tmp/gaussian_nb_streaming ./vsl/examples/ml_gaussian_nb_streaming/main.v
/tmp/gaussian_nb_streaming
```

Expected output includes classes `[0.0, 1.0]`, equal priors, and a prediction of
`1.0` for the example point.
