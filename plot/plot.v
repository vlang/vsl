module plot

// Plot is the main structure that contains layout and traces
// to generate plots
pub struct Plot {
pub mut:
	traces []Trace
	layout Layout
}

pub fn new_plot() Plot {
	return Plot{}
}

pub fn (mut p Plot) add_trace(trace Trace) Plot {
	p.traces << trace
	return p
}

pub fn (mut p Plot) add_annotation(annotation Annotation) Plot {
	p.layout.annotations << annotation
	return p
}

pub fn (mut p Plot) set_layout(layout Layout) Plot {
	p.layout = layout
	return p
}
