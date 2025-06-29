module main

import vsl.plot
import vsl.util

fn main() {
	// Generate sample data representing a wave pattern
	// This creates a sinusoidal wave with some variation
	y := [
		0.0, // Starting point
		1, // Rising phase
		3, // Peak region
		1, // Falling phase
		0, // Zero crossing
		-1, // Negative phase
		-3, // Negative peak
		-1, // Rising from negative
		0, // Zero crossing again
		1, // Positive phase
		3, // Peak again
		1, // Falling
		0, // Return to start
	]

	// Generate corresponding x-values using VSL's utility function
	// Convert to f64 as required by the plotting system
	x := util.arange(y.len).map(f64(it))

	// Create a new plot instance
	// This initializes the plotting backend (uses Plotly.js internally)
	mut plt := plot.Plot.new()

	// Add a scatter trace with both lines and markers
	plt.scatter(
		x:      x               // X-axis data points
		y:      y               // Y-axis data points
		mode:   'lines+markers' // Display both connecting lines and point markers
		marker: plot.Marker{
			size:  []f64{len: x.len, init: 10.0}         // All markers size 10 pixels
			color: []string{len: x.len, init: '#FF0000'} // All markers red color
		}
		line:   plot.Line{
			color: '#FF0000' // Line color matches markers (red)
		}
	)

	// === FIX FOR ANNOTATION ARROW BUG ===
	// Multi-layered approach to prevent unwanted arrows:
	// 1. Set 'showarrow: false'
	// 2. Set 'arrowhead: 0' as additional protection
	// 3. Use transparent arrow color 'rgba(0,0,0,0)' as final fallback

	// Annotation 1: Simple text annotation at peak point
	annotation1 := plot.Annotation{
		text:      'Peak Point' // Text to display
		x:         2.0          // X coordinate (data coordinates)
		y:         3.2          // Y coordinate (slightly above peak)
		showarrow: false        // CRITICAL: This prevents the unwanted arrow!
		arrowhead: 0            // Additional fix: Set arrowhead to 0
		arrowcolor: 'rgba(0,0,0,0)' // Make arrow transparent if it still appears
		font:      plot.Font{
			size:  14        // Font size
			color: '#000000' // Black text
		}
	}

	// Annotation 2: Valley point annotation
	annotation2 := plot.Annotation{
		text:      'Valley Point'
		x:         6.0   // X coordinate at valley
		y:         -2.8  // Y coordinate (slightly below valley)
		showarrow: false // No arrow for clean appearance
		arrowhead: 0     // Additional fix: Set arrowhead to 0
		arrowcolor: 'rgba(0,0,0,0)' // Make arrow transparent
		font:      plot.Font{
			size:  14
			color: '#0000FF' // Blue text for contrast
		}
	}

	// Annotation 3: General description
	annotation3 := plot.Annotation{
		text:      'Sine Wave Pattern'
		x:         8.8   // Position on right side
		y:         1.2   // Middle height
		showarrow: false // Clean text without arrow
		arrowhead: 0     // Additional fix: Set arrowhead to 0
		arrowcolor: 'rgba(0,0,0,0)' // Make arrow transparent
		font:      plot.Font{
			size:  12
			color: '#000000' // Black text for visibility
		}
	}

	// Configure the plot layout with all annotations
	plt.layout(
		title:       'Scatter Plot with Fixed Annotations (No Arrows)' // Main plot title
		annotations: [annotation1, annotation2, annotation3]           // Add all annotations
	)

	// Render the plot and open in default browser
	// This generates an HTML file with interactive JavaScript plot
	plt.show()!

	// Print confirmation message
	println('✅ Plot generated successfully with clean annotations (no unwanted arrows)!')
	println('🎯 Multi-layer fix applied: showarrow: false + arrowhead: 0 + transparent arrow')
	println('📍 Annotations positioned at data coordinates for precision')
}
