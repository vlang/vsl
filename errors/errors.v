module errors

// error exposes this operation as part of the public API.

// error exposes this operation as part of the public API.
@[inline]
pub fn error(reason string, error_code ErrorCode) IError {
	return error_with_code(error_message(reason, error_code), int(error_code))
}

// vsl_panic exposes this operation as part of the public API.

// vsl_panic exposes this operation as part of the public API.
@[inline]
pub fn vsl_panic(reason string, error_code ErrorCode) {
	panic(error_message(reason, error_code))
}

// error_message exposes this operation as part of the public API.

// error_message exposes this operation as part of the public API.
@[inline]
pub fn error_message(reason string, error_code ErrorCode) string {
	return 'VSL Error: (${error_code}) ${reason}'
}
