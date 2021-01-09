module comb

import vsl.util
import vsl.vmath as math

pub struct PermutationsIter {
	rev_range []int
mut:
	pos       u64
	idxs      []int
	cycles    []int
pub:
	repeat    int
	size      u64
	data      []f64
}

// new_permutations_iter will return an iterator that allows
// lazy computation for all length `r` permutations of `data`
pub fn new_permutations_iter(data []f64, r int) PermutationsIter {
	n := data.len
	if r > n {
		return PermutationsIter{
			data: data
			repeat: r
		}
	}
	size := u64(math.factorial(n) / math.factorial(n - r))
	idxs := util.arange(n)
	cycles := util.stepped_range(n, n - r, -1)
	return PermutationsIter{
		data: data
		repeat: r
		size: size
		idxs: idxs
		cycles: cycles
		rev_range: util.arange(r).reverse()
	}
}

// next will return next permutation if possible
pub fn (mut o PermutationsIter) next() ?[]f64 {
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
	mut what_is_i := -1
	for i in o.rev_range {
		o.cycles[i]--
		if o.cycles[i] == 0 {
			util.move_ith_to_end(mut o.idxs, i)
			o.cycles[i] = n - 1
		} else {
			j := o.cycles[i]
			new_at_i := o.idxs[o.idxs.len - j]
			new_at_minus_j := o.idxs[i]
			o.idxs[i] = new_at_i
			o.idxs[o.idxs.len - j] = new_at_minus_j
			return util.get_many(o.data, o.idxs[..r])
		}
		if i == 0 {
			return none
		}
	}
}

// permutations returns successive `r` length permutations of elements in `data`
pub fn permutations(data []f64, r int) [][]f64 {
	mut permutationsiter := new_permutations_iter(data, r)
	mut result := [][]f64{cap: int(permutationsiter.size)}
	for perm in permutationsiter {
		result << perm
	}
	return result
}
