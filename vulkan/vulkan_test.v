module vulkan

import math

// --------------------------------------------------------------------------
// Test helpers
// --------------------------------------------------------------------------

fn try_device() !&Device {
	return new_device()
}

fn bytes_from_f32(data []f32) []u8 {
	mut bytes := []u8{len: data.len * 4}
	unsafe { C.memcpy(bytes.data, data.data, data.len * 4) }
	return bytes
}

fn bytes_to_f32(data []u8) []f32 {
	mut result := []f32{len: data.len / 4}
	unsafe { C.memcpy(result.data, data.data, data.len) }
	return result
}

// --------------------------------------------------------------------------
// Device lifecycle
// --------------------------------------------------------------------------

fn test_new_device_and_release() {
	mut dev := try_device() or {
		eprintln('SKIP: test_new_device_and_release — no Vulkan device available: ${err}')
		return
	}
	// Verify device properties are valid
	name := dev.gpu_name()
	assert name.len > 0
	dtype := dev.device_type()
	assert dtype.len > 0

	dev.release() or { assert false, 'release failed: ${err}' }
}

fn test_device_properties() {
	mut dev := try_device() or {
		eprintln('SKIP: test_device_properties — no Vulkan device available: ${err}')
		return
	}
	defer {
		dev.release() or {}
	}

	// Device summary string should be non-empty
	summary := dev.str()
	assert summary.len > 0
	eprintln('  ${summary}')
}

// --------------------------------------------------------------------------
// GPU buffer lifecycle
// --------------------------------------------------------------------------

fn test_gpu_buffer_alloc_free() {
	mut dev := try_device() or {
		eprintln('SKIP: test_gpu_buffer_alloc_free — no Vulkan device available: ${err}')
		return
	}
	defer {
		dev.release() or {}
	}

	// Allocate a 1KB buffer
	mut buf := dev.buffer(DeviceSize(1024)) or {
		assert false, 'buffer allocation failed: ${err}'
		return
	}
	defer {
		buf.release()
	}

	assert buf.size == DeviceSize(1024)
}

// --------------------------------------------------------------------------
// Buffer upload/download roundtrip
// --------------------------------------------------------------------------

fn test_buffer_upload_download() {
	mut dev := try_device() or {
		eprintln('SKIP: test_buffer_upload_download — no Vulkan device available: ${err}')
		return
	}
	defer {
		dev.release() or {}
	}

	n := 256
	data := []f32{len: n, init: f32(index)}
	bytes := bytes_from_f32(data)

	mut buf := dev.buffer(DeviceSize(bytes.len)) or {
		assert false, 'buffer allocation failed: ${err}'
		return
	}
	defer {
		buf.release()
	}

	// Upload
	buf.load(bytes) or {
		assert false, 'buffer upload failed: ${err}'
		return
	}

	// Download
	mut readback := []u8{len: bytes.len}
	readback = buf.store(mut readback) or {
		assert false, 'buffer store failed: ${err}'
		return
	}

	result := bytes_to_f32(readback)
	for i in 0 .. n {
		assert result[i] == data[i], 'Mismatch at ${i}: got ${result[i]}, expected ${data[i]}'
	}
}

// --------------------------------------------------------------------------
// Pipeline creation
// --------------------------------------------------------------------------

fn test_create_pipeline() {
	mut dev := try_device() or {
		eprintln('SKIP: test_create_pipeline — no Vulkan device available: ${err}')
		return
	}
	defer {
		dev.release() or {}
	}

	mut pl := dev.create_pipeline(vector_add_spv, 'main') or {
		assert false, 'pipeline creation failed: ${err}'
		return
	}
	pl.release()
}

// --------------------------------------------------------------------------
// vector_add operation
// --------------------------------------------------------------------------

fn test_vector_add_op() {
	mut dev := try_device() or {
		eprintln('SKIP: test_vector_add_op — no Vulkan device available: ${err}')
		return
	}
	defer {
		dev.release() or {}
	}

	n := 256
	a_data := []f32{len: n, init: f32(index)}
	b_data := []f32{len: n, init: f32(index * 2)}

	a_bytes := bytes_from_f32(a_data)
	b_bytes := bytes_from_f32(b_data)

	mut a_buf := dev.buffer(DeviceSize(a_bytes.len)) or { assert false, 'buf A failed'; return }
	defer { a_buf.release() }
	mut b_buf := dev.buffer(DeviceSize(b_bytes.len)) or { assert false, 'buf B failed'; return }
	defer { b_buf.release() }
	mut c_buf := dev.buffer(DeviceSize(n * 4)) or { assert false, 'buf C failed'; return }
	defer { c_buf.release() }

	a_buf.load(a_bytes) or { assert false, 'upload A failed: ${err}'; return }
	b_buf.load(b_bytes) or { assert false, 'upload B failed: ${err}'; return }

	vector_add(c_buf, a_buf, b_buf) or {
		assert false, 'vector_add failed: ${err}'
		return
	}

	mut raw := []u8{len: n * 4}
	raw = c_buf.store(mut raw) or { assert false, 'store failed: ${err}'; return }
	result := bytes_to_f32(raw)

	for i := 0; i < n; i++ {
		expected := f32(i) + f32(i * 2)
		if math.abs(result[i] - expected) > 0.001 {
			assert false, 'vec_add mismatch at ${i}: got ${result[i]}, expected ${expected}'
			return
		}
	}
}

