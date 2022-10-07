module plot

import json
import os
import time
import vsl.errors

const (
	schema_version = 'v1.0.2'
	venv_dir_name  = '.plotvenv_$schema_version'
	data_dir_name  = '.data_$schema_version'
)

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
