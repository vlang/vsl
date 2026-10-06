module fft

import math

fn test_complex_f32_fft_roundtrip() ! {
	mut data := [f32(1), 0, 0, 0]
	plan := create_complex_plan_f32(2)!
	defer {
		destroy_plan(plan)
	}

	assert forward_complex_f32(plan, mut data) == 0
	assert math.abs(data[0] - 1) < 1e-5
	assert math.abs(data[1]) < 1e-5
	assert math.abs(data[2] - 1) < 1e-5
	assert math.abs(data[3]) < 1e-5

	assert backward_complex_f32(plan, mut data) == 0
	assert math.abs(data[0] - 2) < 1e-5
	assert math.abs(data[1]) < 1e-5
	assert math.abs(data[2]) < 1e-5
	assert math.abs(data[3]) < 1e-5
}

fn test_complex_f32_fft_rejects_invalid_plan_length() {
	_ := create_complex_plan_f32(0) or {
		assert err.msg().contains('positive')
		return
	}
	assert false, 'expected zero-length plan to fail'
}

fn test_complex_f32_fft_rejects_odd_interleaved_data() ! {
	mut data := [f32(1), 0, 1]
	plan := create_complex_plan_f32(1)!
	defer {
		destroy_plan(plan)
	}

	assert forward_complex_f32(plan, mut data) == -1
	assert backward_complex_f32(plan, mut data) == -1
}

fn test_complex_f32_fft_rejects_data_length_mismatch() ! {
	mut data := [f32(1), 0, 0, 0]
	plan := create_complex_plan_f32(1)!
	defer {
		destroy_plan(plan)
	}

	assert forward_complex_f32(plan, mut data) == -1
	assert backward_complex_f32(plan, mut data) == -1
}

fn test_complex_f64_fft_roundtrip() ! {
	mut data := [f64(1), 0, 0, 0]
	plan := create_complex_plan_f64(2)!
	defer {
		destroy_plan(plan)
	}

	assert forward_complex_f64(plan, mut data) == 0
	assert math.abs(data[0] - 1) < 1e-12
	assert math.abs(data[1]) < 1e-12
	assert math.abs(data[2] - 1) < 1e-12
	assert math.abs(data[3]) < 1e-12

	assert backward_complex_f64(plan, mut data) == 0
	assert math.abs(data[0] - 2) < 1e-12
	assert math.abs(data[1]) < 1e-12
	assert math.abs(data[2]) < 1e-12
	assert math.abs(data[3]) < 1e-12
}

fn test_complex_f64_fft_rejects_invalid_plan_length() {
	_ := create_complex_plan_f64(0) or {
		assert err.msg().contains('positive')
		return
	}
	assert false, 'expected zero-length plan to fail'
}

fn test_complex_f64_fft_rejects_odd_interleaved_data() ! {
	mut data := [f64(1), 0, 1]
	plan := create_complex_plan_f64(1)!
	defer {
		destroy_plan(plan)
	}

	assert forward_complex_f64(plan, mut data) == -1
	assert backward_complex_f64(plan, mut data) == -1
}

fn test_complex_f64_fft_rejects_data_length_mismatch() ! {
	mut data := [f64(1), 0, 0, 0]
	plan := create_complex_plan_f64(1)!
	defer {
		destroy_plan(plan)
	}

	assert forward_complex_f64(plan, mut data) == -1
	assert backward_complex_f64(plan, mut data) == -1
}
