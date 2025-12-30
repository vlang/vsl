# 2D Plotting

Learn how to create beautiful 2D plots with VSL's plotting module.

## What You'll Learn

- Creating scatter plots
- Line charts and time series
- Bar charts and histograms
- Customizing plot appearance

## Prerequisites

- [Your First Plot](../getting-started/02-first-plot.md)
- Basic V language knowledge

## Scatter Plots

```v
import vsl.plot
import vsl.util

x := util.arange(10).map(f64(it))
y := x.map(it * it)

mut plt := plot.Plot.new()
plt.scatter(x: x, y: y, mode: 'markers')
plt.show()!
```

## Line Charts

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
plt.line(x: x, y: y, mode: 'lines')
```

## Bar Charts

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
categories := ['A', 'B', 'C']
values := [10.0, 20.0, 15.0]
plt.bar(x: categories, y: values)
```

## Histograms

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
data := [1.0, 2.0, 2.5, 3.0, 3.5, 4.0]
plt.histogram(x: data)
```

## Customization

Colors, markers, sizes, and more can be customized. See examples for details.

## Next Steps

- [3D Visualization](02-3d-visualization.md)
- [Examples](../../examples/plot_scatter/) - Working examples

