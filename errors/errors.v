module errors

[inline]
pub fn vsl_error(reason string, errno ErrorCode) IError {
	return error_with_code('vsl: $errno: $reason', int(errno))
}

[inline]
pub fn vsl_panic(reason string, errno ErrorCode) {
	panic('vsl: $errno: $reason')
}

[inline]
pub fn vsl_error_message(reason string, errno ErrorCode) string {
	return 'vsl: $errno: $reason'
}

[inline]
pub fn vsl_panic_message(reason string, errno ErrorCode) string {
	return 'vsl: $errno: $reason'
}
