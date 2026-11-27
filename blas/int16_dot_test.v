module blas

fn test_dot_i16_i64_matches_scalar_reference() ! {
	x := [i16(100), -200, 300, -400, 32767, -32768]
	y := [i16(-10), 20, -30, 40, -2, 3]
	mut expected := i64(0)
	for i in 0 .. x.len {
		expected += i64(x[i]) * i64(y[i])
	}
	assert dot_i16_i64(x, y)! == expected
}

fn test_dot_i16_i64_handles_simd_tail_and_wide_result() ! {
	length := 140003
	x := []i16{len: length, init: i16(255)}
	y := []i16{len: length, init: i16(-255)}
	expected := -i64(length) * 255 * 255
	assert dot_i16_i64(x, y)! == expected
}

fn test_dot_i16_i64_preserves_extreme_i16_products() ! {
	length := 64
	x := []i16{len: length, init: i16(-32768)}
	y := []i16{len: length, init: i16(-32768)}
	expected := i64(length) * i64(32768) * i64(32768)
	assert dot_i16_i64(x, y)! == expected
}

fn test_dot_i16_i64_rejects_mismatched_lengths_and_accepts_empty() ! {
	mut mismatch_failed := false
	dot_i16_i64([i16(1)], []i16{}) or { mismatch_failed = true }
	assert mismatch_failed
	assert dot_i16_i64([]i16{}, []i16{})! == 0
}
