module comb

import vsl.util
import vsl.vmath as math

// permutations returns successive `r` length permutations of elements in `data`
pub fn permutations(data []f64, r int) [][]f64 {
	n := data.len
	if r > n {
		return [][]f64{}
	}
	mut indices := util.arange(n)
	mut cycles := util.stepped_range(n, n - r, -1)
	n_perms := u64(math.factorial(n) / math.factorial(n - r))
	mut result := [][]f64{cap: int(n_perms)}
	// Add first row
	result << util.get_many(data, indices[..r])
	rev_range := util.arange(r).reverse()
	// Add the rest of the rows
	for {
		for i in rev_range {
			cycles[i]--
			if cycles[i] == 0 {
				util.move_ith_to_end(mut indices, i)
				cycles[i] = n - 1
			} else {
				j := cycles[i]
				new_at_i := indices[indices.len - j]
				new_at_minus_j := indices[i]
				indices[i] = new_at_i
				indices[indices.len - j] = new_at_minus_j
				result << util.get_many(data, indices[..r])
				break
			}
			if i == 0 {
				return result
			}
		}
	}
	return result
}
