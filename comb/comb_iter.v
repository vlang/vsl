module comb

import vsl.fun
import vsl.util

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
