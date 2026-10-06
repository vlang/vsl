module main

import math
import time
import vsl.fft

const sizes = [256, 1024, 4096, 16384]
const warmup_runs = 3

fn main() {
	println('VSL PocketFFT real f64 forward transform')
	println('size,iterations,mean_us')
	for size in sizes {
		iterations := iterations_for(size)
		mean_us := benchmark_fft(size, iterations) or {
			eprintln('FFT benchmark failed for n=${size}: ${err}')
			exit(1)
		}
		println('${size},${iterations},${mean_us:.3f}')
	}
}

fn iterations_for(size int) int {
	return match size {
		256 { 100 }
		1024 { 50 }
		4096 { 20 }
		else { 10 }
	}
}

fn benchmark_fft(size int, iterations int) !f64 {
	input := make_signal(size)
	plan := fft.create_plan(input) or { return error('failed to create FFT plan') }
	defer {
		fft.destroy_plan(plan)
	}
	for _ in 0 .. warmup_runs {
		mut warmup := input.clone()
		if fft.forward_fft(plan, mut warmup) != 0 {
			return error('forward_fft failed during warmup')
		}
	}

	mut elapsed_ns := u64(0)
	mut values := input.clone()
	for _ in 0 .. iterations {
		values = input.clone()
		start := time.sys_mono_now()
		status := fft.forward_fft(plan, mut values)
		elapsed_ns += time.sys_mono_now() - start
		if status != 0 {
			return error('forward_fft returned status ${status}')
		}
	}
	return f64(elapsed_ns) / f64(iterations) / 1000.0
}

fn make_signal(size int) []f64 {
	mut values := []f64{len: size}
	for i in 0 .. size {
		x := f64(i) / f64(size)
		values[i] = math.sin(2.0 * math.pi * 7.0 * x) + 0.25 * math.cos(2.0 * math.pi * 31.0 * x)
	}
	return values
}
