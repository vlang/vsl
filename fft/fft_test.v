import math
import vsl.fft

fn check_real_fft[T](input []T, expected []f64, tolerance f64) ! {
	mut values := input.clone()
	plan := fft.create_plan(values)!
	defer {
		fft.destroy_plan(plan)
	}

	assert fft.forward_fft(plan, mut values) == 0
	if expected.len > 0 {
		assert values.len == expected.len
		for i, want in expected {
			assert math.abs(f64(values[i]) - want) < tolerance
		}
	}

	assert fft.backward_fft(plan, mut values) == 0
	for i, want in input {
		assert math.abs(f64(values[i]) - f64(want) * f64(input.len)) < tolerance * f64(input.len)
	}
}

fn test_real_fft_f32_and_f64_match_reference() ! {
	input32 := [f32(0.5), 0.5, 1.0, 2.0]
	input64 := [f64(0.5), 0.5, 1.0, 2.0]
	expected := [4.0, -0.5, 1.5, -1.0]
	check_real_fft(input32, expected, 1e-6)!
	check_real_fft(input64, expected, 1e-12)!
}

fn test_real_fft_multiple_lengths_for_both_precisions() ! {
	check_real_fft([f32(1.0), 0.0], [1.0, 1.0], 1e-6)!
	check_real_fft([f64(1.0), 0.0], [1.0, 1.0], 1e-12)!
	check_real_fft([f32(0.0), 1.0, 0.0, 0.0], [1.0, 0.0, -1.0, -1.0], 1e-6)!
	check_real_fft([f64(0.0), 1.0, 0.0, 0.0], [1.0, 0.0, -1.0, -1.0], 1e-12)!
	check_real_fft([f32(0.5), 0.5, 1.0, 2.0, 2.0, 2.0, 2.0, 3.0], [], 1e-5)!
	check_real_fft([f64(0.5), 0.5, 1.0, 2.0, 2.0, 2.0, 2.0, 3.0], [], 1e-12)!
}
