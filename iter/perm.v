module iter

import vsl.util
import math

pub struct PermutationsIter[T] {
mut:
	pos    u64
	idxs   []int
	cycles []int
pub:
	repeat int
	size   u64
	data   []T
}

// PermutationsIter.new will return an iterator that allows
// lazy computation for all length `r` permutations of `data`
pub fn PermutationsIter.new[T](data []T, r int) PermutationsIter[T] {
	n := data.len
	if r > n {
		return PermutationsIter[T]{
			data:   data
			repeat: r
		}
	}
	size := u64(math.factorial(n) / math.factorial(n - r))
	idxs := util.arange(n)
	cycles := util.range(n, n - r, step: -1)
	return PermutationsIter[T]{
		data:   data
		repeat: r
		size:   size
		idxs:   idxs
		cycles: cycles
	}
}

// next will return next permutation if possible
pub fn (mut o PermutationsIter[T]) next[T]() ?[]T {
	// base case for every iterator
	if o.pos == o.size {
		return none
	}
	o.pos++
	if o.pos == 1 {
		return util.get_many(o.data, o.idxs[..o.repeat])
	}
	if o.repeat == 1 {
		return [o.data[o.pos - 1]]
	}
	r := o.repeat
	n := o.data.len
	for i := r - 1; i >= 0; i-- {
		o.cycles[i]--
		if o.cycles[i] == 0 {
			util.move_ith_to_end(mut o.idxs, i)
			o.cycles[i] = n - i
		} else {
			j := o.cycles[i]
			new_at_i := o.idxs[o.idxs.len - j]
			new_at_minus_j := o.idxs[i]
			o.idxs[i] = new_at_i
			o.idxs[o.idxs.len - j] = new_at_minus_j
			return util.get_many(o.data, o.idxs[..r])
		}
	}
	return none
}

// permutations returns successive `r` length permutations of elements in `data`
pub fn permutations[T](data []T, r int) [][]T {
	mut perms := PermutationsIter.new[T](data, r)
	mut result := [][]T{cap: int(perms.size)}
	for perm in perms {
		result << perm
	}
	return result
}
