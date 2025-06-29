module dl

import dl.loader

pub const dl_no_path_issue_code = loader.dl_no_path_issue_code
pub const dl_open_issue_code = loader.dl_open_issue_code
pub const dl_sym_issue_code = loader.dl_sym_issue_code
pub const dl_close_issue_code = loader.dl_close_issue_code
pub const dl_register_issue_code = loader.dl_register_issue_code

fn get_or_create_dynamic_lib_loader() !&loader.DynamicLibLoader {
	return loader.get_or_create_dynamic_lib_loader(
		key:      @MOD + '.' + 'LibOpenCL'
		env_path: 'VCL_LIBOPENCL_PATH'
		paths:    default_paths
	)
}

fn cleanup() {
	mut dl_loader := get_or_create_dynamic_lib_loader() or { return }
	dl_loader.unregister()
}

fn init() {
	mut dl_loader := get_or_create_dynamic_lib_loader() or { return }
	dl_loader.open() or { return }
}

pub fn get_sym(name string) !voidptr {
	mut dl_loader := get_or_create_dynamic_lib_loader()!
	return dl_loader.get_sym(name)
}
