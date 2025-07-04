# Scatter Plot Example �

This example demonstrates VSL's plotting capabilities by creating an interactive scatter plot
with both line and marker elements. Perfect for beginners learning data visualization with VSL.

## 🎯 What You'll Learn

- Basic VSL plot module usage
- Creating scatter plots with markers and lines
- Customizing plot appearance (colors, sizes, titles)
- Using the `vsl.util` module for data generation

## 📋 Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- No additional system dependencies required

## 🚀 Running the Example

```sh
# Navigate to this directory
cd examples/plot_scatter

# Run the example
v run main.v
```

## 📊 Expected Output

The example generates an interactive HTML plot that will open in your default browser, showing:

- A wavy pattern with red markers and connecting lines
- Customizable zoom and pan functionality
- Professional plot styling with title and responsive design

## 🔍 Code Walkthrough

The example demonstrates several key concepts:

1. **Data Generation**: Uses `util.arange()` to create sequential x-values
2. **Plot Configuration**: Combines markers and lines in a single trace
3. **Styling**: Shows how to set colors, sizes, and visual properties
4. **Display**: Renders an interactive plot using VSL's Plotly backend

## 🎨 Customization Ideas

Try modifying the example to:

- Change colors and marker sizes
- Add multiple data series
- Experiment with different mathematical functions
- Add axis labels and annotations

## 📚 Related Examples

- `plot_line_axis_titles` - Adding axis labels
- `plot_scatter_with_annotations` - Enhanced scatter plots
- `plot_scatter3d_1` - Three-dimensional plotting

## 🐛 Troubleshooting

**Plot doesn't open**: Ensure you have a web browser installed and set as default

**Module errors**: Verify VSL installation with `v list` command

**Build failures**: Check V compiler version compatibility

---

Happy plotting! � Explore more VSL examples in the [examples directory](../).
