module plot

// Annotation handles all the information needed to annotate plots
pub struct Annotation {
pub mut:
	x          f64
	y          f64
	text       string [omitempty]
	showarrow  bool   [omitempty]
	arrowhead  int    [omitempty]
	arrowcolor string [omitempty]
	align      string [omitempty]
	font       Font
}
