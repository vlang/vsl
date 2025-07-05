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
	line
	box
	violin
	contour
	waterfall
	sunburst
	treemap
	candlestick
	funnel
	scatterpolar
}

// XType is a type for x-axis data
pub type XType = []f64 | []int | []string

// YType is a type for y-axis data
pub type YType = []f64 | []int | []string

// ZType is a type for z-axis data
pub type ZType = [][]f64 | [][]int | []f64 | []int

// CommonTrace is a struct for common trace properties
@[params]
pub struct CommonTrace {
pub mut:
	x          XType
	x0         string     @[omitempty] // Single x position for violin/box plots
	xbins      map[string]f32
	y          YType      @[omitempty]
	y0         string     @[omitempty] // Single y position for horizontal plots
	z          ZType      @[omitempty]
	name       string     @[omitempty]
	mode       string     @[omitempty]
	marker     Marker     @[omitempty]
	line       Line       @[omitempty]
	pull       []f64      @[omitempty]
	hole       f64        @[omitempty]
	fill       string     @[omitempty]
	fillcolor  string     @[omitempty]
	customdata [][]string @[omitempty]
	colorscale string = 'Viridis'     @[omitempty]
	textinfo   string     @[omitempty]
	text       []string   @[omitempty]
}

// ScatterTrace is a struct for Scatter trace type
@[params]
pub struct ScatterTrace {
	CommonTrace
}

// PieTrace is a struct for Pie trace type
@[params]
pub struct PieTrace {
	CommonTrace
pub mut:
	values []f64    @[omitempty]
	labels []string @[omitempty]
}

// HeatmapTrace is a struct for Heatmap trace type
@[params]
pub struct HeatmapTrace {
	CommonTrace
pub mut:
	hovertemplate string @[omitempty]
	zsmooth       string @[omitempty]
}

// SurfaceTrace is a struct for Surface trace type
@[params]
pub struct SurfaceTrace {
	CommonTrace
pub mut:
	hovertemplate string @[omitempty]
}

// Scatter3DTrace is a struct for Scatter3D trace type
@[params]
pub struct Scatter3DTrace {
	CommonTrace
}

// BarTrace is a struct for Bar trace type
@[params]
pub struct BarTrace {
	CommonTrace
}

// HistogramTrace is a struct for Histogram trace type
@[params]
pub struct HistogramTrace {
	CommonTrace
pub mut:
	nbinsx   int    @[omitempty]
	nbinsy   int    @[omitempty]
	xbins    Bins   @[omitempty]
	histfunc string @[omitempty]
	marker   Marker @[omitempty]
}

// LineTrace is a struct for Line trace type
@[params]
pub struct LineTrace {
	CommonTrace
pub mut:
	connectgaps bool @[omitempty]
}

// BoxTrace is a struct for Box trace type
@[params]
pub struct BoxTrace {
	CommonTrace
pub mut:
	boxpoints   string @[omitempty] // 'all', 'outliers', 'suspectedoutliers', false
	boxmean     string @[omitempty] // true, 'sd'
	notched     bool   @[omitempty]
	orientation string @[omitempty] // 'v' or 'h'
	q1          []f64  @[omitempty]
	median      []f64  @[omitempty]
	q3          []f64  @[omitempty]
	lowerfence  []f64  @[omitempty]
	upperfence  []f64  @[omitempty]
}

// ViolinTrace is a struct for Violin trace type
@[params]
pub struct ViolinTrace {
pub mut:
	// Core violin fields
	x          []string   @[omitempty] // For grouped violin plots
	y          YType      @[omitempty]
	x0         string     @[omitempty] // Single x position for violin plots
	name       string     @[omitempty]
	marker     Marker     @[omitempty]
	line       Line       @[omitempty]
	colorscale string = 'Viridis'     @[omitempty]
	fillcolor  string     @[omitempty] // Fill color for violin
	opacity    f64        @[omitempty] // Opacity for violin

	// Violin-specific fields
	side        string @[omitempty] // 'both', 'positive', 'negative'
	bandwidth   f64    @[omitempty]
	orientation string @[omitempty] // 'v' or 'h'
	points      string @[omitempty] // 'all', 'outliers', 'suspectedoutliers', false
	box         Box    @[omitempty]
	meanline    Line   @[omitempty]
}

// ContourTrace is a struct for Contour trace type
@[params]
pub struct ContourTrace {
	CommonTrace
pub mut:
	contours     Contours @[omitempty]
	hovertemplate string   @[omitempty]
	autocontour  bool     @[omitempty]
	ncontours    int      @[omitempty]
}

// WaterfallTrace is a struct for Waterfall trace type
@[params]
pub struct WaterfallTrace {
	CommonTrace
pub mut:
	measure        []string @[omitempty] // 'relative', 'total', 'absolute'
	base           f64      @[omitempty]
	orientation    string   @[omitempty] // 'v' or 'h'
	connector      Connector @[omitempty]
	decreasing     Decreasing @[omitempty]
	increasing     Increasing @[omitempty]
	totals         Totals     @[omitempty]
}

// SunburstTrace is a struct for Sunburst trace type
@[params]
pub struct SunburstTrace {
	CommonTrace
pub mut:
	labels       []string @[omitempty]
	parents      []string @[omitempty]
	values       []f64    @[omitempty]
	branchvalues string   @[omitempty] // 'total', 'remainder'
	count        string   @[omitempty]
	ids          []string @[omitempty]
	level        string   @[omitempty]
	maxdepth     int      @[omitempty]
}

