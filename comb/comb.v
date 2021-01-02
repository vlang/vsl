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
