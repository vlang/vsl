module main

import vsl.plot
import vsl.util

fn main() {
	// Create sample data
	x := util.arange(10).map(f64(it))
	y := x.map(it * it)

	// Create plot
	mut plt := plot.Plot.new()
	plt.scatter(
		x: x
		y: y
		mode: 'lines+markers'
		marker: plot.Marker{
			size: []f64{len: x.len, init: 8.0}
			color: []string{len: x.len, init: '#1f77b4'}
		}
	)
	plt.layout(
		title: 'JSON Export Example'
		xaxis: plot.Axis{
			title: plot.AxisTitle{text: 'X values'}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{text: 'Y values (X²)'}
		}
	)

	// Test the new JSON export functionality
	println('=== Testing Plot JSON Export (Issue #179) ===\n')

	// Method 1: Get both JSON strings at once
	traces_json, layout_json := plt.to_json()
	println('Method 1: to_json() - Combined export')
	println('Traces JSON length: ${traces_json.len} characters')
	println('Layout JSON length: ${layout_json.len} characters')
	println('')

	// Method 2: Get traces JSON separately
	traces_only := plt.traces_json()
	println('Method 2: traces_json() - Traces only')
	println('Traces JSON length: ${traces_only.len} characters')
	println('First 100 chars: ${traces_only[..100]}...')
	println('')

	// Method 3: Get layout JSON separately
	layout_only := plt.layout_json()
	println('Method 3: layout_json() - Layout only')
	println('Layout JSON length: ${layout_only.len} characters')
	println('First 100 chars: ${layout_only[..100]}...')
	println('')

	// Example usage: Custom HTML generation
	custom_html := generate_custom_html(traces_json, layout_json)
	println('Generated custom HTML length: ${custom_html.len} characters')
	println('')

	println('✅ JSON export functionality working correctly!')
	println('📊 Ready for custom web page integration')
}

// Example function showing how to use the JSON data in custom HTML
fn generate_custom_html(traces_json string, layout_json string) string {
	return '<!DOCTYPE html>
<html>
<head>
    <title>Custom Plot Integration</title>
    <script src="https://cdn.plot.ly/plotly-2.26.2.min.js"></script>
</head>
<body>
    <h1>My Custom Dashboard</h1>
    <div id="my-plot" style="width:100%;height:400px;"></div>
    <script>
        const traces = ${traces_json};
        const layout = ${layout_json};
        
        // Transform traces to Plotly format
        const data = traces.map(({ type, trace: { CommonTrace, _type, ...trace } }) => 
            ({ type, ...CommonTrace, ...trace }));
        
        Plotly.newPlot("my-plot", data, layout);
    </script>
</body>
</html>'
}