// TreemapTrace is a struct for Treemap trace type
@[params]
pub struct TreemapTrace {
	CommonTrace
pub mut:
	labels       []string @[omitempty]
	parents      []string @[omitempty]
	values       []f64    @[omitempty]
	branchvalues string   @[omitempty] // 'total', 'remainder'
	count        string   @[omitempty]
	ids          []string @[omitempty]
	level        string   @[omitempty]
	maxdepth     int      @[omitempty]
	pathbar      PathBar  @[omitempty]
}

// CandlestickTrace is a struct for Candlestick trace type
@[params]
pub struct CandlestickTrace {
	CommonTrace
pub mut:
	open         []f64      @[omitempty]
	high         []f64      @[omitempty]
	low          []f64      @[omitempty]
	close        []f64      @[omitempty]
	increasing   Increasing @[omitempty]
	decreasing   Decreasing @[omitempty]
	xperiod      string     @[omitempty]
	xperiodalignment string @[omitempty]
}

// FunnelTrace is a struct for Funnel trace type
@[params]
pub struct FunnelTrace {
	CommonTrace
pub mut:
	values       []f64  @[omitempty]
	orientation  string @[omitempty] // 'v' or 'h'
	connector    Connector @[omitempty]
}

// ScatterPolarTrace is a struct for Radar/Polar trace type
@[params]
pub struct ScatterPolarTrace {
	CommonTrace
pub mut:
	r      []f64  @[omitempty]
	theta  []f64  @[omitempty]
	thetaunit string @[omitempty] // 'radians', 'degrees'
	subplot   string @[omitempty]
}

// Marker is a struct for marker properties in a trace
pub struct Marker {
pub mut:
	size       []f64    @[omitempty]
	color      []string @[omitempty]
	opacity    f64    = 0.8      @[omitempty]
	colorscale string = 'Viridis'   @[omitempty]
}

// Line is a struct for line properties in a trace
pub struct Line {
pub mut:
	color   string @[omitempty]
	width   f64    = 2.0    @[omitempty]
	dash    string = 'solid' @[omitempty]
	visible bool   @[omitempty]
}

// Bins is a struct for bin limits in a histogram trace
pub struct Bins {
pub mut:
	start f64
	end   f64
	size  f64
}

// Box is a struct for box configuration in violin plots
pub struct Box {
pub mut:
	visible bool @[omitempty]
	width   f64  @[omitempty]
}

// Contours is a struct for contour configuration
pub struct Contours {
pub mut:
	start     f64    @[omitempty]
	end       f64    @[omitempty]
	size      f64    @[omitempty]
	coloring  string @[omitempty] // 'fill', 'heatmap', 'lines', 'none'
	showlines bool   @[omitempty]
	showlabels bool  @[omitempty]
}

// Connector is a struct for waterfall and funnel connectors
pub struct Connector {
pub mut:
	visible bool   @[omitempty]
	line    Line   @[omitempty]
	mode    string @[omitempty] // 'spanning', 'between'
}

// Decreasing is a struct for decreasing values styling
pub struct Decreasing {
pub mut:
	marker Marker @[omitempty]
	line   Line   @[omitempty]
}

// Increasing is a struct for increasing values styling
pub struct Increasing {
pub mut:
	marker Marker @[omitempty]
	line   Line   @[omitempty]
}

// Totals is a struct for totals styling in waterfall charts
pub struct Totals {
pub mut:
	marker Marker @[omitempty]
	line   Line   @[omitempty]
}

// PathBar is a struct for treemap pathbar configuration
pub struct PathBar {
pub mut:
	visible   bool   @[omitempty]
	side      string @[omitempty] // 'top', 'bottom'
	edgeshape string @[omitempty] // 'rounded', 'sharp'
	thickness int    @[omitempty]
}

// Trace is a sum type for representing different trace types
pub type Trace = BarTrace
	| BoxTrace
	| CandlestickTrace
	| ContourTrace
	| FunnelTrace
	| HeatmapTrace
	| HistogramTrace
	| LineTrace
	| PieTrace
	| Scatter3DTrace
	| ScatterPolarTrace
	| ScatterTrace
	| SunburstTrace
	| SurfaceTrace
	| TreemapTrace
	| ViolinTrace
	| WaterfallTrace

pub fn (t Trace) trace_type() string {
	return match t {
		BarTrace { 'bar' }
		HeatmapTrace { 'heatmap' }
		HistogramTrace { 'histogram' }
		PieTrace { 'pie' }
		Scatter3DTrace { 'scatter3d' }
		ScatterTrace { 'scatter' }
		SurfaceTrace { 'surface' }
		LineTrace { 'scatter' } // Line charts use scatter type with mode='lines'
		BoxTrace { 'box' }
		ViolinTrace { 'violin' }
		ContourTrace { 'contour' }
		WaterfallTrace { 'waterfall' }
		SunburstTrace { 'sunburst' }
		TreemapTrace { 'treemap' }
		CandlestickTrace { 'candlestick' }
		FunnelTrace { 'funnel' }
		ScatterPolarTrace { 'scatterpolar' }
	}
}
