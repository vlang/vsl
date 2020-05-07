// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module errno

[inline]
pub fn vsl_error<T>(reason string, errno Errno) ?T {
	estr := str_error(errno)
	return error('vsl: $estr: $reason')
}

[inline]
pub fn vsl_panic(reason string, errno Errno) {
	estr := str_error(errno)
	panic('vsl: $estr: $reason')
}

[inline]
pub fn vsl_error_message(reason string, errno Errno) string {
	estr := str_error(errno)
	return 'vsl: $estr: $reason'
}

[inline]
pub fn vsl_panic_message(reason string, errno Errno) string {
	estr := str_error(errno)
	return 'vsl: $estr: $reason'
}
