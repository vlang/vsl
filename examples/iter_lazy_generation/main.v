module main

import vsl.iter

fn main() {
	data := [1.0, 2.0, 3.0]
	r := 3
	mut count := 0

	mut combs := iter.CombinationsIter.new(data, r)

	for comb in combs {
		print(comb)
		count += 1
	}

	assert count == 3
}
