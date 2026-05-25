module main

import vsl.easings

const frame_count = 121

fn main() {
	names := [
		'linear',
		'quadratic_in_out',
		'cubic_in_out',
		'exponential_in_out',
		'elastic_out',
	]
	funcs := [
		easings.linear_interpolation,
		easings.quadratic_ease_in_out,
		easings.cubic_ease_in_out,
		easings.exponential_ease_in_out,
		easings.elastic_ease_out,
	]

	println('== easing motion profiles ==')
	println('Scenario: move from 0 -> 100 over ${frame_count} frames')
	println('')

	for i, name in names {
		run_profile(name, funcs[i])
		println('')
	}
}

fn run_profile(name string, easing easings.EasingFn) {
	positions := easings.animate(easing, 0.0, 100.0, frame_count)
	vel := first_differences(positions)
	acc := first_differences(vel)

	peak_v_idx, peak_v := max_abs_with_index(vel)
	peak_a_idx, peak_a := max_abs_with_index(acc)

	println('--- ${name} ---')
	println('endpoint: start=${positions[0]:8.4f} end=${positions[positions.len - 1]:8.4f}')
	println('monotonic_non_decreasing: ${is_monotonic_non_decreasing(positions)}')
	println('peak_velocity: frame=${peak_v_idx:3d} value=${peak_v:8.4f}')
	println('peak_acceleration: frame=${peak_a_idx:3d} value=${peak_a:8.4f}')
	println('keyframes (t%, position):')
	for pct in [0, 10, 25, 50, 75, 90, 100] {
		idx := int((f64(pct) / 100.0) * f64(frame_count - 1))
		println('  ${pct:3d}% -> ${positions[idx]:8.4f}')
	}
}

fn first_differences(values []f64) []f64 {
	if values.len < 2 {
		return []
	}
	mut out := []f64{cap: values.len - 1}
	for i in 1 .. values.len {
		out << values[i] - values[i - 1]
	}
	return out
}

fn max_abs_with_index(values []f64) (int, f64) {
	if values.len == 0 {
		return 0, 0.0
	}
	mut max_idx := 0
	mut max_val := values[0]
	for i, v in values {
		if abs(v) > abs(max_val) {
			max_idx = i
			max_val = v
		}
	}
	return max_idx, max_val
}

fn is_monotonic_non_decreasing(values []f64) bool {
	for i in 1 .. values.len {
		if values[i] < values[i - 1] {
			return false
		}
	}
	return true
}

fn abs(x f64) f64 {
	return if x < 0.0 { -x } else { x }
}
