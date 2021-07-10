module plot

pub struct Annotation {
pub mut:
	x			f64
	y			f64
	text		string
	showarrow	bool
	arrowhead	int
	arrowcolor	string = 'black'
	align		string = 'center'
	font		Font
	// WIP: new properties will be added eventually.
}
