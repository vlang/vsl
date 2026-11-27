module main

import time
import vsl.blas

const iteration_count = 5000

@[direct_array_access]
fn scalar_dot_i16_i64(x []i16, y []i16) i64 {
	mut sum := i64(0)
	for i in 0 .. x.len {
		sum += i64(x[i]) * i64(y[i])
	}
	return sum
}

fn main() {
	for size in [9, 32, 72, 96, 128, 192, 256, 1024, 4096, 65536, 1048576] {
		benchmark_size(size)
	}
}

fn benchmark_size(size int) {
	iterations := if size >= 1048576 {
		5
	} else if size >= 65536 {
		100
	} else {
		iteration_count
	}
	mut x := []i16{len: size}
	mut y := []i16{len: size}
	for i in 0 .. size {
		x[i] = i16(i % 511 - 255)
		y[i] = i16((i * 17) % 511 - 255)
	}
	expected := scalar_dot_i16_i64(x, y)
	for _ in 0 .. 5 {
		scalar_dot_i16_i64(x, y)
		blas.dot_i16_i64(x, y) or { panic(err) }
	}

	mut scalar_checksum := i64(0)
	mut started := time.sys_mono_now()
	for _ in 0 .. iterations {
		scalar_checksum += scalar_dot_i16_i64(x, y)
	}
	scalar_ns := time.sys_mono_now() - started

	mut dispatched_checksum := i64(0)
	started = time.sys_mono_now()
	for _ in 0 .. iterations {
		dispatched_checksum += blas.dot_i16_i64(x, y) or { panic(err) }
	}
	dispatched_ns := time.sys_mono_now() - started

	if scalar_checksum != dispatched_checksum || dispatched_checksum != expected * iterations {
		panic('i16 dot checksum mismatch for size ${size}')
	}
	println('n=${size}: scalar=${f64(scalar_ns) / iterations:.1f} ns, VSL-dispatched=${f64(dispatched_ns) / iterations:.1f} ns, speedup=${f64(scalar_ns) / f64(dispatched_ns):.2f}x')
}
