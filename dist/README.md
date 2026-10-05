# `vsl.dist`

`vsl.dist` provides histogram binning and text rendering for numeric samples.
`Histogram` stores bin boundaries and counts; boundaries should be supplied in
ascending order.

| API | Purpose |
| --- | --- |
| `Histogram.new(stations)` | Create a histogram from bin boundaries. |
| `find_bin(x)` | Return the matching bin index or an error when outside the range. |
| `count(values, clear)` | Count values, optionally resetting prior counts first. |
| `gen_labels(format)` | Format the bins as display labels. |
| `density_area(nsamples)` | Estimate the normalized area from accumulated counts. |
| `text_hist(labels, counts, barlen)` | Render labeled counts as a text chart. |
| `build_text_hist(...)` | Build a histogram and render it in one call. |

```v
import vsl.dist

mut histogram := dist.Histogram.new([0.0, 1.0, 2.0, 3.0])
histogram.count([0.2, 0.7, 1.4, 2.8], true)!
labels := histogram.gen_labels('%g')!
println(dist.text_hist(labels, histogram.counts, 0)!)
```

See the [histogram example](../examples/dist_histogram/README.md) and
[`hist.v`](hist.v) for formatting and boundary behavior.
