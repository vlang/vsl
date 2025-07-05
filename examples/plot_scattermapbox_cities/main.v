module main

import vsl.plot

fn main() {
	// Create a scatter mapbox plot for major world cities
	
	// Major world cities data
	city_names := [
		'New York', 'London', 'Tokyo', 'Paris', 'Sydney',
		'Mumbai', 'São Paulo', 'Cairo', 'Moscow', 'Beijing',
		'Los Angeles', 'Istanbul', 'Lagos', 'Bangkok', 'Buenos Aires'
	]
	
	// Coordinates (latitude, longitude)
	latitudes := [
		40.7128, 51.5074, 35.6762, 48.8566, -33.8688,
		19.0760, -23.5505, 30.0444, 55.7558, 39.9042,
		34.0522, 41.0082, 6.5244, 13.7563, -34.6037
	]
	
	longitudes := [
		-74.0060, -0.1278, 139.6503, 2.3522, 151.2093,
		72.8777, -46.6333, 31.2357, 37.6176, 116.4074,
		-118.2437, 28.9784, 3.3792, 100.5018, -58.3816
	]
	
	// Population in millions (approximate)
	populations := [
		8.4, 9.0, 13.9, 2.1, 5.3,
		20.4, 12.3, 10.2, 12.5, 21.5,
		4.0, 15.5, 14.9, 10.5, 3.0
	]
	
	// Create a new plot instance
	mut plt := plot.Plot.new()
	
	// Add scatter mapbox
	plt.scattermapbox(
		lat: latitudes
		lon: longitudes
		mode: 'markers'
		marker: plot.Marker{
			size: populations.map(it * 3) // Scale marker size by population
			color: populations.map(it.str()) // Color by population
			colorscale: 'Viridis'
			opacity: 0.8
		}
		text: city_names
		name: 'World Cities'
		hovertemplate: '<b>%{text}</b><br>Population: %{marker.color:.1f}M<br>Lat: %{lat}<br>Lon: %{lon}<extra></extra>'
	)
	
	// Configure the plot layout
	plt.layout(
		title: 'Major World Cities by Population'
		mapbox: plot.Mapbox{
			style: 'open-street-map'
			center: plot.MapboxCenter{
				lat: 20.0
				lon: 0.0
			}
			zoom: 1.0
		}
		plot_bgcolor: '#f8f9fa'
		paper_bgcolor: '#ffffff'
		width: 900
		height: 700
	)

	// Display the plot
	println('Scatter mapbox cities visualization created successfully!')
	plt.show()!
}
