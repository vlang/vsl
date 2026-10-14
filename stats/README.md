# Descriptive sample statistics

`stats.summarize` computes count, mean, variance, standard deviation, minimum,
and maximum in one pass using Welford's online moment update.

`ddof: 0` returns population variance; `ddof: 1` returns sample variance. The
input must be non-empty and `ddof` must be valid for the observations used.
The existing API rejects non-finite samples. `summarize_with_policy` accepts
`NonFinitePolicy.reject`, `.omit`, or `.propagate`: omission updates the count
and degrees of freedom using finite values only; propagation returns NaN for
numeric summary statistics when any sample is non-finite, while count reports
the input length. Variance and standard deviation are returned as `f64`.

`stats.quantile(values, q)` and `stats.percentile(values, p)` sort a copy and
use linear interpolation (Type 7, the NumPy/SciPy default). The
`quantile_with_method` and `percentile_with_method` variants also support all
thirteen estimators exposed by NumPy through `QuantileMethod`, including the
Hyndman-Fan estimators and `lower`, `higher`, `midpoint`, and `nearest`.
The available methods are `inverted_cdf`, `averaged_inverted_cdf`,
`closest_observation`, `interpolated_inverted_cdf`, `hazen`, `weibull`,
`linear`, `median_unbiased`, `normal_unbiased`, `lower`, `higher`, `midpoint`,
and `nearest`.
Probabilities must be finite and lie in `[0, 1]` or `[0, 100]`. Existing
quantile APIs reject non-finite samples and do not modify the input slice.
`quantile_with_policy`, `percentile_with_policy`, and their method variants
accept the same policies: `.omit` filters non-finite samples, while
`.propagate` returns NaN if any sample is non-finite.

`stats.quantile_weighted(values, weights, q)` and
`stats.percentile_weighted(values, weights, p)` implement NumPy's weighted
inverted-CDF method. Weights must be non-negative, match the sample length,
and have positive finite total mass. The existing APIs reject non-finite values
and weights. Policy variants omit any pair with a non-finite value or weight;
propagation returns NaN for non-finite positive-mass values and rejects
non-finite weights because their contribution is undefined. Finite negative
weights remain invalid under every policy.

`vsl.dist.WeightedHistogram.count(values, weights, clear)` accumulates
non-negative bin weights and returns the total input weight, including samples
outside the configured range. `density(total_weight)` uses that total for
normalization, so the integrated density is the in-range weight fraction.
The histogram `count_with_policy` and automatic-bin `*_with_policy` variants
can omit non-finite observations. Since integer counts and bin-edge selection
cannot meaningfully propagate NaN, their `.propagate` policy returns an error
when a non-finite sample is present. Existing histogram calls retain their
previous behavior.
`vsl.dist.histogram_bin_edges(values, rule)` selects edges with NumPy's
`auto`, `fd`, `doane`, `scott`, `stone`, `rice`, `sturges`, or `sqrt` rule.
Use `histogram_bin_edges_in_range` to select edges over an explicit interval.

```v
import math
import vsl.stats

summary := stats.summarize([2.0, 4.0, 6.0], 1)!
println('mean=${summary.mean}, sample stddev=${summary.stddev}')

sample := [1.0, math.nan(), 3.0]
finite_summary := stats.summarize_with_policy(sample, 0, .omit)!
propagated_median := stats.quantile_with_policy(sample, 0.5, .propagate)!
println('finite count=${finite_summary.count}, propagated median=${propagated_median}')
```

See the runnable [descriptive statistics example](../examples/stats_descriptive/README.md)
for summaries, quantiles, and automatic histogram bins. Inferential tests and confidence intervals
are tracked separately in [VSL issue #572](https://github.com/vlang/vsl/issues/572).
