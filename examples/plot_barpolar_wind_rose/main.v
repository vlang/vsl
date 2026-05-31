module main

import vsl.plot

fn main() {
	// Wind direction + magnitude as a polar bar chart.
	// Each bar's angle represents compass direction; its length represents speed.
	directions := [0.0, 45.0, 90.0, 135.0, 180.0, 225.0, 270.0, 315.0]
	// Wind speed (m/s) for each direction -- realistic prevailing-wind profile
	speeds := [12.5, 8.3, 15.7, 6.2, 9.8, 18.1, 11.4, 7.9]
	// Assign color per wind speed bin
	mut bar_colors := []string{}
	for s in speeds {
		if s >= 10 {
			bar_colors << '#3288BD'
		} else if s >= 8 {
			bar_colors << '#66C2A5'
		} else if s >= 6 {
			bar_colors << '#ABD9E9'
		} else if s >= 4 {
			bar_colors << '#FEE08B'
		} else if s >= 2 {
			bar_colors << '#FDAE61'
		} else {
			bar_colors << '#E6F2FF'
		}
	}

	mut plt := plot.Plot.new()
	plt.barpolar(
		r:         speeds
		theta:     directions
		thetaunit: 'degrees'
		marker:    plot.Marker{
			color: bar_colors
		}
		name:      'Wind Speed by Direction'
	)

	plt.layout(
		title:         'Wind Rose -- Compass Directions'
		plot_bgcolor:  '#f8f9fa'
		paper_bgcolor: '#ffffff'
	)

	println('BarPolar wind rose plot created successfully!')
	plt.show()!
}
