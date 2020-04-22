// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module math

pub fn copysign(x, y f64) f64 {
	if (x < 0 && y > 0) || (x > 0 && y < 0) {
		return -x
	}
	return x
}

pub fn signbit(x f64) bool {
	return f64_bits(x) & (1 << 63) != 0
}
