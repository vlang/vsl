module plot

// Layout
pub struct Layout {
pub mut:
	title       string
	title_x     f64
	autosize    bool
	width       int = 550
	height      int = 550
	xaxis       Axis
	yaxis       Axis
	annotations []Annotation
}
