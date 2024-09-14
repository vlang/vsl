module main

import vsl.plot

fn main() {
	x := []f64{len: 100, init: f64(index) * 0.1}
	y := [1.2, 2.1, 3.0, 4.5, 5.8, 7.0, 8.2, 9.1, 10.5, 11.8]

	mut plt := plot.Plot.new()
	plt.scatter(
		x:      x
		y:      y
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: x.len, init: 10.0}
			color: []string{len: x.len, init: '#00FF00'}
		}
		name: 'Data Points'
	)
	plt.scatter(
		x:    x
		y:    y
		mode: 'lines'
		line: plot.Line{
			color: '#FF0000'
		}
		name: 'Regression Line'
	)
	plt.layout(
		title: 'Scatter Plot with Regression Line'
	)
	plt.show()!
}
