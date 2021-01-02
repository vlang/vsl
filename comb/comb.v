module comb

import vsl.errno

// combinations will return an array of all length `r` combinations of `data`
// While waiting on https://github.com/vlang/v/issues/7753 to be fixed, the function 
// assumes f64 array input. Will be easy to change to generic later
pub fn combinations(data []f64, r int) [][]f64 {
	mut iter := new_combinations_iter(data, r)
	mut result := [][]f64{cap: iter.size}
	for _ in 0 .. iter.size {
		if comb := iter.next() {
			result << comb
		}
	}
	return result
}

// [0, stop)
fn arange(n int) []int {
	mut result := []int{cap: n}
	for i in 0 .. n {
		result << i
	}
	return result
}

// [start, stop)
fn range(start int, stop int) []int {
	if stop <= start {
		return []int{}
	}
	mut result := []int{cap: stop - start}
	for i in start .. stop {
		result << i
	}
	return result
}

// get_many returns an array containing the values in the given idxs
fn get_many<T>(arr []T, idxs []int) []T {
	if idxs.len == 0 {
		return []T{}
	}
	mut result := []T{cap: idxs.len}
	for idx in idxs {
		result << arr[idx]
	}
	return result
}
