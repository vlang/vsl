# VSL Plot Module 📊

This library implements high-level plotting functions for scientific data
visualization using a Plotly-inspired API. Create interactive, publication-quality
plots with minimal code while maintaining full customization control.

## 🚀 Features

### Core Plot Types

- **Scatter Plots**: Points, lines, or combined with extensive marker customization
- **Line Charts**: Time series and continuous data visualization
- **Bar Charts**: Vertical and horizontal bars with grouping support
- **Histograms**: Distribution visualization with binning control
- **Pie Charts**: Proportion visualization with labels and annotations
- **Heatmaps**: 2D data visualization with color mapping
- **3D Scatter**: Three-dimensional data visualization
- **Surface Plots**: 3D surface rendering for mathematical functions

### Statistical & Distribution Charts

- **Box Plots**: Statistical distribution analysis with quartiles
- **Violin Plots**: Kernel density estimation for distributions
- **Contour Plots**: Topographical and mathematical contour visualization

### Business & Financial Charts

- **Waterfall Charts**: Financial flow and variance analysis
- **Candlestick Charts**: OHLC stock price visualization
- **Funnel Charts**: Conversion and process flow analysis

### Hierarchical & Network Charts

- **Sunburst Charts**: Hierarchical data with radial layout
- **Treemap Charts**: Hierarchical data with nested rectangles
- **Sankey Diagrams**: Flow and process visualization
- **Network Graphs**: Node-link relationship visualization

### Advanced Analytics

- **Radar/Polar Charts**: Multi-dimensional comparison
- **Parallel Coordinates**: High-dimensional data analysis
- **2D Histograms**: Bivariate distribution analysis
- **Density Plots**: Continuous probability distributions
- **Ridgeline Plots**: Multiple distribution comparison

### Geographic & Mapping

- **Choropleth Maps**: Geographic data visualization
- **Scatter Mapbox**: Location-based scatter plots
- **Density Mapbox**: Geographic density visualization

### Interactive Features

- **Zoom & Pan**: Mouse-driven plot navigation
- **Hover Information**: Dynamic data point details
- **Legend Control**: Show/hide data series
- **Export Options**: Save as PNG, SVG, or HTML
- **Responsive Design**: Automatic layout adjustment

## 📖 Quick Start

### Basic Scatter Plot

```v
import vsl.plot
import vsl.util

// Generate data
x := util.arange(10).map(f64(it))
y := x.map(it * it) // y = x²

// Create plot
mut plt := plot.Plot.new()
plt.scatter(x: x, y: y, mode: 'lines+markers')
plt.layout(title: 'Quadratic Function')
plt.show()!
```

### Line Chart (Time Series)

```v
import vsl.plot

dates := ['2024-01', '2024-02', '2024-03', '2024-04']
prices := [100.0, 120.0, 110.0, 130.0]

mut plt := plot.Plot.new()
plt.line(x: dates, y: prices, mode: 'lines+markers')
plt.layout(title: 'Stock Price Trend')
plt.show()!
```

### Box Plot (Statistical Analysis)

```v
import vsl.plot

data1 := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
data2 := [2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]

mut plt := plot.Plot.new()
plt.box(y: data1, name: 'Dataset A')
plt.box(y: data2, name: 'Dataset B')
plt.layout(title: 'Distribution Comparison')
plt.show()!
```

### Violin Plot (Distribution Shape)

```v
import vsl.plot

values := [1.0, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]

mut plt := plot.Plot.new()
plt.violin(y: values, name: 'Distribution')
plt.layout(title: 'Data Distribution Shape')
plt.show()!
```

### Candlestick Chart (Financial)

```v
import vsl.plot

dates := ['2024-01-01', '2024-01-02', '2024-01-03']
open_prices := [100.0, 105.0, 102.0]
high_prices := [110.0, 108.0, 107.0]
low_prices := [95.0, 100.0, 98.0]
close_prices := [105.0, 102.0, 106.0]

mut plt := plot.Plot.new()
plt.candlestick(
	x:     dates
	open:  open_prices
	high:  high_prices
	low:   low_prices
	close: close_prices
)
plt.layout(title: 'Stock Price OHLC')
plt.show()!
```

### Sunburst Chart (Hierarchical Data)

```v
import vsl.plot

mut plt := plot.Plot.new()
plt.sunburst(
	labels:  ['Root', 'A', 'B', 'A1', 'A2', 'B1']
	parents: ['', 'Root', 'Root', 'A', 'A', 'B']
	values:  [100.0, 60.0, 40.0, 30.0, 30.0, 40.0]
)
plt.layout(title: 'Hierarchical Structure')
plt.show()!
```

### Choropleth Map (Geographic)

```v
import vsl.plot

state_codes := ['CA', 'TX', 'NY', 'FL']
population := [39500000.0, 29000000.0, 19500000.0, 21500000.0]

mut plt := plot.Plot.new()
plt.choropleth(
	locations:    state_codes
	z:            population
	locationmode: 'USA-states'
	colorscale:   'Viridis'
)
plt.layout(
	title: 'US Population by State'
	geo:   plot.Geo{
		scope: 'usa'
	}
)
plt.show()!
```

