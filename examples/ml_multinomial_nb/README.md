# Multinomial Naive Bayes

This example classifies non-negative feature-count vectors with VSL's
`MultinomialNB`. The classifier applies additive smoothing, supports sample
weights, and reports posterior probabilities in sorted class-label order.

Run from the module workspace:

```sh
v run vsl/examples/ml_multinomial_nb/main.v
```

`MultinomialNBConfig.alpha` must be finite and non-negative. Features and
prediction inputs must be finite and non-negative. A class with zero total
feature mass requires positive smoothing.
