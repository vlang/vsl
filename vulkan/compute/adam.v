module compute

import vsl.vulkan

// AdamStepParams mirrors VTL optimizers.AdamStepParams (f64 scalars).
pub struct AdamStepParams {
pub:
	beta1   f64
	beta2   f64
	lr_t    f64
	epsilon f64
}

// adam_step_vulkan_f32 performs one fused Adam update on host f32 arrays via GPU.
pub fn adam_step_vulkan_f32(dev &vulkan.Device, grad []f32, mut theta []f32, mut m []f32, mut v []f32,
	p AdamStepParams) ! {
	n := grad.len
	if theta.len != n || m.len != n || v.len != n {
		return error('adam_step_vulkan_f32: buffer length mismatch')
	}
	if n == 0 {
		return
	}
	size := vulkan.DeviceSize(n * 4)
	mut g_buf := dev.buffer(size)!
	defer { g_buf.release() }
	mut t_buf := dev.buffer(size)!
	defer { t_buf.release() }
	mut m_buf := dev.buffer(size)!
	defer { m_buf.release() }
	mut v_buf := dev.buffer(size)!
	defer { v_buf.release() }

	mut g_bytes := []u8{len: n * 4}
	mut t_bytes := []u8{len: n * 4}
	mut m_bytes := []u8{len: n * 4}
	mut v_bytes := []u8{len: n * 4}
	unsafe {
		C.memcpy(g_bytes.data, grad.data, n * 4)
		C.memcpy(t_bytes.data, theta.data, n * 4)
		C.memcpy(m_bytes.data, m.data, n * 4)
		C.memcpy(v_bytes.data, v.data, n * 4)
	}
	g_buf.load(g_bytes)!
	t_buf.load(t_bytes)!
	m_buf.load(m_bytes)!
	v_buf.load(v_bytes)!

	vulkan.adam_step(dev, g_buf, t_buf, m_buf, v_buf, vulkan.AdamParams{
		beta1:   f32(p.beta1)
		beta2:   f32(p.beta2)
		lr_t:    f32(p.lr_t)
		epsilon: f32(p.epsilon)
	})!

	t_bytes = t_buf.store(mut t_bytes)!
	m_bytes = m_buf.store(mut m_bytes)!
	v_bytes = v_buf.store(mut v_bytes)!
	unsafe {
		C.memcpy(theta.data, t_bytes.data, n * 4)
		C.memcpy(m.data, m_bytes.data, n * 4)
		C.memcpy(v.data, v_bytes.data, n * 4)
	}
}
