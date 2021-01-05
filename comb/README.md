# Combinatorics

This module provides two different ways of managing combinatorics.
Let see an example for `combinations`.

## Fully formed array of all Combinations

```v nofmt
// combinations will return an array of all length `r` combinations of `data`
// While waiting on https://github.com/vlang/v/issues/7753 to be fixed, the function
// assumes f64 array input. Will be easy to change to generic later
pub fn combinations(data []f64, r int) [][]f64
```

**Usage example**

```v
module main

import vsl.comb

fn main() {
	data := [1., 2., 3.]
	r := 3
	combs := comb.combinations(data, r)
	print(combs)
}
```

## Lazy generation

This case is optimal to generate combinations in a lazy way, optimizing memory use:

```v nofmt
// new_combinations_iter will return an iterator that allows
// lazy computation for all length `r` combinations of `data`
pub fn new_combinations_iter(data []f64, r int) CombinationsIter

// next will return next combination if possible
pub fn (mut o CombinationsIter) next() ?[]f64
```

**Usage example**

```v
module main

import vsl.comb

fn main() {
	data := [1., 2., 3.]
	r := 3
	mut combinations := comb.new_combinations_iter(data, r)
	for comb in combinations {
		print(comb)
	}
}
```
