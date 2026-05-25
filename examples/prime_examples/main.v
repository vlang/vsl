module main

import vsl.prime

fn main() {
	println('== primality checks ==')
	for n in [2, 3, 4, 17, 21, 97] {
		println('${n} -> ${prime.is_prime(n)}')
	}

	println('\n== prime sieve (< 49) ==')
	primes_under_49 := prime.prime_sieve(49) or { panic(err) }
	println(primes_under_49)

	println('\ncount: ${primes_under_49.len}')
	println('first: ${primes_under_49[0]}, last: ${primes_under_49[primes_under_49.len - 1]}')
}
