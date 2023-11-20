module plot

import arrays

// Plot is the main structure that contains layout and traces
// to generate plots
pub struct Plot {
pub mut:
	traces []Trace
	layout Layout
}

pub fn Plot.new() &Plot {
	return &Plot{}
}

// add_trace adds a trace to the plot
@[inline]
fn (mut p Plot) add_trace[T](trace T) Plot {
	p.traces << trace
	return p
}

// scatter adds a scatter trace to the plot
@[inline]
pub fn (mut p Plot) scatter(trace ScatterTrace) Plot {
	return p.add_trace(trace)
}

// pie adds a pie trace to the plot
@[inline]
pub fn (mut p Plot) pie(trace PieTrace) Plot {
	return p.add_trace(trace)
}

// heatmap adds a heatmap trace to the plot
@[inline]
pub fn (mut p Plot) heatmap(trace HeatmapTrace) Plot {
	return p.add_trace(trace)
}

// surface adds a surface trace to the plot
@[inline]
pub fn (mut p Plot) surface(trace SurfaceTrace) Plot {
	return p.add_trace(trace)
}

// scatter3d adds a scatter3d trace to the plot.
// If the z value is a 2D array, it is flattened
// to a 1D array
@[inline]
pub fn (mut p Plot) scatter3d(trace Scatter3DTrace) Plot {
	mut next_trace := trace
	z := next_trace.z
	if z is [][]f64 {
		next_trace.z = arrays.flatten(z)
	}
	return p.add_trace(next_trace)
}

// bar adds a bar trace to the plot
@[inline]
pub fn (mut p Plot) bar(trace BarTrace) Plot {
	return p.add_trace(trace)
}

// histogram adds a histogram trace to the plot
@[inline]
pub fn (mut p Plot) histogram(trace HistogramTrace) Plot {
	return p.add_trace(trace)
}

// box adds a box trace to the plot
@[inline]
pub fn (mut p Plot) annotation(annotation Annotation) Plot {
	p.layout.annotations << annotation
	return p
}

// layout sets the layout of the plot
@[inline]
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
