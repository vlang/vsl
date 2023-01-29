module vcldl

struct GlobalDlContext {
mut:
	handle      voidptr
	sym_opt_map map[string]voidptr
}

const (
	global_ctx = &GlobalDlContext{}
)

[inline]
pub fn get_handle() ?voidptr {
	if !isnil(vcldl.global_ctx.handle) {
		return vcldl.global_ctx.handle
	}
	return none
}

[inline]
pub fn get_sym_opt(name string) ?voidptr {
	if sym := vcldl.global_ctx.sym_opt_map[name] {
		if !isnil(sym) {
			return sym
		}
	}
	return none
}

[inline]
pub fn set_handle(h voidptr) {
	mut ctx := unsafe { vcldl.global_ctx }
	ctx.handle = h
}

[inline]
pub fn set_sym_opt_map(name string, func voidptr) {
	mut ctx := unsafe { vcldl.global_ctx }
	ctx.sym_opt_map[name] = func
}
