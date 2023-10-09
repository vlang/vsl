module plot

// Layout
pub struct Layout {
pub mut:
	title       string
	title_x     f64  = 0.5
	autosize    bool = true
	width       int  = 650
	height      int  = 650
	xaxis       Axis
	yaxis       Axis
	annotations []Annotation
}
