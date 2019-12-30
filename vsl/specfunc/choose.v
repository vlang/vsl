// Copyright (c) 2019 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

module specfunc

import math
import math.factorial
import internal

/**
 * Compute the binomial coefficient
 *
 *      / n \        n!
 *      |   |  = ---------
 *      \ k /    k! (n-k)!
 *
 * @param n a non-negative integer
 * @param p a non-negative integer smaller that n
 *
 */
pub fn choose(n, p int) f64 {
        if n - p < 0 || n < 0 || p < 0 {
                return 0.0
        }

        n_f64 := f64(n)
        p_f64 := f64(p)

        k := math.max(p_f64, n_f64 - p_f64)

        if k < internal.max_int_fact_arg {
                return factorial.factorial(n_f64) /
                       (factorial.factorial(p_f64) * factorial.factorial(n_f64 - p_f64))
        }

        log_choose := factorial.log_factorial(n_f64 + 1.0)
                    - factorial.log_factorial(p_f64 + 1.0)
                    - factorial.log_factorial(n_f64 - p_f64 + 1.0)

        return math.exp(log_choose)
}
