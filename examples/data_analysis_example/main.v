module main

import vsl.ml
import vsl.plot

fn main() {
	// Example data: two features (X1 and X2) and a label (y)
	mut data := ml.Data.from_raw_xy([
		[1.0, 2.0, 0.0],
		[2.0, 3.0, 0.0],
		[3.0, 3.0, 0.0],
		[2.0, 1.0, 0.0],
		[6.0, 7.0, 1.0],
		[8.0, 6.0, 1.0],
		[7.0, 8.0, 1.0],
		[8.0, 7.0, 1.0],
		[4.0, 5.0, 0.0],
		[5.0, 6.0, 0.0],
		[6.0, 5.0, 0.0],
		[5.0, 4.0, 0.0],
		[9.0, 10.0, 1.0],
		[10.0, 9.0, 1.0],
		[11.0, 10.0, 1.0],
		[10.0, 11.0, 1.0],
		[12.0, 11.0, 1.0],
		[11.0, 12.0, 1.0],
		[13.0, 14.0, 1.0],
		[14.0, 13.0, 1.0],
		[15.0, 14.0, 1.0],
		[14.0, 15.0, 1.0],
		[16.0, 15.0, 1.0],
		[15.0, 16.0, 1.0],
		[17.0, 18.0, 1.0],
		[18.0, 17.0, 1.0],
		[19.0, 18.0, 1.0],
		[18.0, 19.0, 1.0],
		[3.0, 4.0, 0.0],
		[4.0, 3.0, 0.0],
		[7.0, 6.0, 1.0],
		[6.0, 8.0, 1.0],
		[9.0, 8.0, 1.0],
		[8.0, 9.0, 1.0],
		[11.0, 12.0, 1.0],
		[12.0, 13.0, 1.0],
		[15.0, 14.0, 1.0],
		[14.0, 16.0, 1.0],
		[18.0, 17.0, 1.0],
		[17.0, 19.0, 1.0],
		[5.0, 5.0, 0.0],
		[10.0, 10.0, 1.0],
		[15.0, 15.0, 1.0],
		[4.0, 8.0, 1.0],
		[8.0, 4.0, 0.0],
		[12.0, 16.0, 1.0],
		[16.0, 12.0, 1.0],
		[20.0, 5.0, 0.0],
		[5.0, 20.0, 0.0],
		[12.0, 8.0, 1.0],
		[8.0, 12.0, 1.0],
		[18.0, 16.0, 1.0],
		[16.0, 18.0, 1.0],
	])!

	// Visualize data in a 3D scatter plot
	mut plt_3d := plot.Plot.new()

	x1 := data.x.get_col(0)
	x2 := data.x.get_col(1)
	y := data.y

	// Split data into two classes for visualization
	mut x1_class0 := []f64{}
	mut x2_class0 := []f64{}
	mut x1_class1 := []f64{}
	mut x2_class1 := []f64{}

	for i in 0 .. data.nb_samples {
		if y[i] == 0.0 {
			x1_class0 << x1[i]
			x2_class0 << x2[i]
		} else {
			x1_class1 << x1[i]
			x2_class1 << x2[i]
		}
	}

	// Add traces for each class in the 3D plot
	plt_3d.scatter3d(
		x:      x1_class0
		y:      x2_class0
		z:      [][]f64{len: x1_class0.len, init: [0.0]}
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: x1_class0.len, init: 8.0}
			color: []string{len: x1_class0.len, init: 'blue'}
		}
		name:   'Class 0'
	)
	plt_3d.scatter3d(
		x:      x1_class1
		y:      x2_class1
		z:      [][]f64{len: x1_class1.len, init: [0.0]}
		mode:   'markers'
		marker: plot.Marker{
			size:  []f64{len: x1_class1.len, init: 8.0}
			color: []string{len: x1_class1.len, init: 'red'}
		}
		name:   'Class 1'
	)

	// Configure the layout of the 3D plot
	plt_3d.layout(
		title: 'Two-class Data'
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'X1'
			}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'X2'
			}
		}
	)

	// Show the 3D plot
	plt_3d.show()!

	// Basic statistics analysis
	mut stat := ml.Stat.from_data(mut data, 'Example Data')
	stat.update()

	// Visualize statistics in a bar chart
	mut plt_bars := plot.Plot.new()

	plt_bars.bar(
		x:    []string{len: stat.mean_x.len, init: 'Class ${index}'}
		y:    stat.mean_x
		name: 'Mean'
	)

	plt_bars.bar(
		x:    []string{len: stat.sig_x.len, init: 'Class ${index}'}
		y:    stat.sig_x
		name: 'Standard Deviation'
	)

	// Configure the layout of the bar chart
	plt_bars.layout(
		title: 'Feature Statistics'
	)

	// Show the bar chart
	plt_bars.show()!
}
