# Multinomial Naive Bayes

`MultinomialNB` models the feature counts of each class using a multinomial
distribution. It is suitable for non-negative count and frequency features such
as bag-of-words vectors.

```v ignore
mut data := Data.from_raw_xy_sep([
    [3.0, 0.0],
    [1.0, 1.0],
    [0.0, 3.0],
    [1.0, 2.0],
], [0.0, 0.0, 1.0, 1.0])!
model := MultinomialNB.new_with_config(mut data, 'word_counts',
    MultinomialNBConfig{
        alpha: 1.0
        sample_weights: [1.0, 1.0, 1.0, 1.0]
    })!
println(model.predict([2.0, 0.0])!)
println(model.predict_proba([2.0, 0.0])!)
```

The default `alpha` is `1.0` (Laplace smoothing). A finite non-negative
`alpha` adds the same pseudocount to every class-feature count. Optional
`sample_weights` must be finite, non-negative, and match the training row
count; an empty slice uses unit weights. At least one sample weight must be
positive. The model observes its `Data` object and retrains when it changes.

`classes()`, `class_priors()`, and `feature_log_probabilities()` return values
in ascending class-label order. `predict_log_proba()` normalizes class log
scores with a log-sum-exp calculation, so large feature counts do not require
probability-domain multiplication.

Training and prediction reject non-finite or negative feature values. With
`alpha == 0`, every class must still have positive total feature mass; features
with zero class count have negative-infinite log probability. If a prediction
assigns zero probability to every class, normalization returns an error.
