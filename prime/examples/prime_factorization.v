// A simple prime factorizer
module main

import vsl.prime
import os

fn spf(x int) ?int {
	sieve := prime.prime_sieve(x)?
	for p in sieve {
		if x % p == 0 {
			return p
		}
	}
	return x
}

fn factorize(y int) ?[]int {
	mut n := y
	mut factors := []int{}
	for n != 1 {
		x := spf(n)?
		factors << x
		n /= x
	}
	return factors
}

fn main() {
	mut n := os.input('').int()
	factors := factorize(n)?
	for f in factors {
		print('$f ')
	}
	println('')
}
