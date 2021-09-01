# Probability Distributions algorithms

## Histograms

```v ignore
// Histogram holds data for computing/plotting histograms
//
//  bin[i] corresponds to station[i] <= x < station[i+1]
//
//       [ bin[0] )[ bin[1] )[ bin[2] )[ bin[3] )[ bin[4] )
//    ---|---------|---------|---------|---------|---------|---  x
//     s[0]      s[1]      s[2]      s[3]      s[4]      s[5]
//
pub struct Histogram {
pub mut:
	stations []f64 // stations
	counts   []int     // counts
}
```

### Usage Example

```v
module main

import vsl.dist

fn main() {
	lims := [0.0, 1, 2, 3, 4, 5]

	mut hist := dist.new_histogram(lims)

	hist.count([
		0.0,
		0.1,
		0.2,
		0.3,
		0.9,
		1,
		1,
		1,
		1.2,
		1.3,
		1.4,
		1.5,
		1.99,
		2,
		2.5,
		3,
		3.5,
		4.1,
		4.5,
		4.9,
		-3,
		-2,
		-1,
		5,
		6,
		7,
		8,
	], true) ?

	labels := hist.gen_labels('%g') ?
	println(labels)
}
```
