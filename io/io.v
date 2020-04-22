// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module io

pub fn safe_print_int(format string, message int) string {
	buf := [byte(0)]
	mut ptr := &buf[0]
	C.sprintf(charptr(ptr), charptr(format.str), message)
	return tos(buf.data, vstrlen(buf.data)).trim_space()
}

pub fn safe_print_f64(format string, message f64) string {
	buf := [byte(0)]
	mut ptr := &buf[0]
	C.sprintf(charptr(ptr), charptr(format.str), message)
	return tos(buf.data, vstrlen(buf.data)).trim_space()
}

pub fn safe_print_string(format string, message string) string {
	buf := [byte(0)]
	mut ptr := &buf[0]
	C.sprintf(charptr(ptr), charptr(format.str), message)
	return tos(buf.data, vstrlen(buf.data)).trim_space()
}
