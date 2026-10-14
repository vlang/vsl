# Descriptive sample statistics

`stats.summarize` computes count, mean, variance, standard deviation, minimum,
and maximum in one pass using Welford's online moment update.

`ddof: 0` returns population variance; `ddof: 1` returns sample variance. The
input must be non-empty, `ddof` must be in `[0, len)`, and non-finite samples
are rejected rather than propagated or omitted. Variance and standard deviation
are returned as `f64`.

`stats.quantile(values, q)` and `stats.percentile(values, p)` sort a copy and
use linear interpolation (Type 7, the NumPy/SciPy default). The
`quantile_with_method` and `percentile_with_method` variants also support all
thirteen estimators exposed by NumPy through `QuantileMethod`, including the
Hyndman-Fan estimators and `lower`, `higher`, `midpoint`, and `nearest`.
The available methods are `inverted_cdf`, `averaged_inverted_cdf`,
`closest_observation`, `interpolated_inverted_cdf`, `hazen`, `weibull`,
`linear`, `median_unbiased`, `normal_unbiased`, `lower`, `higher`, `midpoint`,
and `nearest`.
Probabilities must be finite and lie in `[0, 1]` or `[0, 100]`. Input samples
must be finite; the input slice is not modified.

`stats.quantile_weighted(values, weights, q)` and
`stats.percentile_weighted(values, weights, p)` implement NumPy's weighted
inverted-CDF method. Weights must be finite, non-negative, match the sample
length, and have positive total mass. Non-finite sample values are rejected.

`vsl.dist.WeightedHistogram.count(values, weights, clear)` accumulates
non-negative bin weights and returns the total input weight, including samples
outside the configured range. `density(total_weight)` uses that total for
normalization, so the integrated density is the in-range weight fraction.

```v
import vsl.stats

summary := stats.summarize([2.0, 4.0, 6.0], 1)!
println('mean=${summary.mean}, sample stddev=${summary.stddev}')
```

This is partial descriptive-statistics coverage tracked in
[VSL issue #559](https://github.com/vlang/vsl/issues/559). Automatic histogram
bin selection and configurable non-finite value policies remain future work in
[#575](https://github.com/vlang/vsl/issues/575) and
[#576](https://github.com/vlang/vsl/issues/576), respectively.
Inferential tests and confidence intervals
are tracked separately in [VSL issue #572](https://github.com/vlang/vsl/issues/572).
