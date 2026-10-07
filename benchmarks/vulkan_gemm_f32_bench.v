// Resident-buffer Vulkan f32 GEMM benchmark.
// Run from ~/.vmodules with `v -prod -d vulkan run ...`.
module main

import time
import vsl.vulkan

fn main() {
	mut dev := vulkan.new_device() or {
		eprintln('Vulkan device unavailable: ${err}')
		return
	}
	defer {
		dev.release() or {}
	}
	println('VSL Vulkan GEMM f32 on ${dev.gpu_name()}')
	println('size,k_tile,iterations,mean_ms,checksum')
	for n in [128, 256, 512, 1024, 2048] {
		bench_gemm(dev, n) or {
			eprintln('Vulkan GEMM ${n}x${n} failed: ${err}')
			return
		}
	}
}

fn bench_gemm(dev &vulkan.Device, n int) ! {
	mut a_values := []f32{len: n * n}
	mut b_values := []f32{len: n * n}
	for i in 0 .. n {
		for j in 0 .. n {
			a_values[i * n + j] = f32((i * 17 + j * 13) % 997 + 1) / 997.0
			b_values[i * n + j] = f32((i * 7 + j * 19) % 991 + 1) / 991.0
		}
	}
	mut a_bytes := []u8{len: a_values.len * 4}
	mut b_bytes := []u8{len: b_values.len * 4}
	unsafe {
		C.memcpy(a_bytes.data, a_values.data, a_bytes.len)
		C.memcpy(b_bytes.data, b_values.data, b_bytes.len)
	}
	a_buf := dev.buffer(vulkan.DeviceSize(a_bytes.len))!
	defer {
		a_buf.release()
	}
	b_buf := dev.buffer(vulkan.DeviceSize(b_bytes.len))!
	defer {
		b_buf.release()
	}
	c_buf := dev.buffer(vulkan.DeviceSize(n * n * 4))!
	defer {
		c_buf.release()
	}
	a_buf.load(a_bytes)!
	b_buf.load(b_bytes)!
	for _ in 0 .. 3 {
		vulkan.gemm(dev, c_buf, a_buf, b_buf, u32(n), u32(n), u32(n))!
	}
	iterations := 10
	started := time.sys_mono_now()
	for _ in 0 .. iterations {
		vulkan.gemm(dev, c_buf, a_buf, b_buf, u32(n), u32(n), u32(n))!
	}
	mean_ms := f64(time.sys_mono_now() - started) / f64(iterations) / 1_000_000.0
	k_tile := if n >= 512 && n <= 1024 { 32 } else { 16 }
	mut c_bytes := []u8{len: n * n * 4}
	c_buf.store(mut c_bytes)!
	mut c_values := []f32{len: n * n}
	unsafe {
		C.memcpy(c_values.data, c_bytes.data, c_bytes.len)
	}
	checksum := c_values[n * n / 2 + n / 2]
	println('${n},${k_tile},${iterations},${mean_ms:.3f},${checksum:.6f}')
}
