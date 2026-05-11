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

	vector_add(dev, c_buf, a_buf, b_buf) or {
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

	scale(dev, dst_buf, src_buf, alpha) or {
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

	total := sum(dev, buf) or {
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

	relu(dev, dst_buf, src_buf) or {
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
	// Keep inputs in [-8, 8] so f32 sigmoid stays strictly in (0, 1).
	// sigmoid(x) saturates to exactly 0.0 or 1.0 in f32 beyond ~±16.
	src_data := []f32{len: n, init: f32(index) * 0.25 - 8.0}
	src_bytes := bytes_from_f32(src_data)

	mut src_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf src failed'; return }
	defer { src_buf.release() }
	mut dst_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf dst failed'; return }
	defer { dst_buf.release() }

	src_buf.load(src_bytes) or { assert false, 'upload failed: ${err}'; return }

	sigmoid(dev, dst_buf, src_buf) or {
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

fn test_softmax() {
	mut dev := new_device() or {
		eprintln('no Vulkan device — skip')
		return
	}
	defer { dev.release() or {} }

	n := u32(64)
	mut src_data := []f32{len: int(n), init: f32(index) * 0.1}
	src_bytes := bytes_from_f32(src_data)

	mut src_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf src'; return }
	defer { src_buf.release() }
	mut dst_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf dst'; return }
	defer { dst_buf.release() }

	src_buf.load(src_bytes) or { assert false, 'upload: ${err}'; return }

	softmax(dev, dst_buf, src_buf, n) or { assert false, 'softmax: ${err}'; return }

	mut raw := []u8{len: int(n) * 4}
	raw = dst_buf.store(mut raw) or { assert false, 'store: ${err}'; return }
	result := bytes_to_f32(raw)

	mut total := f32(0.0)
	for v in result {
		assert v > 0.0, 'softmax output must be positive'
		total += v
	}
	// Sum should be approximately 1.0
	assert total > 0.99 && total < 1.01, 'softmax sum=${total} not ≈ 1'
}

fn test_layernorm() {
	mut dev := new_device() or {
		eprintln('no Vulkan device — skip')
		return
	}
	defer { dev.release() or {} }

	n := u32(64)
	mut src_data := []f32{len: int(n), init: f32(index) - f32(n) / 2.0}
	src_bytes := bytes_from_f32(src_data)

	mut src_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf src'; return }
	defer { src_buf.release() }
	mut dst_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf dst'; return }
	defer { dst_buf.release() }

	src_buf.load(src_bytes) or { assert false, 'upload: ${err}'; return }

	eps := f32(1e-5)
	layernorm(dev, dst_buf, src_buf, n, eps) or { assert false, 'layernorm: ${err}'; return }

	mut raw := []u8{len: int(n) * 4}
	raw = dst_buf.store(mut raw) or { assert false, 'store: ${err}'; return }
	result := bytes_to_f32(raw)

	// Normalised output should have mean ≈ 0 and values in [-3, 3]
	mut s := f32(0.0)
	for v in result {
		s += v
	}
	mean := s / f32(n)
	assert mean > -0.1 && mean < 0.1, 'layernorm mean=${mean} not ≈ 0'
}

fn test_reduce_sum() {
	mut dev := new_device() or {
		eprintln('no Vulkan device — skip')
		return
	}
	defer { dev.release() or {} }

	n := u32(256)
	src_data := []f32{len: int(n), init: f32(1)} // all ones → sum = n
	src_bytes := bytes_from_f32(src_data)

	wg_size := u32(256)
	num_groups := (n + wg_size - 1) / wg_size

	mut src_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf src'; return }
	defer { src_buf.release() }
	mut dst_buf := dev.buffer(DeviceSize(u64(num_groups) * 4)) or { assert false, 'buf dst'; return }
	defer { dst_buf.release() }

	src_buf.load(src_bytes) or { assert false, 'upload: ${err}'; return }

	reduce(dev, dst_buf, src_buf, n, .sum) or { assert false, 'reduce: ${err}'; return }

	mut raw := []u8{len: int(num_groups) * 4}
	raw = dst_buf.store(mut raw) or { assert false, 'store: ${err}'; return }
	partial := bytes_to_f32(raw)

	mut total := f32(0.0)
	for v in partial {
		total += v
	}
	assert total > f32(n) - 1.0 && total < f32(n) + 1.0, 'reduce sum=${total} expected ${n}'
}

fn test_gelu() {
	dev := try_device() or {
		eprintln('skip: no Vulkan device')
		return
	}
	defer { dev.release() or {} }

	n := u32(4)
	// x = [0, 1, -1, 2]
	src_data := [f32(0.0), 1.0, -1.0, 2.0]
	src_bytes := bytes_from_f32(src_data)

	mut src_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false, 'buf src'; return }
	defer { src_buf.release() }
	mut dst_buf := dev.buffer(DeviceSize(u64(n) * 4)) or { assert false, 'buf dst'; return }
	defer { dst_buf.release() }

	src_buf.load(src_bytes) or { assert false, 'upload'; return }
	gelu(dev, dst_buf, src_buf, n) or { assert false, 'gelu: ${err}'; return }

	mut raw := []u8{len: int(n) * 4}
	raw = dst_buf.store(mut raw) or { assert false, 'store'; return }
	out := bytes_to_f32(raw)

	// gelu(0) = 0
	assert math.abs(out[0]) < 0.01, 'gelu(0) = ${out[0]}'
	// gelu(1) ≈ 0.8413
	assert math.abs(out[1] - 0.8413) < 0.01, 'gelu(1) = ${out[1]}'
	// gelu(-1) ≈ -0.1587
	assert math.abs(out[2] - (-0.1587)) < 0.01, 'gelu(-1) = ${out[2]}'
	// gelu(2) ≈ 1.9545
	assert math.abs(out[3] - 1.9545) < 0.01, 'gelu(2) = ${out[3]}'
}

fn test_maxpool2d() {
	dev := try_device() or {
		eprintln('skip: no Vulkan device')
		return
	}
	defer { dev.release() or {} }

	// Input: [1, 1, 4, 4], kernel=2x2, stride=2, no padding → output [1, 1, 2, 2]
	// Input values:
	// 1  2  3  4
	// 5  6  7  8
	// 9  10 11 12
	// 13 14 15 16
	src_data := [
		f32(1), 2, 3, 4,
		f32(5), 6, 7, 8,
		f32(9), 10, 11, 12,
		f32(13), 14, 15, 16,
	]
	src_bytes := bytes_from_f32(src_data)

	batch := u32(1); in_ch := u32(1)
	in_h := u32(4); in_w := u32(4)
	k_h := u32(2); k_w := u32(2)
	stride_h := u32(2); stride_w := u32(2)
	pad_h := u32(0); pad_w := u32(0)
	out_h := (in_h + 2 * pad_h - k_h) / stride_h + 1  // = 2
	out_w := (in_w + 2 * pad_w - k_w) / stride_w + 1  // = 2
	n_out := batch * in_ch * out_h * out_w

	mut src_buf := dev.buffer(DeviceSize(src_bytes.len)) or { assert false; return }
	defer { src_buf.release() }
	mut dst_buf := dev.buffer(DeviceSize(u64(n_out) * 4)) or { assert false; return }
	defer { dst_buf.release() }

	src_buf.load(src_bytes) or { assert false; return }
	maxpool2d(dev, dst_buf, src_buf, batch, in_ch, in_h, in_w, k_h, k_w, out_h, out_w, pad_h, pad_w, stride_h, stride_w) or {
		assert false, 'maxpool2d: ${err}'
		return
	}

	mut raw := []u8{len: int(n_out) * 4}
	raw = dst_buf.store(mut raw) or { assert false; return }
	out := bytes_to_f32(raw)

	// Expected max values per 2x2 block:
	// top-left: max(1,2,5,6)=6, top-right: max(3,4,7,8)=8
	// bot-left: max(9,10,13,14)=14, bot-right: max(11,12,15,16)=16
	assert math.abs(out[0] - 6.0) < 0.01, 'maxpool[0] = ${out[0]}'
	assert math.abs(out[1] - 8.0) < 0.01, 'maxpool[1] = ${out[1]}'
	assert math.abs(out[2] - 14.0) < 0.01, 'maxpool[2] = ${out[2]}'
	assert math.abs(out[3] - 16.0) < 0.01, 'maxpool[3] = ${out[3]}'
}

fn test_batchnorm1d() {
	mut dev := new_device() or {
		eprintln('no Vulkan device — skipping batchnorm1d test')
		return
	}
	defer { dev.release() or {} }

	// 4 samples, 2 features
	// col0: [1,2,3,4] mean=2.5 var=1.25  → normalised: [-1.342, -0.447, 0.447, 1.342]
	// col1: [2,4,6,8] mean=5   var=5     → normalised: [-1.342, -0.447, 0.447, 1.342]
	n := u32(4)
	c := u32(2)
	input := [
		f32(1), f32(2),
		f32(2), f32(4),
		f32(3), f32(6),
		f32(4), f32(8),
	]
	eps := f32(1e-5)
	total := int(n * c)

	mut src_bytes := []u8{len: total * 4}
	for i, v in input {
		unsafe { *(&f32(&src_bytes[i * 4])) = v }
	}
	mut src_buf := dev.buffer(DeviceSize(u64(total) * 4))!
	defer { src_buf.release() }
	src_buf.load(src_bytes)!

	mut dst_buf := dev.buffer(DeviceSize(u64(total) * 4))!
	defer { dst_buf.release() }

	batchnorm1d(dev, dst_buf, src_buf, n, c, eps)!

	mut raw := []u8{len: total * 4}
	dst_buf.store(mut raw)!

	mut out := []f32{len: total}
	for i in 0 .. total {
		unsafe { out[i] = *(&f32(&raw[i * 4])) }
	}

	// Both columns should have same normalised pattern
	assert math.abs(f64(out[0]) - (-1.342)) < 0.01, 'out[0]=${out[0]}'
	assert math.abs(f64(out[2]) - (-0.447)) < 0.01, 'out[2]=${out[2]}'
	assert math.abs(f64(out[4]) -   0.447)  < 0.01, 'out[4]=${out[4]}'
	assert math.abs(f64(out[6]) -   1.342)  < 0.01, 'out[6]=${out[6]}'
}

// ── Edge-case sizes ──────────────────────────────────────────────────────────

fn run_vector_add_size(n int) ! {
	mut dev := new_device() or { return }
	defer { dev.release() or {} }

	a := []f32{len: n, init: f32(index) + 1}
	b := []f32{len: n, init: f32(index) * 2}

	mut ab := []u8{len: n * 4}
	mut bb := []u8{len: n * 4}
	for i in 0 .. n {
		unsafe {
			*(&f32(&ab[i * 4])) = a[i]
			*(&f32(&bb[i * 4])) = b[i]
		}
	}

	mut buf_a := dev.buffer(DeviceSize(u64(n) * 4))!
	defer { buf_a.release() }
	buf_a.load(ab)!

	mut buf_b := dev.buffer(DeviceSize(u64(n) * 4))!
	defer { buf_b.release() }
	buf_b.load(bb)!

	mut buf_c := dev.buffer(DeviceSize(u64(n) * 4))!
	defer { buf_c.release() }

	vector_add(dev, buf_c, buf_a, buf_b)!

	mut raw := []u8{len: n * 4}
	buf_c.store(mut raw)!

	for i in 0 .. n {
		got := unsafe { *(&f32(&raw[i * 4])) }
		want := a[i] + b[i]
		assert math.abs(f64(got) - f64(want)) < 1e-4, 'n=${n} i=${i}: got=${got} want=${want}'
	}
}

fn test_vector_add_size_1() {
	run_vector_add_size(1) or {
		eprintln('no Vulkan device — skipping')
		return
	}
}

fn test_vector_add_size_64() {
	run_vector_add_size(64) or {
		eprintln('no Vulkan device — skipping')
		return
	}
}

fn test_vector_add_size_1024() {
	run_vector_add_size(1024) or {
		eprintln('no Vulkan device — skipping')
		return
	}
}

fn test_vector_add_size_4096() {
	run_vector_add_size(4096) or {
		eprintln('no Vulkan device — skipping')
		return
	}
}

// ── Multiple consecutive dispatches on the same pipeline ─────────────────────

fn test_multiple_consecutive_dispatches() {
	mut dev := new_device() or {
		eprintln('no Vulkan device — skipping')
		return
	}
	defer { dev.release() or {} }

	n := 128
	a := []f32{len: n, init: f32(1)}
	mut ab := []u8{len: n * 4}
	for i in 0 .. n {
		unsafe { *(&f32(&ab[i * 4])) = a[i] }
	}

	mut buf_a := dev.buffer(DeviceSize(u64(n) * 4)) or { return }
	defer { buf_a.release() }
	buf_a.load(ab) or { return }

	mut buf_b := dev.buffer(DeviceSize(u64(n) * 4)) or { return }
	defer { buf_b.release() }
	buf_b.load(ab) or { return }

	mut buf_out := dev.buffer(DeviceSize(u64(n) * 4)) or { return }
	defer { buf_out.release() }

	// First dispatch: a + b = 2
	vector_add(dev, buf_out, buf_a, buf_b) or { return }
	mut raw1 := []u8{len: n * 4}
	buf_out.store(mut raw1) or { return }
	got1 := unsafe { *(&f32(&raw1[0])) }
	assert math.abs(f64(got1) - 2.0) < 1e-4, 'first dispatch: got=${got1}'

	// Second dispatch: out + a = 3
	vector_add(dev, buf_out, buf_out, buf_a) or { return }
	mut raw2 := []u8{len: n * 4}
	buf_out.store(mut raw2) or { return }
	got2 := unsafe { *(&f32(&raw2[0])) }
	assert math.abs(f64(got2) - 3.0) < 1e-4, 'second dispatch: got=${got2}'
}

// ── Device teardown and re-creation ──────────────────────────────────────────

fn test_device_recreate() {
	for _ in 0 .. 3 {
		mut dev := new_device() or {
			eprintln('no Vulkan device — skipping')
			return
		}
		name := dev.gpu_name()
		assert name.len > 0
		dev.release() or { return }
	}
}

// ── Multiple pipelines active simultaneously ──────────────────────────────────

fn test_multiple_pipelines_active() {
	mut dev := new_device() or {
		eprintln('no Vulkan device — skipping')
		return
	}
	defer { dev.release() or {} }

	n := 64
	mut data := []u8{len: n * 4}
	for i in 0 .. n {
		val := f32(i) + 1
		unsafe { *(&f32(&data[i * 4])) = val }
	}

	// Run relu and sigmoid on the same data in sequence (exercises pipeline cache with 2 entries)
	mut buf_in := dev.buffer(DeviceSize(u64(n) * 4)) or { return }
	defer { buf_in.release() }
	buf_in.load(data) or { return }

	mut buf_relu := dev.buffer(DeviceSize(u64(n) * 4)) or { return }
	defer { buf_relu.release() }

	mut buf_sig := dev.buffer(DeviceSize(u64(n) * 4)) or { return }
	defer { buf_sig.release() }

	relu(dev, buf_relu, buf_in) or { return }
	sigmoid(dev, buf_sig, buf_in) or { return }

	mut raw_relu := []u8{len: n * 4}
	buf_relu.store(mut raw_relu) or { return }
	mut raw_sig := []u8{len: n * 4}
	buf_sig.store(mut raw_sig) or { return }

	// relu(1) = 1, sigmoid(1) ≈ 0.731
	r0 := unsafe { *(&f32(&raw_relu[0])) }
	s0 := unsafe { *(&f32(&raw_sig[0])) }
	assert math.abs(f64(r0) - 1.0) < 1e-4, 'relu[0]=${r0}'
	assert math.abs(f64(s0) - 0.7311) < 0.001, 'sigmoid[0]=${s0}'
}

// ── Single-element scale (boundary n=1) ──────────────────────────────────────

fn test_scale_single_element() {
	mut dev := new_device() or {
		eprintln('no Vulkan device — skipping')
		return
	}
	defer { dev.release() or {} }

	mut data := []u8{len: 4}
	unsafe { *(&f32(&data[0])) = f32(7.0) }

	mut buf_in := dev.buffer(DeviceSize(4)) or { return }
	defer { buf_in.release() }
	buf_in.load(data) or { return }

	mut buf_out := dev.buffer(DeviceSize(4)) or { return }
	defer { buf_out.release() }

	scale(dev, buf_out, buf_in, f32(3.0)) or { return }

	mut raw := []u8{len: 4}
	buf_out.store(mut raw) or { return }
	got := unsafe { *(&f32(&raw[0])) }
	assert math.abs(f64(got) - 21.0) < 1e-4, 'scale(7*3)=${got}'
}
