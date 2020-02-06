// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module math

// Returns the absolute value.
pub fn abs(x f64) f64 {
        return if x > 0 { x } else { -x }
}
