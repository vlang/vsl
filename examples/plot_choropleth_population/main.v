module main

import vsl.plot

fn main() {
	// Create a choropleth map for population density analysis
	// Using US states as an example
	
	// US state codes (ISO-3166-2)
	state_codes := [
		'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
		'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
		'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
		'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
		'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY'
	]
	
	// Population density per square mile (simplified data)
	population_density := [
		96.9, 1.3, 64.0, 58.4, 253.7, 56.4, 735.8, 508.8, 401.4, 186.6,
		221.8, 22.0, 230.8, 188.1, 56.9, 36.0, 113.0, 107.5, 43.2, 626.6,
		894.4, 174.0, 71.5, 63.7, 89.5, 7.4, 25.2, 28.6, 153.1, 1263.0,
		17.2, 410.5, 218.3, 11.0, 287.5, 57.7, 43.8, 290.5, 1061.4, 173.3,
		11.9, 170.8, 112.8, 39.9, 68.0, 218.4, 117.0, 77.2, 108.0, 6.0
	]
	
	// Create a new plot instance
	mut plt := plot.Plot.new()
	
	// Add choropleth map
	plt.choropleth(
		locations: state_codes
		z: population_density
		locationmode: 'USA-states'
		colorscale: 'Viridis'
		showscale: true
		reversescale: false
		name: 'Population Density'
		hovertemplate: '<b>%{location}</b><br>Density: %{z:.1f} people/sq mi<extra></extra>'
	)
	
	// Configure the plot layout
	plt.layout(
		title: 'US Population Density by State (People per Square Mile)'
		geo: plot.Geo{
			scope: 'usa'
			projection: plot.GeoProjection{
				typ: 'albers usa'
			}
		}
		plot_bgcolor: '#f8f9fa'
		paper_bgcolor: '#ffffff'
		width: 900
		height: 600
	)

	// Display the plot
	println('Choropleth population density map created successfully!')
	plt.show()!
}
