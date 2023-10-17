module plot

import arrays

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

pub fn (mut p Plot) scatter(trace ScatterTrace) Plot {
	p.traces << trace
	return p
}

pub fn (mut p Plot) pie(trace PieTrace) Plot {
	p.traces << trace
	return p
}

pub fn (mut p Plot) heatmap(trace HeatmapTrace) Plot {
	p.traces << trace
	return p
}

pub fn (mut p Plot) surface(trace SurfaceTrace) Plot {
	p.traces << trace
	return p
}

pub fn (mut p Plot) scatter3d(trace Scatter3DTrace) Plot {
	mut next_trace := trace
	z := next_trace.z
	if z is [][]f64 {
		next_trace.z = arrays.flatten(z)
	}
	p.traces << next_trace
	return p
}

pub fn (mut p Plot) bar(trace BarTrace) Plot {
	p.traces << trace
	return p
}

pub fn (mut p Plot) histogram(trace HistogramTrace) Plot {
	p.traces << trace
	return p
}

pub fn (mut p Plot) annotation(annotation Annotation) Plot {
	p.layout.annotations << annotation
	return p
}

pub fn (mut p Plot) layout(layout Layout) Plot {
	mut next_layout := layout
	// Ensure that the layout range is specified correctly
	if next_layout.xaxis.range.len != 2 {
		next_layout.xaxis.range = []f64{}
	}
	if next_layout.yaxis.range.len != 2 {
		next_layout.yaxis.range = []f64{}
	}
	p.layout = next_layout
	return p
}
