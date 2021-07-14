module fun

import vsl.vmath as math

// fib returns the nth number in the Fibonacci sequence using O(1) space
// in O(logn) time complexity
pub fn fib(n int) int {
	phi := (1. + math.sqrt(5.)) / 2.
	nth_fib := math.round(math.pow(phi, f64(n)) / math.sqrt(5.))
	return int(nth_fib)
}
