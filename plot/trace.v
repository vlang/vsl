module plot

pub enum TraceType {
	scatter
	pie
	heatmap
	surface
	scatter3d
	bar
	// WIP: new trace types will be added eventually.
}

pub struct Trace {
pub mut:
	trace_type		TraceType	[required]
	x				[]f64
	x_str			[]string	// for bar graphs
	y				[]f64
	z				[][]f64
	values			[]f64
	labels			[]string
	text			[]string
	customdata		[][]string
	name			string
	mode			string
	marker			Marker
	line			Line
	pull			[]f64
	hole			f64
	colorscale		string	= 'Viridis'
	hovertemplate	string
	// WIP: new properties will be added eventually.
}

pub struct Marker {
pub mut:
	size			[]f64
	color			[]string
	opacity			f64		= 0.8
	colorscale		string	= 'Viridis'
	// WIP: new properties will be added eventually.
}

pub struct Line {
pub mut:
	color			string
	width			f64		= 2.0
	dash			string	= 'solid' // check Plotly docs for more dash types
	// WIP: new properties will be added eventually.
}
