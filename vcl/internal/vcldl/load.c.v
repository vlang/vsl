module vcldl

import dl
import os

pub const (
	dl_open_issue    = 1
	dl_sym_opt_issue = 2
)

fn cleanup() {
	dl_close()
}

fn init() {
	dl_open() or { return }
}

pub fn dl_open() !voidptr {
	if ctx_handle := get_handle() {
		return ctx_handle
	}

	if vcl_path := os.getenv_opt('VCL_LIBOPENCL_PATH') {
		for path in vcl_path.split(':') {
			if handle := dl.open_opt(path, dl.rtld_lazy) {
				set_handle(handle)
				return handle
			}
		}
	}

	for path in default_paths {
		if handle := dl.open_opt(path, dl.rtld_lazy) {
			set_handle(handle)
			return handle
		}
	}

	return error('Could not find OpenCL library')
}

pub fn dl_close() {
	if handle := get_handle() {
		dl.close(handle)
		set_handle(unsafe { nil })
	}
}

pub fn dl_sym_opt(name string) !voidptr {
	if sym := get_sym_opt(name) {
		return sym
	}
	handle := dl_open() or { return error_with_code('', vcldl.dl_open_issue) }
	sym := dl.sym_opt(handle, name) or {
		dl_close()
		return error_with_code('', vcldl.dl_sym_opt_issue)
	}
	set_sym_opt_map(name, sym)
	return sym
}
