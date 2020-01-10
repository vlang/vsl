// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module io

pub fn safe_print<T>(format string, message T) string {
	buf := [byte(0)]
	mut ptr := &buf[0]
	C.sprintf(charptr(ptr), charptr(format.str), message)
	return tos(buf.data, vstrlen(buf.data)).trim_space()
}
