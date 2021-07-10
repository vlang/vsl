module errors

[inline]
pub fn error(reason string, errno ErrorCode) IError {
	return error_with_code(error_message(reason, errno), int(errno))
}

[inline]
pub fn vsl_panic(reason string, errno ErrorCode) {
	panic(error_message(reason, errno))
}

[inline]
pub fn error_message(reason string, errno ErrorCode) string {
	return 'vsl: $errno: $reason'
}
