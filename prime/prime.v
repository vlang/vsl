module prime

import math
// is_prime returns if an int is prime (deterministically)

pub fn is_prime(p int) bool {
	if p < 2 || p % 2 == 0 {
		return p == 2
	}
	mut i := 3
	max := math.floor(math.sqrt(p))
	for i <= max {
		rem := p % i
		if rem == 0 {
			return false
		}
		i += 2
	}
	return true
}

// prime sieve returns a list of primes up the number specified
pub fn prime_sieve(range int) ![]int {
	if range <= 1 {
		return error('Range must be greater than 1')
	}
	mut number_list := []bool{len: range, init: (index % 2 != 0)}
	number_list[0] = false
	number_list[1] = false
	number_list[2] = true
	mut primes := []int{cap: int(range / 6)}

	for i := 3; i < int(math.sqrt(range)); i += 2 {
		if number_list[i] {
			for j := i * i; j < range; j += i {
				number_list[j] = false
			}
		}
	}
	primes << 2
	for i := 3; i < range; i += 2 {
		if number_list[i] {
			primes << i
		}
	}
	return primes
}
