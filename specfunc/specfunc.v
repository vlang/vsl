// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module specfunc

import vsl.vmath

fn is_neg_int(x f64) bool {
	if x < 0 {
		_, xf := vmath.modf(x)
		return xf == 0
	}
	return false
}
