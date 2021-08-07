module vimpl

import rand

const max_allowed_error = 0.000001

[unsafe]
fn test_q_rsqrt_random() {
	for _ in 0 .. 1000 {
		mut rand_num := 0.0
		for rand_num == 0.0 {
			rand_num = rand.f64n(999999.0)
		}
		sqrt_a := 1.0 / sqrt(rand_num)
		sqrt_b := q_rsqrt(rand_num)
		assert abs(sqrt_a - sqrt_b) <= vimpl.max_allowed_error
	}
}
