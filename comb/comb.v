module comb

import vsl.fun
import vsl.util

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

pub struct CombinationsIter {
mut:
	pos    int
	idxs   []int
pub:
	repeat int
	size   int
	data   []f64
}

// new_combinations_iter will return an iterator that allows
// lazy computation for all length `r` combinations of `data`
pub fn new_combinations_iter(data []f64, r int) CombinationsIter {
	n := data.len
	if r > n {
		return CombinationsIter{
			data: data
			repeat: r
		}
	}
	size := int(fun.choose(n, r))
	idxs := util.arange(r)
	return CombinationsIter{
		data: data
		repeat: r
		size: size
		idxs: idxs
	}
}

// next will return next combination if possible
pub fn (mut o CombinationsIter) next() ?[]f64 {
	// base case for every iterator
	if o.pos == o.size {
		return none
	}
	o.pos++
	if o.repeat == 1 {
		return [o.data[o.pos - 1]]
	}
	r := o.repeat
	n := o.data.len
	// extra case for optimization
	if o.pos == 1 {
		return o.data[0..r]
	}
	rev_range := util.arange(r).reverse()
	mut what_is_i := -1
	for i in rev_range {
		if o.idxs[i] != i + n - r {
			what_is_i = i
			break
		} else if i == 0 {
			return none
		}
	}
	o.idxs[what_is_i] = o.idxs[what_is_i] + 1
	for j in util.range(what_is_i + 1, r) {
		o.idxs[j] = o.idxs[j - 1] + 1
	}
	return util.get_many(o.data, o.idxs)
}

// combinations_with_replacement will return r length subsequences of elements from the
// input `data` allowing individual elements to be repeated more than once.
// This is as close a translation of python's [itertools.combinations_with_replacement]
// (https://docs.python.org/3.9/library/itertools.html#itertools.combinations_with_replacement)
// as I could manage.
// Using f64 array instead of generic while waiting on https://github.com/vlang/v/issues/7753
pub fn combinations_with_replacement(data []f64, r int) [][]f64 {
	n := data.len
	if (n == 0) && (r == 0) {
		return [][]f64{}
	} else if r > n {
		return [][]f64{}
	} else if r == 1 {
		return data.map([it])
	}
	mut indices := []int{len: r, init: 0}
	// Create the result
	n_combos := fun.n_combos_w_replacement(n, r)
	mut result := [][]f64{cap: int(n_combos)}
	// Add the first row
	result << util.get_many(data, indices)
	// Add the rest
	rev_range := util.arange(r).reverse()
	mut what_is_i := -1
	for {
		for i in rev_range {
			if indices[i] != n - 1 {
				what_is_i = i
				break
			} else if i == 0 {
				return result
			}
		}
		// This for loop mimics the python list slice
		new_val := indices[what_is_i] + 1
		for idx in what_is_i .. (indices.len) {
			indices[idx] = new_val
		}
		result << util.get_many(data, indices)
	}
	return result
}

