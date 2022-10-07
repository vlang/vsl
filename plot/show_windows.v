module plot

import vsl.errors

pub fn (p Plot) show() ? {
	$if !test ? {
		return errors.error('not implemented', .efailed)
	}
}

// init will ensure that all dependencies are correctly installed and venv initiallized
fn init() {
	print(@MOD + ' is not working on widows yet')
}
