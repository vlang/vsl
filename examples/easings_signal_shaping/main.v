module main

import math
import vsl.easings

const sample_count = 200

fn main() {
	names := [
		'linear',
		'sine_in_out',
		'quintic_in_out',
		'bounce_out',
	]
	funcs := [
		easings.linear_interpolation,
		easings.sine_ease_in_out,
		easings.quintic_ease_in_out,
		easings.bounce_ease_out,
	]

	println('== easing signal shaping ==')
	println('Scenario: ADSR-like amplitude envelope over a 5 Hz carrier')
	println('')

	for i, name in names {
		envelope := build_envelope(funcs[i], sample_count)
		signal := apply_envelope(envelope, sample_count, 5.0)
		rms_value := rms(signal)
		crest := crest_factor(signal, rms_value)

		println('--- ${name} ---')
		println('envelope bounds: min=${min_value(envelope):8.4f} max=${max_value(envelope):8.4f}')
		println('signal rms: ${rms_value:8.4f}')
		println('signal crest factor: ${crest:8.4f}')
		println('checkpoints (idx -> envelope, signal):')
		for idx in [0, 25, 50, 75, 100, 150, 199] {
			println('  ${idx:3d} -> ${envelope[idx]:8.4f}, ${signal[idx]:8.4f}')
		}
		println('')
	}
}

fn build_envelope(easing easings.EasingFn, n int) []f64 {
	mut env := []f64{len: n}
	attack_len := n / 5
	decay_len := n / 5
	sustain_len := n / 5
	release_len := n - attack_len - decay_len - sustain_len

	mut i := 0

	// Attack: 0.0 -> 1.0
	for k in 0 .. attack_len {
		t := normalized_time(k, attack_len)
		env[i] = easing(t)
		i++
	}

	// Decay: 1.0 -> 0.7
	for k in 0 .. decay_len {
		t := normalized_time(k, decay_len)
		env[i] = 1.0 - 0.3 * easing(t)
		i++
	}

	// Sustain: constant 0.7
	for _ in 0 .. sustain_len {
		env[i] = 0.7
		i++
	}

	// Release: 0.7 -> 0.0
	for k in 0 .. release_len {
		t := normalized_time(k, release_len)
		env[i] = 0.7 * (1.0 - easing(t))
		i++
	}

	return env
}

fn apply_envelope(envelope []f64, n int, freq_hz f64) []f64 {
	mut signal := []f64{len: n}
	dt := 1.0 / f64(n - 1)
	for i in 0 .. n {
		t := f64(i) * dt
		carrier := math.sin(math.tau * freq_hz * t)
		signal[i] = envelope[i] * carrier
	}
	return signal
}

fn normalized_time(i int, len int) f64 {
	if len <= 1 {
		return 0.0
	}
	return f64(i) / f64(len - 1)
}

fn rms(values []f64) f64 {
	if values.len == 0 {
		return 0.0
	}
	mut sum := 0.0
	for v in values {
		sum += v * v
	}
	return math.sqrt(sum / f64(values.len))
}

fn crest_factor(values []f64, signal_rms f64) f64 {
	if signal_rms == 0.0 {
		return 0.0
	}
	mut peak := 0.0
	for v in values {
		av := abs(v)
		if av > peak {
			peak = av
		}
	}
	return peak / signal_rms
}

fn min_value(values []f64) f64 {
	mut m := values[0]
	for v in values {
		if v < m {
			m = v
		}
	}
	return m
}

fn max_value(values []f64) f64 {
	mut m := values[0]
	for v in values {
		if v > m {
			m = v
		}
	}
	return m
}

fn abs(x f64) f64 {
	return if x < 0.0 { -x } else { x }
}
