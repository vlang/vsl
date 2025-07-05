module plot

// Layout
pub struct Layout {
pub mut:
	title         string
	title_x       f64
	autosize      bool
	width         int = 550
	height        int = 550
	xaxis         Axis
	yaxis         Axis
	annotations   []Annotation
	showlegend    bool     @[omitempty]
	plot_bgcolor  string   @[omitempty]
	paper_bgcolor string   @[omitempty]
	polar         Polar    @[omitempty]
}

// Polar layout for radar/polar charts
pub struct Polar {
pub mut:
	radialaxis  RadialAxis  @[omitempty]
	angularaxis AngularAxis @[omitempty]
	sector      []f64       @[omitempty]
	hole        f64         @[omitempty]
	bgcolor     string      @[omitempty]
}

// RadialAxis for polar plots
pub struct RadialAxis {
pub mut:
	visible   bool    @[omitempty]
	range     []f64   @[omitempty]
	tickvals  []f64   @[omitempty]
	ticktext  []string @[omitempty]
	tickangle f64     @[omitempty]
	showgrid  bool    @[omitempty]
	gridcolor string  @[omitempty]
	linecolor string  @[omitempty]
}

// AngularAxis for polar plots
pub struct AngularAxis {
pub mut:
	visible   bool     @[omitempty]
	tickvals  []f64    @[omitempty]
	ticktext  []string @[omitempty]
	direction string   @[omitempty] // 'clockwise' or 'counterclockwise'
	period    f64      @[omitempty]
	rotation  f64      @[omitempty]
	showgrid  bool     @[omitempty]
	gridcolor string   @[omitempty]
	linecolor string   @[omitempty]
}
