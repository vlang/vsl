# Plot JSON Export Example 📊🔌

This example demonstrates the new JSON export functionality that addresses [GitHub Issue #179](https://github.com/vlang/vsl/issues/179).

## 🎯 Purpose

Provides flexible methods to extract plot data as JSON strings for embedding plots in custom
web pages or using the data in other contexts.

## 🚀 New Methods

### `to_json() (string, string)`
Returns both traces and layout JSON strings in one call:
```v ignore
traces_json, layout_json := plt.to_json()
```

### `traces_json() string`
Returns only the traces data as JSON:
```v ignore
traces_json := plt.traces_json()
```

### `layout_json() string`
Returns only the layout configuration as JSON:
```v ignore
layout_json := plt.layout_json()
```

## 🛠️ Use Cases

- **Custom Web Pages**: Embed plots in existing websites
- **Data Export**: Extract plot data for other applications
- **API Integration**: Serve plot data via REST APIs
- **Template Systems**: Use with custom HTML templates

## 📋 Prerequisites

- V compiler installed
- VSL library installed
- No additional dependencies required

## 🚀 Running the Example

```sh
v run vsl/examples/plot_json_export/main.v
```

## 📊 Expected Output

The example will:
1. Create a simple quadratic function plot
2. Demonstrate all three JSON export methods
3. Show how to generate custom HTML with the exported data
4. Display character counts and sample JSON snippets

## 🔧 Integration Example

```v ignore
import vsl.plot

// Create your plot
mut plt := plot.Plot.new()
plt.scatter(x: x_data, y: y_data)
plt.layout(title: 'My Plot')

// Export JSON for custom integration
traces_json, layout_json := plt.to_json()

// Use in your custom web framework, API, or template system
custom_response := embed_in_webpage(traces_json, layout_json)
```

## 🌐 Custom HTML Generation

The example includes a `generate_custom_html()` function showing how to:
- Include Plotly.js CDN
- Transform VSL JSON format to Plotly.js format
- Create a complete HTML page with embedded plot

## 🔗 Related

- [Issue #179](https://github.com/vlang/vsl/issues/179) - Original feature request
- `plot_scatter` - Basic plotting example
- VSL Plot Documentation

---

Flexible plot data export for custom integrations! 🚀
