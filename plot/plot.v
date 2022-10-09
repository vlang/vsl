module plot

import os

const (
	schema_version = 'v1.0.2'
	venv_dir_name  = '.plotvenv_$schema_version'
	data_dir_name  = '.data_$schema_version'
)

// init will ensure that all dependencies are correctly installed and venv initiallized
fn init() {
	$if windows ? {
		print(@MOD + ' is not working on widows yet')
		return
	}
	venv_path := solve_mod_path(plot.venv_dir_name)
	if !os.is_dir(venv_path) {
		println('Creating plotly virtualenv...')
	}
	init_path := solve_mod_path('create-venv.sh')
	result := os.execute('bash $init_path "$venv_path"')
	if result.exit_code != 0 {
		panic(result.output)
	}
	println(result.output)
}

fn solve_mod_path(dirs ...string) string {
	return os.join_path(@VMODROOT, ...dirs)
}

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
