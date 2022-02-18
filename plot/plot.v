module plot

import json
import os
import time
import vsl.errors

const (
	schema_version = 'v1'
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

pub fn (p Plot) show() ? {
	ts := time.now().format_ss_micro()
	plot_str := json.encode_pretty(p.traces)

	venv_path := solve_mod_path(plot.venv_dir_name)
	if !os.is_dir(venv_path) {
		return errors.error('plotly virtualenv not found', .efailed)
	}

	data_dir_path := solve_mod_path(plot.data_dir_name)
	if !os.is_dir(data_dir_path) {
		os.mkdir(data_dir_path) or {
			return errors.error('could not create needed dir path at ${data_dir_path}.',
				.efailed)
		}
	}

	data_path := solve_mod_path(plot.data_dir_name, 'data-${ts}.json')
	layout_path := solve_mod_path(plot.data_dir_name, 'layout-${ts}.json')
	run_path := solve_mod_path('run.sh')

	os.write_file(data_path, plot_str) or {
		return errors.error('could not save the plot to a JSON file at ${data_path}.',
			.efailed)
	}
	layout_str := json.encode(p.layout)
	os.write_file(layout_path, layout_str) or {
		return errors.error('could not save the layout to a JSON file at ${layout_path}.',
			.efailed)
	}
	$if !test ? {
		result := os.execute('bash $run_path --venv="$venv_path" --data="$data_path" --layout="$layout_path"')
		if result.exit_code != 0 {
			return error_with_code(result.output, result.exit_code)
		}
		println(result.output)
	}
}

// init will ensure that all dependencies are correctly installed and venv initiallized
fn init() {
	venv_path := solve_mod_path(plot.venv_dir_name)
	if !os.is_dir(venv_path) {
		println('Creating plotly virtualenv...')
	}
	init_path := solve_mod_path('create-venv.sh')
	result := os.execute('bash $init_path --venv="$venv_path"')
	if result.exit_code != 0 {
		panic(result.output)
	}
	println(result.output)
}

fn solve_mod_path(dirs ...string) string {
	return os.join_path(@VMODROOT, ...dirs)
}
