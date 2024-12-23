module iter

import vsl.fun
import vsl.util

// combinations will return an array of all length `r` combinations of `data`
pub fn combinations[T](data []T, r int) [][]T {
	mut combinations := CombinationsIter.new(data, r)
	mut result := [][]T{cap: int(combinations.size)}
	for comb in combinations {
		result << comb
	}
	return result
}

pub struct CombinationsIter[T] {
mut:
	pos  u64
	idxs []int
pub:
	repeat int
	size   u64
	data   []T
}

// CombinationsIter.new will return an iterator that allows
// lazy computation for all length `r` combinations of `data`
pub fn CombinationsIter.new[T](data []T, r int) CombinationsIter[T] {
	n := data.len
	if r > n {
		return CombinationsIter[T]{
			data:   data
			repeat: r
		}
	}
	size := u64(fun.choose(n, r))
	idxs := util.arange(r)
	return CombinationsIter[T]{
		data:   data
		repeat: r
		size:   size
		idxs:   idxs
	}
}

// next will return next combination if possible
pub fn (mut o CombinationsIter[T]) next() ?[]T {
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
	mut what_is_i := -1
	for i := r - 1; i >= 0; i-- {
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
pub fn combinations_with_replacement[T](data []T, r int) [][]T {
	mut combinations := CombinationsWithReplacementIter.new(data, r)
	mut result := [][]T{cap: int(combinations.size)}
	for comb in combinations {
		result << comb
	}
	return result
}

pub struct CombinationsWithReplacementIter[T] {
mut:
	pos  u64
	idxs []int
pub:
	repeat int
	size   u64
	data   []T
}

// CombinationsWithReplacementIter.new will return an iterator that allows
// lazy computation for all length `r` combinations with replacement of `data`
pub fn CombinationsWithReplacementIter.new[T](data []T, r int) CombinationsWithReplacementIter[T] {
	n := data.len
	if r > n {
		return CombinationsWithReplacementIter[T]{
			data:   data
			repeat: r
		}
	}
	size := fun.n_combos_w_replacement(n, r)
	idxs := []int{len: r, init: 0}
	return CombinationsWithReplacementIter[T]{
		data:   data
		repeat: r
		size:   size
		idxs:   idxs
	}
}

// next will return next combination if possible
pub fn (mut o CombinationsWithReplacementIter[T]) next[T]() ?[]T {
	// base case for every iterator
	if o.pos == o.size {
		return none
	}
	o.pos++
	if o.pos == 1 {
		return util.get_many(o.data, o.idxs)
	}
	if o.repeat == 1 {
		return [o.data[o.pos - 1]]
	}
	r := o.repeat
	n := o.data.len
	mut what_is_i := -1
	for i := r - 1; i >= 0; i-- {
		if o.idxs[i] != n - 1 {
			what_is_i = i
			break
		} else if i == 0 {
			return none
		}
	}
	// This for loop mimics the python list slice
	new_val := o.idxs[what_is_i] + 1
	for idx in what_is_i .. (o.idxs.len) {
		o.idxs[idx] = new_val
	}
	return util.get_many(o.data, o.idxs)
}
