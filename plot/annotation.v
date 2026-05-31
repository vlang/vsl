module plot

// Annotation handles all the information needed to annotate plots
pub struct Annotation {
pub mut:
	x          f64    @[omitempty]
	y          f64    @[omitempty]
	xanchor    string @[omitempty] // 'left', 'center', 'right' - horizontal text alignment
	yanchor    string @[omitempty] // 'top', 'middle', 'bottom' - vertical text alignment
	text       string @[required]
	showarrow  bool
	arrowhead  int    @[omitempty]
	arrowcolor string @[omitempty]
	align      string @[omitempty] // 'left', 'center', 'right' - text align within the annotation box
	font       Font
}
