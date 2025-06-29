# VSL Plot Module 📊

This library implements high-level plotting functions for scientific data visualization using a Plotly-inspired API. Create interactive, publication-quality plots with minimal code while maintaining full customization control.

## 🚀 Features

### Plot Types

- **Scatter Plots**: Points, lines, or combined with extensive marker customization
- **Bar Charts**: Vertical and horizontal bars with grouping support
- **Heatmaps**: 2D data visualization with color mapping
- **Histograms**: Distribution visualization with binning control
- **Pie Charts**: Proportion visualization with labels and annotations
- **3D Scatter**: Three-dimensional data visualization
- **Surface Plots**: 3D surface rendering for mathematical functions

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
y := x.map(it * it)  // y = x²

// Create plot
mut plt := plot.Plot.new()
plt.scatter(x: x, y: y, mode: 'lines+markers')
plt.layout(title: 'Quadratic Function')
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
z := [[1.0, 20.0, 30.0],
      [20.0, 1.0, 60.0],
      [30.0, 60.0, 1.0]]

mut plt := plot.Plot.new()
plt.heatmap(z: z)
plt.layout(title: 'Correlation Matrix')
plt.show()!
```

## 🎨 Customization Guide

### Styling Options

**Colors**: Use hex codes (`#FF0000`), RGB (`rgb(255,0,0)`), or named colors (`red`)

**Markers**: Control size, color, symbol, and opacity

```v
marker: plot.Marker{
    size: []f64{len: data.len, init: 12.0}
    color: ['#FF0000', '#00FF00', '#0000FF']
    symbol: 'circle'  // Options: circle, square, diamond, triangle, etc.
}
```

**Lines**: Customize thickness, style, and color

```v
line: plot.Line{
    color: '#FF0000'
    width: 3.0
    dash: 'solid'  // Options: solid, dash, dot, dashdot
}
```

### Layout Configuration

```v
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

```v
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

```v
font: plot.Font{
    family: 'Arial, sans-serif'
    size: 16
    color: '#333333'
}
```

### Arrow Customization

```v
annotation := plot.Annotation{
    text: 'Point with Arrow'
    x: 5.0
    y: 10.0
    showarrow: true
    arrowhead: 2           // Arrow style (0-8)
    arrowcolor: '#FF0000'  // Red arrow color
}
```

## 🐛 Common Issues & Solutions

### Annotation Arrows Appearing Unexpectedly

**Problem**: Unwanted arrows show up with annotations
**Solution**: Always set `showarrow: false` unless arrows are specifically needed

```v
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

```v
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

## 🎯 Examples Directory

Explore complete examples:

- `plot_scatter` - Basic scatter plotting
- `plot_scatter_annotations_fixed` - Annotations without arrows
- `plot_bar` - Bar chart examples
- `plot_heatmap_golden_ratio` - Advanced heatmap styling
- `plot_surface` - 3D surface visualization

## 🔗 API Reference

### Core Functions

- `Plot.new()` - Create new plot instance
- `plt.scatter()` - Add scatter/line traces
- `plt.bar()` - Add bar charts
- `plt.heatmap()` - Add heatmap visualization
- `plt.layout()` - Configure plot appearance
- `plt.show()` - Render and display plot

### Data Types

- `Plot` - Main plotting object
- `Marker` - Point styling configuration
- `Line` - Line styling configuration
- `Axis` - Axis configuration
- `Annotation` - Text annotation settings

---

Create beautiful, interactive visualizations with VSL Plot! 🚀

Based on [Plotly's graph_objects](https://plotly.com/python/graph-objects/) API design.