// --------------------------------------------------------------------------
// scale operation
// --------------------------------------------------------------------------

fn test_scale_op() {
	mut dev := try_device() or {
		eprintln('SKIP: test_scale_op — no Vulkan device available: ${err}')
		return
	}
	defer {
		dev.release() or {}
	}

	n := 128
	alpha := f32(3.0)
	src_data := []f32{len: n, init: f32(index) * 2.0}
	src_bytes := bytes_from_f32(src_data)

	mut src_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf src failed'; return }
	defer { src_buf.release() }
	mut dst_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf dst failed'; return }
	defer { dst_buf.release() }

	src_buf.load(src_bytes) or { assert false, 'upload failed: ${err}'; return }

	scale(dst_buf, src_buf, alpha) or {
		assert false, 'scale failed: ${err}'
		return
	}

	mut raw := []u8{len: n * 4}
	raw = dst_buf.store(mut raw) or { assert false, 'store failed: ${err}'; return }
	result := bytes_to_f32(raw)

	for i := 0; i < n; i++ {
		expected := alpha * f32(i * 2)
		if math.abs(result[i] - expected) > 0.001 {
			assert false, 'scale mismatch at ${i}: got ${result[i]}, expected ${expected}'
			return
		}
	}
}

// --------------------------------------------------------------------------
// sum operation (reduction)
// --------------------------------------------------------------------------

fn test_sum_op() {
	mut dev := try_device() or {
		eprintln('SKIP: test_sum_op — no Vulkan device available: ${err}')
		return
	}
	defer {
		dev.release() or {}
	}

	n := 512
	data := []f32{len: n, init: f32(index)}
	bytes := bytes_from_f32(data)

	mut buf := dev.buffer(DeviceSize(bytes.len)) or { assert false, 'buf failed'; return }
	defer { buf.release() }
	buf.load(bytes) or { assert false, 'upload failed: ${err}'; return }

	total := sum(buf) or {
		assert false, 'sum failed: ${err}'
		return
	}

	// Expected: sum of 0..n-1 = n*(n-1)/2
	expected := f32(n * (n - 1) / 2)
	if math.abs(total - expected) > 1.0 {
		// Allow 1.0 tolerance due to reduction precision
		assert false, 'sum mismatch: got ${total}, expected ${expected}'
		return
	}
}

// --------------------------------------------------------------------------
// relu operation
// --------------------------------------------------------------------------

fn test_relu_op() {
	mut dev := try_device() or {
		eprintln('SKIP: test_relu_op — no Vulkan device available: ${err}')
		return
	}
	defer {
		dev.release() or {}
	}

	n := 128
	// Mix of positive and negative values
	src_data := []f32{len: n, init: f32(index) - 50.0}
	src_bytes := bytes_from_f32(src_data)

	mut src_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf src failed'; return }
	defer { src_buf.release() }
	mut dst_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf dst failed'; return }
	defer { dst_buf.release() }

	src_buf.load(src_bytes) or { assert false, 'upload failed: ${err}'; return }

	relu(dst_buf, src_buf) or {
		assert false, 'relu failed: ${err}'
		return
	}

	mut raw := []u8{len: n * 4}
	raw = dst_buf.store(mut raw) or { assert false, 'store failed: ${err}'; return }
	result := bytes_to_f32(raw)

	for i := 0; i < n; i++ {
		mut expected := f32(0.0)
		if src_data[i] > 0 {
			expected = src_data[i]
		}
		if math.abs(result[i] - expected) > 0.001 {
			assert false, 'relu mismatch at ${i}: got ${result[i]}, expected ${expected}'
			return
		}
	}
}

// --------------------------------------------------------------------------
// sigmoid operation
// --------------------------------------------------------------------------

fn test_sigmoid_op() {
	mut dev := try_device() or {
		eprintln('SKIP: test_sigmoid_op — no Vulkan device available: ${err}')
		return
	}
	defer {
		dev.release() or {}
	}

	n := 64
	src_data := []f32{len: n, init: f32(index) * 0.5 - 5.0}
	src_bytes := bytes_from_f32(src_data)

	mut src_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf src failed'; return }
	defer { src_buf.release() }
	mut dst_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf dst failed'; return }
	defer { dst_buf.release() }

	src_buf.load(src_bytes) or { assert false, 'upload failed: ${err}'; return }

	sigmoid(dst_buf, src_buf) or {
		assert false, 'sigmoid failed: ${err}'
		return
	}

	mut raw := []u8{len: n * 4}
	raw = dst_buf.store(mut raw) or { assert false, 'store failed: ${err}'; return }
	result := bytes_to_f32(raw)

	// Sigmoid should be in (0, 1) range
	for i := 0; i < n; i++ {
		assert result[i] > 0.0, 'sigmoid at ${i}: ${result[i]} is not > 0'
		assert result[i] < 1.0, 'sigmoid at ${i}: ${result[i]} is not < 1'
	}
}
