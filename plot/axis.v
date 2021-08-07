module plot

// Axis handles axis data
pub struct Axis {
pub mut:
	title    AxisTitle
	tickmode string = 'auto'
	tick0    f64
	dtick    f64
	tickvals []f64
	ticktext []string
}

// AxisTitle handles needed data to render an axis title
pub struct AxisTitle {
pub mut:
	text string
}
