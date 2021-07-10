module plot

pub struct Axis {
pub mut:
	title		AxisTitle
	tickmode	string		= 'auto'
	tick0		f64
	dtick		f64
	tickvals	[]f64
	ticktext	[]string
	// WIP: new properties will be added eventually.
}

pub struct AxisTitle {
pub mut:
	text		string
	// WIP: new properties will be added eventually.
}
