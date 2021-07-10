module plot

import os
import json

import vsl.errors

pub struct Plot {
pub mut:
	traces		[]Trace
	layout		Layout
	// WIP: new properties will be added eventually.
}

pub fn (mut p Plot) add_trace(trace Trace) {
	p.traces << trace
}

pub fn (mut p Plot) add_annotation(anno Annotation) {
	p.layout.annotations << anno
}

pub fn (mut p Plot) set_layout(lyt Layout) {
	p.layout = lyt
}

pub fn (p Plot) show() {
	plot_str := json.encode_pretty(p.traces)

	venv_path := os.join_path(os.home_dir(), '.vmodules/vsl/plot/plotvenv')
	if !os.is_dir(venv_path) {
		// Print just in case vsl_panic throws a runtime error
		println('Plotly virtualenv not found. Run `bash ~/.vmodules/' +
		'vsl/plot/create-venv.sh` and try again.')
		errors.vsl_panic('', .efailed)
	}

	data_path := os.join_path(os.home_dir(), '.vmodules/vsl/plot/data.json')
	layout_path := os.join_path(os.home_dir(), '.vmodules/vsl/plot/layout.json')
	run_path := os.join_path(os.home_dir(), '.vmodules/vsl/plot/run.sh')

	os.write_file(data_path, plot_str) or {
		errors.vsl_panic('Could not save the plot to a JSON file.', .efailed)
	}
	layout_str := json.encode(p.layout)
	os.write_file(layout_path, layout_str) or {
		errors.vsl_panic('Could not save the layout to a JSON file.', .efailed)
	}
	os.execute_or_panic('bash ' + run_path)

	os.rm(data_path) or { }
	os.rm(layout_path) or { }
}
