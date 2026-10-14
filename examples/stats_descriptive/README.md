# Descriptive statistics example

This example combines VSL's one-pass sample summary, Type 7 quantiles, and
NumPy-compatible automatic histogram bin selection.

Run these commands from `~/.vmodules`:

```sh
v -prod -o /tmp/vsl-stats-descriptive ./vsl/examples/stats_descriptive/main.v
/tmp/vsl-stats-descriptive
```

The example reports count, sample mean and standard deviation, extrema, the
25th percentile, selected histogram edges, and counts.
