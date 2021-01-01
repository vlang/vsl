module combinatorics

import math.factorial

// n_choose_k calculates the [binomial coefficient](https://mathworld.wolfram.com/BinomialCoefficient.html)
pub fn n_choose_k(n f64, k f64) int {
	if (k < 0.0) || (k > n) {
		eprintln('k is outside range 0 <= k < n')
		return 0
	} else if k == n {
		return 1
	}
	numerator := factorial.factorial(n)
	denominator := factorial.factorial(k) * factorial.factorial(n - k)
	return int(numerator / denominator)
}

// combinations will return an array of all length `r` combinations of `data`
// This is as close a translation of the example algorithm listed with python's 
// [itertools.combinations]
// (https://docs.python.org/3.9/library/itertools.html?highlight=combinations#itertools.combinations)
// as I could manage
// While waiting on https://github.com/vlang/v/issues/7753 to be fixed, the function 
// assumes int array input. Will be easy to change to generic later
pub fn combinations(data []int, r int) [][]int {
	// Return quickly when possible
	n := data.len
	if r > n {
		return [][]int{}
	} else if r == 1 {
		return data.map([it])
	}
	// Create the empty result with correct capacity
	n_combos := n_choose_k(n, r)
	mut result := [][]int{cap: n_combos}
	// Fill the first row of the result
	result << data[0..r]
	// Fill the rest of the rows
	mut indices := arange(r)
	rev_range := arange(r).reverse()
	for {
		mut what_is_i := -1
		for i in rev_range {
			if indices[i] != i + n - r {
				what_is_i = i
				break
			} else if i == 0 {
				return result
			}
		}
		indices[what_is_i] = indices[what_is_i] + 1
		for j in arange_start_stop(what_is_i + 1, r) {
			indices[j] = indices[j - 1] + 1
		}
		result << get_many(data, indices)
	}
	return result
}

// [0, stop)
fn arange(n int) []int {
	mut result := []int{cap: n}
	for idx in 0 .. n {
		result << idx
	}
	return result
}

// [start, stop)
fn arange_start_stop(start int, stop int) []int {
	if stop <= start {
		return []int{}
	}
	mut result := []int{cap: stop - start}
	for idx in start .. stop {
		result << idx
	}
	return result
}

fn get_many<T>(arr []T, inds []int) []T {
	if inds.len == 0 {
		return []T{}
	}
	mut result := []T{cap: inds.len}
	for idx in inds {
		result << arr[idx]
	}
	return result
}
