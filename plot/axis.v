module plot

// Axis handles axis data
pub struct Axis {
pub mut:
	title       AxisTitle
	tickmode    string = 'auto'
	tick0       f64      @[omitempty]
	dtick       f64      @[omitempty]
	tickvals    []f64    @[omitempty]
	ticktext    []string @[omitempty]
	range       []f64    @[omitempty]
	showgrid    bool     @[omitempty]
	tickangle   f64      @[omitempty]
	scaleanchor string   @[omitempty]
	rangeslider RangeSlider @[omitempty]
}

// AxisTitle handles needed data to render an axis title
pub struct AxisTitle {
pub mut:
	text string
}

// RangeSlider handles range slider configuration for axes
pub struct RangeSlider {
pub mut:
	visible bool @[omitempty]
	range   []f64 @[omitempty]
	thickness f64 @[omitempty]
}
