module compute

import math
import os
import vsl.vulkan

fn test_adam_step_vulkan_f32_matches_cpu() ! {
	if os.getenv('VSL_TEST_VULKAN') != '1' {
		return
	}
	dev := vulkan.new_device() or { return }
	defer { dev.release() or {} }

	grad := [f32(1.0), f32(2.0), f32(0.5)]
	mut theta_gpu := [f32(5.0), f32(5.0), f32(5.0)]
	mut m_gpu := [f32(0.0), f32(0.0), f32(0.0)]
	mut v_gpu := [f32(0.0), f32(0.0), f32(0.0)]

	mut theta_cpu := [f32(5.0), f32(5.0), f32(5.0)]
	mut m_cpu := [f32(0.0), f32(0.0), f32(0.0)]
	mut v_cpu := [f32(0.0), f32(0.0), f32(0.0)]

	p := AdamStepParams{
		beta1:   0.9
		beta2:   0.999
		lr_t:    0.001
		epsilon: 1e-8
	}
	adam_step_cpu_f32(grad, mut theta_cpu, mut m_cpu, mut v_cpu, p)
	adam_step_vulkan_f32(dev, grad, mut theta_gpu, mut m_gpu, mut v_gpu, p)!

	for i in 0 .. grad.len {
		assert math.abs(theta_cpu[i] - theta_gpu[i]) < 1e-4
		assert math.abs(m_cpu[i] - m_gpu[i]) < 1e-4
		assert math.abs(v_cpu[i] - v_gpu[i]) < 1e-4
	}
}

fn adam_step_cpu_f32(grad []f32, mut theta []f32, mut m []f32, mut v []f32, p AdamStepParams) {
	b1 := f32(p.beta1)
	b2 := f32(p.beta2)
	lr := f32(p.lr_t)
	eps := f32(p.epsilon)
	for i in 0 .. grad.len {
		g := grad[i]
		m[i] = b1 * m[i] + f32(1.0 - p.beta1) * g
		v[i] = b2 * v[i] + f32(1.0 - p.beta2) * g * g
		theta[i] -= lr * m[i] / (f32(math.sqrt(f64(v[i]))) + eps)
	}
}
