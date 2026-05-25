module main

import vsl.plot

fn main() {
	// Representative reporting use case:
	// KPI table for an executive dashboard.
	mut plt := plot.Plot.new()
	plt.table(
		header:      plot.TableHeader{
			values: ['Metric', 'Current', 'Target', 'Status']
			align:  'left'
			fill:   plot.Fill{color: ['#1f2937']}
			font:   plot.Font{color: '#ffffff', size: 13}
		}
		cells:       plot.TableCells{
			values: [
				['MRR', 'Churn', 'NPS', 'Uptime'],
				['$421k', '2.1%', '51', '99.95%'],
				['$400k', '<3%', '50+', '99.90%'],
				['✅', '✅', '✅', '✅'],
			]
			align:  'left'
			fill:   plot.Fill{color: ['#f9fafb']}
			font:   plot.Font{color: '#111827', size: 12}
		}
		name:        'Executive KPI Summary'
		columnwidth: [220.0, 140.0, 140.0, 100.0]
	)

	plt.layout(
		title:         'Executive KPI Summary'
		width:         900
		height:        420
		plot_bgcolor:  '#ffffff'
		paper_bgcolor: '#ffffff'
	)

	println('Executive summary table plot created successfully!')
	plt.show()!
}
