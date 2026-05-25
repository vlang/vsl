module main

import vsl.plot

fn main() {
	// Trade route visualization using ScatterGeo.
	// Shows major shipping lanes between global hubs on a geographic projection.
	lat := [
		51.5074, // London
		35.6762, // Tokyo
		1.3521,  // Singapore
		22.3193, // Shanghai
		37.5665, // Seoul
		-33.8688, // Sydney
		40.7128, // New York
		51.5074, // London (return)
	]
	lon := [
		-0.1278,  // London
		139.6503, // Tokyo
		103.8198, // Singapore
		114.1694, // Shanghai
		126.9780, // Seoul
		151.2093, // Sydney
		-74.0060, // New York
		-0.1278,  // London (return)
	]

	mut plt := plot.Plot.new()
	plt.scattergeo(
		lat:   lat
		lon:   lon
		mode:  'lines+markers'
		text:  ['London', 'Tokyo', 'Singapore', 'Shanghai', 'Seoul', 'Sydney', 'New York', 'London']
		name:  'Trade Route'
		line:  plot.Line{
			color: '#E63946'
			width: 2.0
		}
		marker: plot.Marker{
			size:  [12.0]
			color: ['#4575B4', '#FEE090', '#FC8D59', '#FC8D59', '#91BFDB', '#91BFDB', '#E63946', '#E63946']
		}
	)

	plt.layout(
		title:         'Global Trade Route Analysis'
		geo:           plot.Geo{
			scope:       'world'
			projection:  plot.GeoProjection{
				typ: 'equirectangular'
			}
			bgcolor:     '#e6f2ff'
		}
		plot_bgcolor:  '#f8f9fa'
		paper_bgcolor: '#ffffff'
	)

	println('ScatterGeo trade routes plot created successfully!')
	plt.show()!
}