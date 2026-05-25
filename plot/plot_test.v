module plot

fn test_bar() {
	mut plt := Plot.new()

	plt.bar(
		x: ['China', 'India', 'USA', 'Indonesia', 'Pakistan']
		y: [1411778724.0, 1379217184, 331989449, 271350000, 225200000]
	)
	plt.layout(
		title: 'Countries by population'
	)
	plt.show()!
}

fn test_scatter_hovertemplate_in_json() {
	mut plt := Plot.new()
	mut tr := ScatterTrace{
		x:             [1.0]
		y:             [2.0]
		hovertemplate: 'x=%{x}, y=%{y}<extra></extra>'
	}
	plt.add_trace(tr)
	traces, _ := plt.to_json()
	assert traces.contains('"hovertemplate":')
	assert traces.contains('x=%{x}, y=%{y}<extra></extra>')
}

fn test_ohlc_trace_type_in_json() {
	mut plt := Plot.new()
	plt.ohlc(
		x:     ['2026-01-01', '2026-01-02', '2026-01-03']
		open:  [100.0, 102.0, 101.0]
		high:  [105.0, 106.0, 104.0]
		low:   [99.0, 100.0, 98.0]
		close: [104.0, 101.0, 103.0]
		name:  'OHLC sample'
	)

	traces, _ := plt.to_json()
	assert traces.contains('"type":"ohlc"')
	assert traces.contains('"open"')
	assert traces.contains('"high"')
	assert traces.contains('"low"')
	assert traces.contains('"close"')
}

fn test_table_trace_type_in_json() {
	mut plt := Plot.new()
	plt.table(
		header: TableHeader{
			values: ['Metric', 'Value']
			align:  'left'
		}
		cells:  TableCells{
			values: [['Latency p95', 'Error rate'], ['123ms', '0.21%']]
			align:  'left'
		}
		name:   'Service SLA'
	)

	traces, _ := plt.to_json()
	assert traces.contains('"type":"table"')
	assert traces.contains('"header"')
	assert traces.contains('"cells"')
	assert traces.contains('Latency p95')
}

fn test_scattergeo_trace_type_in_json() {
	mut plt := Plot.new()
	plt.scattergeo(
		lat:   [40.71, 34.05, 37.77]
		lon:   [-74.0, -118.24, -122.41]
		mode:  'markers'
		text:  ['New York', 'Los Angeles', 'San Francisco']
		name:  'Cities'
	)

	traces, _ := plt.to_json()
	assert traces.contains('"type":"scattergeo"')
	assert traces.contains('"lat"')
	assert traces.contains('"lon"')
	assert traces.contains('"mode":"markers"')
}

fn test_barpolar_trace_type_in_json() {
	mut plt := Plot.new()
	plt.barpolar(
		r:     [1.0, 3.0, 2.0, 4.0, 2.5]
		theta: [0.0, 45.0, 90.0, 135.0, 180.0]
		marker: Marker{
			color: ['#636EFA', '#EF553B', '#00CC96', '#AB63FA', '#FFA15A']
		}
		name:  'Polar Bars'
	)

	traces, _ := plt.to_json()
	assert traces.contains('"type":"barpolar"')
	assert traces.contains('"r"')
	assert traces.contains('"theta"')
}
