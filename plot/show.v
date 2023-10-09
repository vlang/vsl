module plot

import json
import os
import time
import vsl.errors

const (
	schema_version = 'v1.0.3'
	venv_dir_name  = '.plotvenv_${schema_version}'
	data_dir_name  = '.data_${schema_version}'
)

pub fn (p Plot) show() ! {
	create_venv()!

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
	run_path := solve_mod_path('scripts', 'run.sh')

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
		result := os.execute('bash ${run_path} "${venv_path}" "${data_path}" "${layout_path}"')
		if result.exit_code != 0 {
			return error_with_code(result.output, result.exit_code)
		}
		println(result.output)
	}
}

// create_venv will ensure that all dependencies are correctly installed and venv initiallized
fn create_venv() ! {
	venv_path := solve_mod_path(plot.venv_dir_name)
	if !os.is_dir(venv_path) {
		println('Creating plotly virtualenv...')
	}
	init_path := solve_mod_path('scripts', 'create-venv.sh')
	result := os.execute('bash ${init_path} "${venv_path}"')
	if result.exit_code != 0 {
		return errors.error(result.output, .efailed)
	}
}

fn solve_mod_path(dirs ...string) string {
	return os.join_path(@VMODROOT, ...dirs)
}
