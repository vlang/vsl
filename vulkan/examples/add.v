module main

// Example: Vulkan Compute — vector add on GPU
//
// Run with:
//   v -enable-globals run --path ~/.vmodules/vsl ~/.vmodules/vsl/vulkan/examples/add.v
//
// Requirements: Vulkan SDK installed (libvulkan.so / libvulkan.1.dylib)
//
// This example demonstrates:
//   1. Device discovery (find GPU with compute support)
//   2. Buffer creation and host→GPU data transfer
//   3. GPU compute dispatch (vector add via SPIR-V)
//   4. GPU→host readback of results
import vsl.vulkan
import math

fn main() {
	println('VSL Vulkan Compute — vector add example')
	println('====================================')

	// Create Vulkan device (finds first discrete GPU with compute queue)
	mut dev := vulkan.new_device() or {
		eprintln('Failed to create Vulkan device: ${err}')
		eprintln('Make sure Vulkan drivers are installed (e.g. mesa-vulkan-drivers on Linux)')
		return
	}
	defer {
		dev.release() or { eprintln('release error: ${err}') }
	}

	println('GPU: ${dev.gpu_name()} (${dev.device_type()})')
	println('Queue family: ${dev.queue_family_index}')

	// Host data
	n := 1024
	a_data := []f32{len: n, init: f32(index)}
	b_data := []f32{len: n, init: f32(index * 2)}
	mut c_data := []f32{len: n}

	// Allocate GPU buffers
	mut a_buf := dev.buffer(vulkan.DeviceSize(n * 4)) or {
		eprintln('Failed to create buffer A: ${err}')
		return
	}
	mut b_buf := dev.buffer(vulkan.DeviceSize(n * 4)) or {
		eprintln('Failed to create buffer B: ${err}')
		return
	}
	mut c_buf := dev.buffer(vulkan.DeviceSize(n * 4)) or {
		eprintln('Failed to create buffer C: ${err}')
		return
	}
	defer {
		a_buf.release()
		b_buf.release()
		c_buf.release()
	}

	// Upload data to GPU (synchronous)
	a_buf.load(bytes_from_f32(a_data)) or {
		eprintln('Failed to upload A: ${err}')
		return
	}
	b_buf.load(bytes_from_f32(b_data)) or {
		eprintln('Failed to upload B: ${err}')
		return
	}

	// Create pipeline and dispatch
	mut pl := dev.create_pipeline(vulkan.vector_add_spv, 'main') or {
		eprintln('Failed to create pipeline: ${err}')
		return
	}
	defer {
		pl.release()
	}

	// Update descriptor set bindings
	pl.update_buffer(0, a_buf) or {
		eprintln('Failed to update buffer binding 0: ${err}')
		return
	}
	pl.update_buffer(1, b_buf) or {
		eprintln('Failed to update buffer binding 1: ${err}')
		return
	}
	pl.update_buffer(2, c_buf) or {
		eprintln('Failed to update buffer binding 2: ${err}')
		return
	}

	// Dispatch: 1024 work items, 256 per workgroup (set in SPIR-V) → 4 groups
	vulkan.dispatch_sync(pl, u32(1024), 1, 1) or {
		eprintln('Dispatch failed: ${err}')
		return
	}

	// Read result back
	mut raw := []u8{len: n * 4}
	raw = c_buf.store(mut raw) or {
		eprintln('Failed to read back result: ${err}')
		return
	}
	c_data = bytes_to_f32(raw)

	// Verify: c[i] = a[i] + b[i] = it + it*2 = it*3
	mut ok := true
	for i := 0; i < n; i++ {
		expected := f32(i * 3)
		if math.abs(c_data[i] - expected) > 0.001 {
			eprintln('Mismatch at ${i}: got ${c_data[i]}, expected ${expected}')
			ok = false
			break
		}
	}

	if ok {
		println('✓ All ${n} elements correct!')
		println('  Sample: c[0] = ${c_data[0]:.1}, c[100] = ${c_data[100]:.1}, c[1023] = ${c_data[1023]:.1}')
	} else {
		eprintln('✗ Verification failed')
	}
}

// bytes_from_f32 converts a []f32 slice to []u8 via memcpy.
fn bytes_from_f32(data []f32) []u8 {
	mut bytes := []u8{len: data.len * 4}
	unsafe { C.memcpy(bytes.data, data.data, data.len * 4) }
	return bytes
}

// bytes_to_f32 converts a []u8 slice back to []f32 via memcpy.
fn bytes_to_f32(data []u8) []f32 {
	mut result := []f32{len: data.len / 4}
	unsafe { C.memcpy(result.data, data.data, data.len) }
	return result
}
