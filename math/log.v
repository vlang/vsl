// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module math

#include <math.h>

fn C.log(x f64) f64

pub fn log(x f64) f64 {
        return C.log(x)
}

pub fn log_n(x, b f64) f64 {
        y := log(x)
        z := log(b)

        return y/z
}

pub fn log1p(x f64) f64 {
        y := f64(1.0) + x
        z := y - f64(1.0)

        return log(y) - (z - x) / y /* cancels errors with IEEE arithmetic */
}
