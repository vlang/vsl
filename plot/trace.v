module plot

pub enum TraceType {
	scatter
	pie
	heatmap
	surface
	scatter3d
	bar
	histogram
}

type XType = []f64 | []string
type ZType = [][]f64 | []f64

[params]
pub struct Trace {
pub mut:
	trace_type    TraceType      [required]
	x             XType
	xbins         map[string]f32
	y             []f64          [omitempty]
	z             ZType          [omitempty]
	values        []f64          [omitempty]
	labels        []string       [omitempty]
	text          []string       [omitempty]
	customdata    [][]string     [omitempty]
	name          string         [omitempty]
	mode          string         [omitempty]
	marker        Marker         [omitempty]
	line          Line           [omitempty]
	pull          []f64          [omitempty]
	hole          f64            [omitempty]
	colorscale    string         [omitempty] = 'Viridis'
	hovertemplate string         [omitempty]
	textinfo      string         [omitempty]
	fill          string         [omitempty]
	fillcolor     string         [omitempty]
}

pub struct Marker {
pub mut:
	size       []f64    [omitempty]
	color      []string [omitempty]
	opacity    f64      [omitempty]
	colorscale string   [omitempty]
}

pub struct Line {
pub mut:
	color string [omitempty]
	width f64    [omitempty] = 2.0
	// check Plotly docs for more dash types
	dash string = 'solid'
}
