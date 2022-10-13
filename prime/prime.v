module prime

import math

// is_prime returns if an int is prime (deterministically)
pub fn is_prime(p int) bool {
	if p < 2 {
		return false
	}
	mut i := 2
	for i <= math.floor(p / 2) {
		rem := p % i
		if rem != 0 {
			i++
		} else {
			return false
		}
	}
	return true
}

// prime sieve returns a list of primes up the number specified
pub fn prime_sieve(range int) ?[]int {
	if range <= 1 {
		return error('Range must be greater than 1')
	}
	mut number_list := []bool{len: range, init: true}
	number_list[0] = false
	number_list[1] = false
	mut primes := []int{cap: range / 2}

	for i in 2 .. int(math.sqrt(range)) {
		if number_list[i] {
			for j := i * i; j < range; j += i {
				number_list[j] = false
			}
		}
	}
	for i, n in number_list {
		if n {
			primes << i
		}
	}
	return primes
}
