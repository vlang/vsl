// Copyright (c) 2019-2020 Ulises Jeremias Cornejo Fandos. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module specfunc

import vsl.math
import vsl.internal

/*
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
pub fn choose(n int, p int) f64 {
	if n - p < 0 || n < 0 || p < 0 {
		return 0.0
	}
	n_f64 := f64(n)
	p_f64 := f64(p)
	k := math.max(p_f64, n_f64 - p_f64)
	if k < internal.max_int_fact_arg {
		return math.factorial(n_f64) / (math.factorial(p_f64) * math.factorial(n_f64 - p_f64))
	}
	log_choose := math.log_factorial(n_f64 + 1.0) - math.log_factorial(p_f64 + 1.0) - math.log_factorial(n_f64 -
		p_f64 + 1.0)
	return math.exp(log_choose)
}
