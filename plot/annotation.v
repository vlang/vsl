module plot

// Annotation handles all the information needed to annotate plots
pub struct Annotation {
pub mut:
	x          f64    @[omitempty]
	y          f64    @[omitempty]
	text       string @[required]
	showarrow  bool
	arrowhead  int    @[omitempty]
	arrowcolor string @[omitempty]
	align      string @[omitempty]
	font       Font
}
