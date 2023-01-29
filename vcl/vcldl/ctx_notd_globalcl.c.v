module vcldl

[inline]
pub fn get_cl_handle() voidptr {
	return unsafe { nil }
}

[inline]
pub fn get_cl_sym_opt_map() map[string]voidptr {
	return map[string]voidptr{}
}

[inline]
pub fn set_cl_handle(h voidptr) {
}

[inline]
pub fn set_cl_sym_opt_map(name string, func voidptr) {
}
