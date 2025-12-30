# Your First Plot

Learn how to create beautiful, interactive plots with VSL in just a few lines of code.

## What You'll Learn

- Creating your first scatter plot
- Understanding the VSL plot API
- Customizing plot appearance
- Generating and visualizing data

## Prerequisites

- VSL installed ([see installation guide](01-installation.md))
- Basic V language knowledge

## Theory

VSL's plotting module provides a Plotly-inspired API for creating interactive
visualizations. Plots are created by:
1. Creating a `Plot` object
2. Adding traces (data series)
3. Configuring layout
4. Displaying the plot

## Basic Scatter Plot

Let's create a simple scatter plot:

```v
import vsl.plot
import vsl.util

fn main() {
	// Generate data: x from 0 to 10, y = x²
	x := util.arange(11).map(f64(it))
	y := x.map(it * it)

	// Create plot
	mut plt := plot.Plot.new()

	// Add scatter trace
	plt.scatter(
		x:    x
		y:    y
		mode: 'lines+markers'
		name: 'Quadratic Function'
	)

	// Configure layout
	plt.layout(
		title: 'My First VSL Plot'
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'X values'
			}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Y values'
			}
		}
	)

	// Display plot
	plt.show()!
}
```

Save this as `first_plot.v` and run:

```sh
v run first_plot.v
```

An interactive HTML plot should open in your browser!

## Understanding the Code

### Data Generation

```v ignore
import vsl.util

x := util.arange(11).map(f64(it))  // [0, 1, 2, ..., 10]
y := x.map(it * it)                 // [0, 1, 4, ..., 100]
```

`util.arange(n)` creates an array `[0, 1, 2, ..., n-1]`. We convert to `f64` and
map to create y-values.

### Creating the Plot

```v ignore
import vsl.plot
import vsl.util

mut plt := plot.Plot.new()
x := util.arange(11).map(f64(it)) // [0, 1, 2, ..., 10]
```

Creates a new plot object. The `mut` keyword allows modification.

### Adding Traces

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
x := []f64{}  // Assume populated
y := []f64{}  // Assume populated
plt.scatter(x: x, y: y, mode: 'lines+markers', name: 'Quadratic Function')
```

Adds a scatter trace with:
- `x`, `y`: Data arrays
- `mode`: How to display (`'markers'`, `'lines'`, or `'lines+markers'`)
- `name`: Legend label

### Layout Configuration

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
plt.layout(
    title: 'My First VSL Plot'
    xaxis: plot.Axis{title: plot.AxisTitle{text: 'X values'}}
    yaxis: plot.Axis{title: plot.AxisTitle{text: 'Y values'}}
)
```

Configures plot appearance: title, axis labels, etc.

### Displaying

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
plt.show()!
```

Opens the plot in your default browser. The `!` indicates this can fail.

## Customizing Appearance

### Colors and Markers

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
x := []f64{}  // Assume populated
y := []f64{}  // Assume populated
plt.scatter(
    x: x
    y: y
    mode: 'markers'
    marker: plot.Marker{
        size: []f64{len: x.len, init: 10.0}
        color: []string{len: x.len, init: '#FF5733'}
    }
)
```

### Multiple Traces

```v ignore
import vsl.plot
import vsl.util

x := util.arange(11).map(f64(it))
y1 := x.map(it * it)           // x²
y2 := x.map(it * it * it)      // x³

mut plt := plot.Plot.new()
plt.scatter(x: x, y: y1, name: 'Quadratic')
plt.scatter(x: x, y: y2, name: 'Cubic')
plt.layout(title: 'Multiple Functions')
plt.show()!
```

## Exercises

1. **Modify the function**: Change `y = x²` to `y = sin(x)` or `y = 2x + 1`
2. **Add more traces**: Plot multiple functions on the same plot
3. **Change colors**: Use different colors for each trace
4. **Adjust markers**: Change size, shape, or style

## Common Plot Types

### Line Chart

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
x := []f64{}  // Assume populated
y := []f64{}  // Assume populated
plt.line(x: x, y: y, mode: 'lines')
```

### Bar Chart

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
categories := []string{}  // Assume populated
values := []f64{}  // Assume populated
plt.bar(x: categories, y: values)
```

### Histogram

```v ignore
import vsl.plot

mut plt := plot.Plot.new()
data := []f64{}  // Assume populated
plt.histogram(x: data)
```

## Next Steps

- [Basic Linear Algebra](03-basic-linear-algebra.md) - Work with matrices
- [2D Plotting Tutorial](../visualization/01-2d-plotting.md) - Advanced plotting
- [Examples Directory](../../examples/) - More plot examples

## Related Examples

- `examples/plot_scatter` - Scatter plot example
- `examples/plot_line_axis_titles` - Line charts with labels
- `examples/plot_bar` - Bar chart example
- `examples/plot_histogram` - Histogram example
