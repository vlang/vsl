# Descriptive sample statistics

`stats.summarize` computes count, mean, variance, standard deviation, minimum,
and maximum in one pass using Welford's online moment update.

`ddof: 0` returns population variance; `ddof: 1` returns sample variance. The
input must be non-empty, `ddof` must be in `[0, len)`, and non-finite samples
are rejected rather than propagated or omitted. Variance and standard deviation
are returned as `f64`.

```v
import vsl.stats

summary := stats.summarize([2.0, 4.0, 6.0], 1)!
println('mean=${summary.mean}, sample stddev=${summary.stddev}')
```

This is the first part of the descriptive-statistics coverage tracked in
[VSL issue #559](https://github.com/vlang/vsl/issues/559). Quantiles and
histogram density summaries remain future work.
