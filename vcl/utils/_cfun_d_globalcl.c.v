module utils

__global (
	cl_handle      = unsafe { nil }
	cl_sym_opt_map = map[string]voidptr{}
)

[inline]
pub fn get_cl_handle() voidptr {
	return cl_handle
}

[inline]
pub fn get_cl_sym_opt_map() map[string]voidptr {
	return cl_sym_opt_map
}

[inline]
pub fn set_cl_handle(h voidptr) {
	cl_handle = h
}

[inline]
pub fn set_cl_sym_opt_map(name string, func voidptr) {
	cl_sym_opt_map[name] = func
}
