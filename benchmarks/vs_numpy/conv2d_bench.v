// VSL Conv2D CPU reference benchmark (NCHW). Run: v run vsl/benchmarks/vs_numpy/conv2d_bench.v
module main

import time
import vsl.benchmarks.util as bu

fn main() {
	bu.print_header('VSL Conv2D benchmark (CPU NCHW reference)')
	config := bu.BenchmarkConfig{
		iterations:  5
		warmup_runs: 2
	}
	bu.print_vs_numpy_table_header()
	bench_conv2d(config)
	println('\nNumPy baseline: see benchmarks/vs_numpy/README.md')
}

fn bench_conv2d(config bu.BenchmarkConfig) {
	// 1x1x32x32 input, 1x1x3x3 kernel, stride 1
	batch := 1
	in_ch := 1
	out_ch := 1
	in_h := 32
	in_w := 32
	k_h := 3
	k_w := 3
	stride_h := 1
	stride_w := 1

	mut input := []f64{len: batch * in_ch * in_h * in_w}
	mut kernel := []f64{len: out_ch * in_ch * k_h * k_w}
	for i in 0 .. input.len {
		input[i] = f64(i % 17) * 0.01
	}
	for i in 0 .. kernel.len {
		kernel[i] = f64((i % 5) + 1) * 0.1
	}

	for _ in 0 .. config.warmup_runs {
		conv2d_cpu_nchw(input, kernel, batch, in_h, in_w, in_ch, out_ch, k_h, k_w, stride_h,
			stride_w) or { panic(err) }
	}

	mut samples := []f64{len: config.iterations}
	for i in 0 .. config.iterations {
		t0 := time.ticks()
		conv2d_cpu_nchw(input, kernel, batch, in_h, in_w, in_ch, out_ch, k_h, k_w, stride_h,
			stride_w) or { panic(err) }
		samples[i] = f64(time.ticks() - t0)
	}
	avg := bu.mean_time_ms(mut samples)
	bu.print_vs_numpy_row('conv2d', '1x1x32x32', avg, '-')
}

fn conv2d_cpu_nchw(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	out_h := (in_h - k_h) / stride_h + 1
	out_w := (in_w - k_w) / stride_w + 1
	out_size := batch * out_ch * out_h * out_w
	mut out := []f64{len: out_size}
	for b in 0 .. batch {
		for oc in 0 .. out_ch {
			for oh in 0 .. out_h {
				for ow in 0 .. out_w {
					mut sum := 0.0
					for ic in 0 .. in_ch {
						for krow in 0 .. k_h {
							for kcol in 0 .. k_w {
								ih := oh * stride_h + krow
								iw := ow * stride_w + kcol
								in_idx := ((b * in_ch + ic) * in_h + ih) * in_w + iw
								k_idx := ((oc * in_ch + ic) * k_h + krow) * k_w + kcol
								sum += input[in_idx] * kernel[k_idx]
							}
						}
					}
					out_idx := ((b * out_ch + oc) * out_h + oh) * out_w + ow
					out[out_idx] = sum
				}
			}
		}
	}
	return out
}
