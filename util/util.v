module util

// range returns a list with int values in the interval [0, n)
pub fn arange(n int) []int {
	mut result := []int{cap: n}
	for i in 0 .. n {
		result << i
	}
	return result
}

@[params]
pub struct RangeStep {
	step int = 1
}

// range returns a list with int values in the interval [start, stop)
pub fn range(start int, stop int, params RangeStep) []int {
	step := params.step
	if step == 0 {
		return []int{}
	}
	mut result := []int{}
	mut val := -1
	for {
		val++
		new_val := start + (val * step)
		if step > 0 && new_val >= stop {
			break
		} else if step < 0 && new_val <= stop {
			break
		} else {
			result << new_val
		}
	}
	return result
}

// get_many returns an array containing the values in the given idxs
pub fn get_many[T](arr []T, idxs []int) []T {
	if idxs.len == 0 {
		return []T{}
	}
	mut result := []T{cap: idxs.len}
	for idx in idxs {
		result << arr[idx]
	}
	return result
}

// lin_space returns evenly spaced numbers over a specified closed interval.
pub fn lin_space(start f64, stop f64, num int) []f64 {
	if num <= 0 {
		return []f64{}
	}
	if num == 1 {
		return [start]
	}
	step := (stop - start) / f64(num - 1)
	mut res := []f64{len: num}
	res[0] = start
	for i in 1 .. num {
		res[i] = start + f64(i) * step
	}
	res[num - 1] = stop
	return res
}

// move_ith_to_end removes element at i from the array, and puts it at the end
// is O(n)(?) because we have to potentially shift all the elements if we remove the first
pub fn move_ith_to_end(mut arr []int, i int) {
	elt_t := arr[i]
	arr.delete(i)
	arr << elt_t
}
