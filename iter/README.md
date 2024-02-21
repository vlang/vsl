# Iterator Tools

This module provides two different ways of managing combinatorics.
Let see an example for `combinations`.

## Fully formed array of all Combinations

```v ignore
// combinations will return an array of all length `r` combinations of `data`
// While waiting on https://github.com/vlang/v/issues/7753 to be fixed, the function
// assumes f64 array input. Will be easy to change to generic later
pub fn combinations(data []f64, r int) [][]f64
```

## Lazy generation

This case is optimal to generate combinations in a lazy way, optimizing memory use:

```v ignore
// CombinationsIter.new will return an iterator that allows
// lazy computation for all length `r` combinations of `data`
pub fn CombinationsIter.new(data []f64, r int) CombinationsIter

// next will return next combination if possible
pub fn (mut o CombinationsIter) next() ?[]f64
```
