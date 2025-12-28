module util

import benchmark

// Benchmark utilities for VSL

// Benchmark configuration
pub struct Config {
pub:
	sizes       []int
	iterations  int = 10
	warmup_runs int = 3
}

// Format time in appropriate units
pub fn format_time(ns f64) string {
	if ns < 1000 {
		return '${ns:.2f} ns'
	} else if ns < 1000000 {
		return '${ns / 1000:.2f} μs'
	} else if ns < 1000000000 {
		return '${ns / 1000000:.2f} ms'
	} else {
		return '${ns / 1000000000:.2f} s'
	}
}

// Calculate GFLOPS for matrix multiplication
pub fn calculate_gflops_gemm(m int, n int, k int, time_ns f64) f64 {
	ops := f64(2 * m * n * k) // 2*m*n*k floating point operations
	time_s := time_ns / 1e9
	return ops / time_s / 1e9
}

// Calculate GFLOPS for matrix-vector multiplication
pub fn calculate_gflops_gemv(m int, n int, time_ns f64) f64 {
	ops := f64(2 * m * n) // 2*m*n floating point operations
	time_s := time_ns / 1e9
	return ops / time_s / 1e9
}

// Run benchmark with warmup and iterations
pub fn run_benchmark(config Config, f fn ()) f64 {
	mut b := benchmark.new_benchmark()

	// Warmup runs
	for _ in 0 .. config.warmup_runs {
		f()
	}

	// Actual benchmark
	b.step()
	for _ in 0 .. config.iterations {
		b.step()
		f()
		b.stop()
	}

	return f64(b.total_duration()) / f64(config.iterations)
}

// Print benchmark header
pub fn print_header(title string) {
	println('\n${'='.repeat(80)}')
	println('  ${title}')
	println('${'='.repeat(80)}')
}

// Print benchmark result row
pub fn print_result(operation string, size string, time_ns f64, extra string) {
	time_str := format_time(time_ns)
	println('${operation:-30} | ${size:-15} | ${time_str:-15} | ${extra}')
}

// Print table header
pub fn print_table_header() {
	println('${'Operation':-30} | ${'Size':-15} | ${'Time':-15} | ${'Extra Info':-20}')
	println('${'-'.repeat(30)}-+-${'-'.repeat(15)}-+-${'-'.repeat(15)}-+-${'-'.repeat(20)}')
}
