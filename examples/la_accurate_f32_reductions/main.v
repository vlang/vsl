module main

import vsl.la

fn main() {
	values := [f32(1e8), f32(1), f32(-1e8)]
	println('naive f32 sum: ${la.vector_accum(values)}')
	println('accurate f32 sum: ${la.vector_sum_accurate_f32(values)}')

	left := [f32(1.0000001192092896), f32(-1)]
	right := [f32(1.0000001192092896), f32(1.000000238418579)]
	naive_dot := la.vector_dot(left, right)
	accurate_dot := la.vector_dot_accurate_f32(left, right) or { panic(err) }
	println('naive f32 dot: ${naive_dot}')
	println('accurate f32 dot: ${accurate_dot}')
}