### Parallel Coordinates (Multi-dimensional)

```v
import vsl.plot

mut plt := plot.Plot.new()
plt.parcoords(
	dimensions: [
		plot.Dimension{
			label:  'Feature 1'
			values: [1.0, 2.0, 3.0, 4.0]
		},
		plot.Dimension{
			label:  'Feature 2'
			values: [10.0, 20.0, 30.0, 40.0]
		},
	]
)
plt.layout(title: 'Multi-dimensional Analysis')
plt.show()!
```

### Bar Chart

```v
import vsl.plot

categories := ['A', 'B', 'C', 'D']
values := [23.0, 45.0, 56.0, 78.0]

mut plt := plot.Plot.new()
plt.bar(x: categories, y: values)
plt.layout(title: 'Category Comparison')
plt.show()!
```

### Heatmap

```v
import vsl.plot

// 2D data matrix
z := [[1.0, 20.0, 30.0], [20.0, 1.0, 60.0], [30.0, 60.0, 1.0]]

mut plt := plot.Plot.new()
plt.heatmap(z: z)
plt.layout(title: 'Correlation Matrix')
plt.show()!
```

## 🎨 Customization Guide

### Styling Options

**Colors**: Use hex codes (`#FF0000`), RGB (`rgb(255,0,0)`), or named colors (`red`)

**Markers**: Control size, color, symbol, and opacity

```v ignore
marker:
plot.Marker
{
	size:   []f64{len: data.len, init: 12.0}
	color:  ['#FF0000', '#00FF00', '#0000FF']
	symbol: 'circle' // Options: circle, square, diamond, triangle, etc.
}
```

**Lines**: Customize thickness, style, and color

```v ignore
line:
plot.Line
{
	color: '#FF0000'
	width: 3.0
	dash:  'solid' // Options: solid, dash, dot, dashdot
}
```

### Layout Configuration

```v ignore
plt.layout(
    title: 'My Plot Title'
    xaxis: plot.Axis{
        title: plot.AxisTitle{text: 'X-axis Label'}
        range: [0.0, 10.0]  // Set axis range
    }
    yaxis: plot.Axis{
        title: plot.AxisTitle{text: 'Y-axis Label'}
        type: 'log'  // Linear or logarithmic scale
    }
    width: 800
    height: 600
)
```

## 🔧 Annotations & Text

### Adding Annotations (Fixed Arrow Issue)

The most important fix for annotation arrows:

```v ignore
// ✅ CORRECT: No unwanted arrows
annotation := plot.Annotation{
    text: 'Important Point'
    x: 5.0
    y: 25.0
    showarrow: false  // This prevents unwanted arrows!
    font: plot.Font{
        size: 14
        color: '#000000'
    }
}

plt.layout(
    title: 'Plot with Clean Annotations'
    annotations: [annotation]
)
```

### Text Styling

```v ignore
font:
plot.Font
{
	family: 'Arial, sans-serif'
	size:   16
	color:  '#333333'
}
```

### Arrow Customization

```v ignore
annotation := plot.Annotation
{
	text:       'Point with Arrow'
	x:          5.0
	y:          10.0
	showarrow:  true
	arrowhead:  2 // Arrow style (0-8)
	arrowcolor: '#FF0000' // Red arrow color
}
```

## 🐛 Common Issues & Solutions

### Annotation Arrows Appearing Unexpectedly

**Problem**: Unwanted arrows show up with annotations
**Solution**: Always set `showarrow: false` unless arrows are specifically needed

```v ignore
// ❌ WRONG: May show unwanted arrows
annotation := plot.Annotation{
    text: 'My annotation'
    x: 1.0
    y: 2.0
    // Missing showarrow property
}

// ✅ CORRECT: Clean text annotation
annotation := plot.Annotation{
    text: 'My annotation'
    x: 1.0
    y: 2.0
    showarrow: false  // Explicitly prevent arrows
}
```

### Plot Not Displaying

**Common causes:**

- Missing `plt.show()!` call
- Browser not opening HTML file
- Invalid data format (ensure f64 for numeric data)

### Performance Issues

**Large datasets:**

- Consider data sampling for >10,000 points
- Use appropriate plot types (heatmap for dense 2D data)
- Optimize marker sizes and line widths

## 📚 Advanced Examples

### Multiple Data Series

```v ignore
mut plt := plot.Plot.new()

// First series
plt.scatter(
    x: x1, y: y1
    name: 'Dataset 1'
    marker: plot.Marker{color: ['#FF0000']}
)

// Second series
plt.scatter(
    x: x2, y: y2
    name: 'Dataset 2'
    marker: plot.Marker{color: ['#0000FF']}
)
```

### Subplots (Coming Soon)

The VSL plot module is actively developed. Subplot functionality is planned for future releases.

---

Create beautiful, interactive visualizations with VSL Plot! 🚀

Based on [Plotly's graph_objects](https://plotly.com/python/graph-objects/) API design.
