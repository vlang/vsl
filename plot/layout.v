module plot

// Layout
pub struct Layout {
pub mut:
	title       string
	title_x     f64  = 0.5
	autosize    bool = true
	width       int  = 500
	height      int  = 500
	xaxis       Axis
	yaxis       Axis
	annotations []Annotation
}
