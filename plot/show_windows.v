module plot

pub fn (p Plot) show() ? {
	return error('not implemented')
}

// init will ensure that all dependencies are correctly installed and venv initiallized
fn init() {
	print(@MOD + ' is not working on widows yet')
}
