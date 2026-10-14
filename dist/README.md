# `vsl.dist`

`vsl.dist` provides histogram binning, density estimates, and text rendering
for numeric samples. `Histogram` stores finite, strictly increasing bin
boundaries and counts. Bins are left-closed and right-open, except the last bin
includes its right boundary, matching NumPy histogram edge semantics.

| API | Purpose |
| --- | --- |
| `Histogram.new(stations)` | Create a histogram from bin boundaries. |
| `find_bin(x)` | Return the matching bin index, `-1` when outside the range, or an error for invalid edges/NaN. |
| `count(values, clear)` | Count values, optionally resetting prior counts first. |
| `gen_labels(format)` | Format the bins as display labels. |
| `density(nsamples)` | Estimate per-bin density using each bin's width and the total sample count. |
| `density_area(nsamples)` | Integrate the density estimate across all bins. |
| `text_hist(labels, counts, barlen)` | Render labeled counts as a text chart. |
| `build_text_hist(...)` | Build a histogram and render it in one call. |

```v
import vsl.dist

mut histogram := dist.Histogram.new([0.0, 1.0, 2.0, 3.0])
histogram.count([0.2, 0.7, 1.4, 2.8], true)!
labels := histogram.gen_labels('%g')!
println(dist.text_hist(labels, histogram.counts, 0)!)
println(histogram.density(4)!)
```

For non-uniform bins, each density is `count / (sample_count * bin_width)`.
Values outside the bin range still contribute to `sample_count`; therefore
`density_area` is the fraction of samples that fell within the histogram range.

See the [histogram example](../examples/dist_histogram/README.md) and
[`hist.v`](hist.v) for formatting and boundary behavior.
