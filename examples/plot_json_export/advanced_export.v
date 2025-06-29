module main

import vsl.plot
import vsl.util
import os

fn main() {
	// Create a more complex plot with multiple traces
	x := util.arange(20).map(f64(it))
	y1 := x.map(f64(it) * 0.5 + 2.0) // Linear
	y2 := x.map(f64(it * it) * 0.1) // Quadratic

	mut plt := plot.Plot.new()

	// Add first trace
	plt.scatter(
		x:      x
		y:      y1
		mode:   'lines+markers'
		name:   'Linear Function'
		marker: plot.Marker{
			size:  []f64{len: x.len, init: 6.0}
			color: []string{len: x.len, init: '#1f77b4'}
		}
		line:   plot.Line{
			color: '#1f77b4'
			width: 2.0
		}
	)

	// Add second trace
	plt.scatter(
		x:      x
		y:      y2
		mode:   'lines+markers'
		name:   'Quadratic Function'
		marker: plot.Marker{
			size:  []f64{len: x.len, init: 6.0}
			color: []string{len: x.len, init: '#ff7f0e'}
		}
		line:   plot.Line{
			color: '#ff7f0e'
			width: 2.0
		}
	)

	// Configure layout with annotations
	plt.layout(
		title:  'Multi-Trace Plot for JSON Export'
		xaxis:  plot.Axis{
			title: plot.AxisTitle{
				text: 'X Values'
			}
		}
		yaxis:  plot.Axis{
			title: plot.AxisTitle{
				text: 'Y Values'
			}
		}
		width:  800
		height: 600
	)

	// Export JSON data
	traces_json, layout_json := plt.to_json()

	// Generate a complete standalone HTML file
	html_content := generate_standalone_plot(traces_json, layout_json)

	// Write to file
	os.write_file('exported_plot.html', html_content) or {
		eprintln('Error writing file: ${err}')
		return
	}

	println('✅ Advanced plot exported successfully!')
	println('📁 Generated file: exported_plot.html')
	println('🌐 Open the file in your browser to view the interactive plot')
	println('')
	println('📊 Plot Data Summary:')
	println('   - Traces JSON: ${traces_json.len} characters')
	println('   - Layout JSON: ${layout_json.len} characters')
	println('   - Total HTML: ${html_content.len} characters')
	println('   - Traces count: 2')
	println('   - Data points per trace: ${x.len}')
}

fn generate_standalone_plot(traces_json string, layout_json string) string {
	return '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VSL Plot Export - Advanced Example</title>
    <script src="https://cdn.plot.ly/plotly-2.26.2.min.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
            margin-bottom: 30px;
        }
        .info {
            background: #e3f2fd;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            border-left: 4px solid #2196f3;
        }
        #plot-container {
            width: 100%;
            height: 600px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 VSL Plot Export Example</h1>
        
        <div class="info">
            <strong>🎯 Generated with VSL Plot JSON Export</strong><br>
            This plot was created using V Scientific Library (VSL) and exported using the new JSON export methods 
            that address <a href="https://github.com/vlang/vsl/issues/179" target="_blank">GitHub Issue #179</a>.
        </div>
        
        <div id="plot-container"></div>
        
        <script>
            // Raw data exported from VSL Plot
            const traces = ${traces_json};
            const layout = ${layout_json};
            
            function removeEmptyFieldsDeeply(obj) {
                if (Array.isArray(obj)) {
                    return obj.map(removeEmptyFieldsDeeply);
                }
                if (typeof obj === "object" && obj !== null) {
                    const newObj = Object.fromEntries(
                        Object.entries(obj)
                            .map(([key, value]) => [key, removeEmptyFieldsDeeply(value)])
                            .filter(([_, value]) => !!value)
                    );
                    return Object.keys(newObj).length > 0 ? newObj : undefined;
                }
                return obj;
            }
            
            // Transform VSL format to Plotly.js format
            const data = traces.map(({ type, trace: { CommonTrace, _type, ...trace } }) => 
                ({ type, ...CommonTrace, ...trace }));
            
            // Clean up empty fields and render plot
            const payload = {
                data: removeEmptyFieldsDeeply(data),
                layout: removeEmptyFieldsDeeply(layout),
            };
            
            // Create the interactive plot
            Plotly.newPlot("plot-container", payload);
            
            console.log("📊 Plot rendered successfully!");
            console.log("🔧 Traces:", payload.data);
            console.log("📐 Layout:", payload.layout);
        </script>
    </div>
</body>
</html>'
}
