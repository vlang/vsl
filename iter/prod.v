module iter

import arrays

pub struct ProductIterator {
	repeat_lengths []u64
	size           u64
mut:
	indices_to_grab []int
	idx             u64
pub:
	data [][]f64
}

pub fn ProductIterator.new(data [][]f64) ProductIterator {
	return ProductIterator{
		repeat_lengths:  calc_repeat_lengths(data.map(it.len)).map(u64(it))
		indices_to_grab: []int{len: data.len, init: -1}
		data:            data
		size:            u64(arrays.fold(data.map(it.len), 1, int_prod))
	}
}

pub fn (mut o ProductIterator) next() ?[]f64 {
	if o.idx == o.size {
		return none
	}
	mut result := []f64{cap: o.data.len}
	is_time_to_inc := o.repeat_lengths.map(o.idx % it == 0)
	o.idx++
	for inc_idx, change in is_time_to_inc {
		if change {
			o.indices_to_grab[inc_idx]++
		}
		result << o.data[inc_idx][o.indices_to_grab[inc_idx] % o.data[inc_idx].len]
	}
	return result
}

// Cartesian product of the arrays in `data`
pub fn product(data [][]f64) [][]f64 {
	products := ProductIterator.new(data)
	mut result := [][]f64{cap: int(products.size)}
	for prod in products {
		result << prod
	}
	return result
}

fn int_prod(a int, b int) int {
	return a * b
}

// The idea here is that we pass in an array of the lengths of a bunch of arrays, and we
// get how long an item from the i_th array should repeat before moving onto the next
// item in that array
// e.g. if our arrays are `data := [[1,2],[3,4,5],[6,7]]`
// and the lengths are `data_lens := data.map(it.len)`
// So the array [6,7] flips every time, the array [3,4,5] changes when the array [6,7]
// has been fully iterated over, and finally the array [1,2] flips every 2*3=6 times
// so `calc_repeat_lengths(data.map(it.len)) == [6, 2, 1]`
// or if `data := [[1],[3,4],[2,3,4,5]]`, then
// `calc_repeat_lengths(data.map(it.len)) == [8, 4, 1]`
fn calc_repeat_lengths(data_lens []int) []int {
	mut result := []int{cap: data_lens.len}
	// First item will always be 1
	result << 1
	for idx, len in data_lens.reverse() {
		result << result[idx] * len
	}
	// Remove unnecssary item at the end
	result.delete_last()
	return result.reverse()
}
