# 3D Scatter Plot Example

This example demonstrates how to create interactive 3D scatter plots using VSL's plotting module.

## What You'll Learn

- Creating 3D scatter plots with VSL
- Using `scatter3d()` function
- Customizing 3D plot appearance (colors, markers, lines)
- Understanding 3D data visualization

## Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- No additional system dependencies required

## Running the Example

```sh
# Navigate to this directory
cd examples/plot_scatter3d_1

# Run the example
v run main.v
```

## Expected Output

The example generates an interactive 3D plot showing:

- **3D scatter points**: Points plotted in 3D space with connecting lines
- **Interactive controls**: Rotate, zoom, and pan the 3D view
- **Custom styling**: Blue markers and lines connecting the points

## Code Walkthrough

### 1. Data Preparation

```v
import vsl.util

y := [0.0, 1, 3, 1, 0, -1, -3, -1, 0, 1, 3, 1, 0]
x := util.arange(y.len)
z := util.arange(y.len).map(util.arange(y.len).map(f64(it * it)))
```

The example creates:
- `y`: A wavy pattern of values
- `x`: Sequential indices
- `z`: 2D array flattened to 1D (represents z-coordinates)

### 2. Creating the 3D Plot

```v ignore
import vsl.plot
import vsl.util

x := util.arange(13).map(f64(it))
y := [0.0, 1, 3, 1, 0, -1, -3, -1, 0, 1, 3, 1, 0]
z := util.arange(y.len).map(util.arange(y.len).map(f64(it * it)))

mut plt := plot.Plot.new()
plt.scatter3d(
    x: x
    y: y
    z: z
    mode: 'lines+markers'
    marker: plot.Marker{size: []f64{len: x.len, init: 10.0}, color: []string{len: x.len, init: '#0000FF'}}
    line: plot.Line{color: '#0000FF'}
)
```

The `scatter3d()` function creates a 3D scatter plot with:
- Markers at each point
- Lines connecting the points
- Custom colors and sizes

### 3. Layout Configuration

```v
import vsl.plot

mut plt := plot.Plot.new()
// ... add traces ...
plt.layout(title: 'Scatter plot example')
plt.show()!
```

Sets the plot title and other layout properties.

## Mathematical Background

3D scatter plots visualize data points in three-dimensional space:
- **X-axis**: First dimension
- **Y-axis**: Second dimension  
- **Z-axis**: Third dimension

Each point is represented as (x, y, z) coordinates.

## Experiment Ideas

Try modifying the example to:

- **Change data**: Create your own 3D data patterns
- **Different markers**: Try different marker symbols and sizes
- **Color mapping**: Use color to represent a fourth dimension
- **Multiple traces**: Add multiple 3D scatter traces
- **Surface plots**: Convert to surface plots for continuous data

## Related Examples

- `plot_scatter3d_2` - Another 3D scatter plot example
- `plot_scatter3d_easing` - 3D scatter with animation
- `plot_surface` - 3D surface plots
- `plot_scatter` - 2D scatter plots

## Related Tutorials

- [3D Visualization](../../docs/visualization/02-3d-visualization.md)
- [2D Plotting](../../docs/visualization/01-2d-plotting.md)

## Troubleshooting

**Plot doesn't open**: Ensure you have a web browser installed and set as default

**3D view not interactive**: Check that JavaScript is enabled in your browser

**Points not visible**: Adjust the zoom or check data ranges

**Module errors**: Verify VSL installation with `v list` command

---

Happy plotting! Explore more 3D visualization examples in the [examples directory](../).
