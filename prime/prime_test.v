module prime

import math

fn test_is_prime() {
	// true
	assert is_prime(2)
	assert is_prime(3)
	assert is_prime(5)

	// false
	assert is_prime(0) == false
	assert is_prime(1) == false
	assert is_prime(6) == false

	// bigger
	// true
	assert is_prime(7_691)
	assert is_prime(524_287)
	assert is_prime(int(max_i32))

	// false
	assert is_prime(int(max_i32) - 1) == false
}

fn test_prime_sieve() {
	assert prime_sieve(20)! == [2, 3, 5, 7, 11, 13, 17, 19]
}
