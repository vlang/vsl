module main

import vsl.dist

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
], true)?

labels := hist.gen_labels('%g')?
println(labels)
