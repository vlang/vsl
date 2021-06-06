module errors

[inline]
pub fn vsl_error(reason string, errno ErrorCode) IError {
	estr := errno.str()
	return error_with_code('vsl: $estr: $reason', int(errno))
}

[inline]
pub fn vsl_panic(reason string, errno ErrorCode) {
	estr := errno.str()
	panic('vsl: $estr: $reason')
}

[inline]
pub fn vsl_error_message(reason string, errno ErrorCode) string {
	estr := errno.str()
	return 'vsl: $estr: $reason'
}

[inline]
pub fn vsl_panic_message(reason string, errno ErrorCode) string {
	estr := errno.str()
	return 'vsl: $estr: $reason'
}
