# Statistical Charts

Create statistical visualizations with VSL.

## What You'll Learn

- Box plots
- Violin plots
- Histograms
- Distribution charts

## Box Plots

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
data := []f64{}  // Assume populated
plt.box(y: data, name: 'Distribution')
```

## Violin Plots

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
data := []f64{}  // Assume populated
plt.violin(y: data, name: 'Distribution')
```

## Histograms

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
data := []f64{}  // Assume populated
plt.histogram(x: data)
```

## Next Steps

- [Examples](../../examples/plot_box_statistics/) - Working examples

