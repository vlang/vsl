// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

module diff

import math
import vsl
import vsl.internal

pub fn diff_backward(f vsl.Function, x f64) (f64, f64) {
        /* Construct a divided difference table with a fairly large step
         * size to get a very rough estimate of f''. Use this to estimate
         * the step size which will minimize the error in calculating f'.
         */

        mut h := internal.sqrt_dbl_epsilon
        mut a := [f64(0.0)].repeat(3)
        mut d := [f64(0.0)].repeat(3)

        mut k := 0
        mut i := 0

        /* Algorithm based on description on pg. 204 of Conte and de Boor
         * (CdB) - coefficients of Newton form of polynomial of degree 2.
         */

        for i = 0; i < 3; i++ {
                a[i] = x + (f64(i) - 2.0) * h
                d[i] = f.eval(a[i])
        }

        for k = 1; k < 4; k++ {
                for i = 0; i < 3 - k; i++ {
                        d[i] = (d[i + 1] - d[i])/(a[i + k] - a[i])
                }
        }

        /* Adapt procedure described on pg. 282 of CdB to find best value of
         * step size.
         */

        mut a2 := math.abs(d[0] + d[1] + d[2])

        if a2 < 100.0 * internal.sqrt_dbl_epsilon {
                a2 = 100.0 * internal.sqrt_dbl_epsilon
        }

        h = math.sqrt(internal.sqrt_dbl_epsilon/(2.0 * a2))

        if h > 100.0 * internal.sqrt_dbl_epsilon {
                h = 100.0 * internal.sqrt_dbl_epsilon
        }

        return (f.eval(x) - f.eval(x - h))/h, math.abs(10.0 * a2 * h)
}
