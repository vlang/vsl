module fun

import math
import vsl.internal

// Compute the binomial coefficient
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
	log_choose := math.log_factorial(n_f64 + 1.0) - math.log_factorial(p_f64 + 1.0) - math.log_factorial(
		n_f64 - p_f64 + 1.0)
	return math.exp(log_choose)
}
