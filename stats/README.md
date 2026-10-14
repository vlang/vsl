# Descriptive sample statistics

`stats.summarize` computes count, mean, variance, standard deviation, minimum,
and maximum in one pass using Welford's online moment update.

`ddof: 0` returns population variance; `ddof: 1` returns sample variance. The
input must be non-empty, `ddof` must be in `[0, len)`, and non-finite samples
are rejected rather than propagated or omitted. Variance and standard deviation
are returned as `f64`.

`stats.quantile(values, q)` and `stats.percentile(values, p)` sort a copy and
linearly interpolate between adjacent observations (Type 7, the NumPy/SciPy
default). Probabilities must be finite and lie in `[0, 1]` or `[0, 100]`.
Input samples must be finite; the input slice is not modified.

`stats.quantile_weighted(values, weights, q)` and
`stats.percentile_weighted(values, weights, p)` implement NumPy's weighted
inverted-CDF method. Weights must be finite, non-negative, match the sample
length, and have positive total mass. Non-finite sample values are rejected.

```v
import vsl.stats

summary := stats.summarize([2.0, 4.0, 6.0], 1)!
println('mean=${summary.mean}, sample stddev=${summary.stddev}')
```

This is partial descriptive-statistics coverage tracked in
[VSL issue #559](https://github.com/vlang/vsl/issues/559). Alternative quantile
estimators, weighted quantiles, and histogram density summaries remain future
work.
