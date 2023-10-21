module plot

// Enum for trace types
pub enum TraceType {
	scatter
	pie
	heatmap
	surface
	scatter3d
	bar
	histogram
}

// XType is a type for x-axis data
pub type XType = []f64 | []int | []string

// YType is a type for y-axis data
pub type YType = []f64 | []int | []string

// ZType is a type for z-axis data
pub type ZType = [][]f64 | [][]int | []f64 | []int

// CommonTrace is a struct for common trace properties
[params]
pub struct CommonTrace {
pub mut:
	x          XType
	xbins      map[string]f32
	y          YType          [omitempty]
	z          ZType          [omitempty]
	name       string         [omitempty]
	mode       string         [omitempty]
	marker     Marker         [omitempty]
	line       Line           [omitempty]
	pull       []f64          [omitempty]
	hole       f64            [omitempty]
	fill       string         [omitempty]
	fillcolor  string         [omitempty]
	customdata [][]string     [omitempty]
	colorscale string         [omitempty] = 'Viridis'
	textinfo   string         [omitempty]
	text       []string       [omitempty]
}

// ScatterTrace is a struct for Scatter trace type
[params]
pub struct ScatterTrace {
	CommonTrace
}

// PieTrace is a struct for Pie trace type
[params]
pub struct PieTrace {
	CommonTrace
pub mut:
	values []f64    [omitempty]
	labels []string [omitempty]
}

// HeatmapTrace is a struct for Heatmap trace type
[params]
pub struct HeatmapTrace {
	CommonTrace
pub mut:
	hovertemplate string [omitempty]
	zsmooth       string [omitempty]
}

// SurfaceTrace is a struct for Surface trace type
[params]
pub struct SurfaceTrace {
	CommonTrace
pub mut:
	hovertemplate string [omitempty]
}

// Scatter3DTrace is a struct for Scatter3D trace type
[params]
pub struct Scatter3DTrace {
	CommonTrace
}

// BarTrace is a struct for Bar trace type
[params]
pub struct BarTrace {
	CommonTrace
}

// HistogramTrace is a struct for Histogram trace type
[params]
pub struct HistogramTrace {
	CommonTrace
pub mut:
	nbinsx   int    [omitempty]
	nbinsy   int    [omitempty]
	xbins    Bins   [omitempty]
	histfunc string [omitempty]
	marker   Marker [omitempty]
}

// Marker is a struct for marker properties in a trace
pub struct Marker {
pub mut:
	size       []f64    [omitempty]
	color      []string [omitempty]
	opacity    f64      [omitempty]    = 0.8
	colorscale string   [omitempty] = 'Viridis'
}

// Line is a struct for line properties in a trace
pub struct Line {
pub mut:
	color string [omitempty]
	width f64    [omitempty]    = 2.0
	dash  string [omitempty] = 'solid'
}

// Bins is a struct for bin limits in a histogram trace
pub struct Bins {
pub mut:
	start f64
	end   f64
	size  f64
}

// Trace is a sum type for representing different trace types
pub type Trace = BarTrace
	| HeatmapTrace
	| HistogramTrace
	| PieTrace
	| Scatter3DTrace
	| ScatterTrace
	| SurfaceTrace

pub fn (t Trace) trace_type() string {
	return match t {
		BarTrace { 'bar' }
		HeatmapTrace { 'heatmap' }
		HistogramTrace { 'histogram' }
		PieTrace { 'pie' }
		Scatter3DTrace { 'scatter3d' }
		ScatterTrace { 'scatter' }
		SurfaceTrace { 'surface' }
	}
}
