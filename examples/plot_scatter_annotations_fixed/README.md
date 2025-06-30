# Scatter Plot with Annotations Example 📊✍️

This example demonstrates how to create scatter plots with text annotations without unwanted
arrows. This addresses common annotation display issues and shows best practices for plot
annotations.

## 🐛 Bug Fix: Unwanted Annotation Arrows

This example specifically addresses the bug where annotations show unwanted arrows. The
solution involves:

1. **Explicitly setting arrow properties to hide them**
2. **Using proper annotation positioning**
3. **Demonstrating multiple annotation styles**

## 🎯 What You'll Learn

- Creating scatter plots with proper annotations
- Controlling annotation arrow visibility
- Positioning annotations correctly
- Using different annotation styles
- Troubleshooting common plotting issues

## 📋 Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- No additional system dependencies required

## 🚀 Running the Example

```sh
# Navigate to this directory
cd examples/plot_scatter_annotations_fixed

# Run the example
v run main.v
```

## 📊 Expected Output

The example generates an interactive HTML plot showing:

- A wave pattern with red markers and connecting lines
- Clean text annotations **without arrows**
- Multiple annotation styles (simple text, positioned text, styled text)
- Professional plot appearance with proper positioning

## 🔍 Code Walkthrough

### Fixed Annotation Implementation

The key fix is to explicitly configure annotation properties to hide arrows:

```v ignore
annotation1 := plot.Annotation{
    text: 'Peak point'
    x: 2.0
    y: 3.0
    showarrow: false  // This fixes the unwanted arrow bug!
    font: plot.Font{
        size: 14
        color: '#000000'
    }
}
```

### Multiple Annotation Styles

The example demonstrates various annotation approaches:

1. **Simple Text**: Basic annotation without arrows
2. **Positioned Text**: Precisely placed annotations
3. **Styled Text**: Custom fonts and colors
4. **Background Box**: Annotations with background styling

## 🎨 Customization Options

Try modifying the example to:

- Change annotation positions and text
- Add background boxes to annotations
- Use different font styles and sizes
- Create callout-style annotations
- Add multiple annotation layers

## 📚 Related Examples

- `plot_scatter` - Basic scatter plotting
- `plot_scatter_with_annotations` - Original annotation example
- `plot_line_axis_titles` - Adding axis labels and titles

## 🐛 Troubleshooting

**Arrows still appear**: Ensure `showarrow: false` is set for each annotation

**Positioning issues**: Use relative positioning (0.0-1.0) for consistent placement

**Text overlap**: Adjust annotation positions or use smaller font sizes

**Styling not applied**: Verify font and color properties are correctly formatted

## 🔧 Technical Details

**Annotation Properties:**

- `text` - The annotation content
- `x`, `y` - Position coordinates (data coordinates or relative)
- `showarrow` - Controls arrow visibility (set to `false` to fix bug)
- `arrowhead` - Arrow style when showarrow is true (0-8)
- `arrowcolor` - Arrow color when showarrow is true
- `align` - Text alignment
- `font` - Text styling options

**Best Practices:**

- Always set `showarrow: false` unless arrows are specifically needed
- Use relative positioning for responsive layouts
- Test annotations at different zoom levels
- Consider text readability against plot background

---

Clean annotations without unwanted arrows! 🚀 Explore more plotting examples in the
[examples directory](../).
