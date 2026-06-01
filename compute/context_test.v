module compute

import math

fn test_op_supported_cpu() {
	assert op_supported(.cpu, 'gemm')
	assert op_supported(.cpu, 'relu')
	assert op_supported(.cpu, 'softmax')
	assert op_supported(.cpu, 'layernorm')
	assert !op_supported(.cpu, 'conv2d')
	assert !op_supported(.auto, 'gemm')
}

fn test_op_supported_backend_tables_match_beta_contract() {
	assert op_supported(.cuda, 'conv2d')
	assert op_supported(.vulkan, 'mul_vec')
}

fn test_cpu_backend_support_table() {
	cpu := new_cpu_backend()
	assert cpu.supports('gemm')
	assert cpu.supports('layernorm')
	assert !cpu.supports('conv2d')
}

fn test_cpu_gemm_dispatch() {
	ctx := new_context(.cpu)
	a := [f64(1), 2, 3, 4]
	b := [f64(5), 6, 7, 8]
	out := gemm(ctx, a, b, 2, 2, 2)!
	assert out.len == 4
	assert math.abs(out[0] - 19.0) < 1e-9
}

fn test_cpu_relu_dispatch() {
	ctx := new_context(.cpu)
	out := relu(ctx, [-1.0, 2.0, -3.0])!
	assert out == [0.0, 2.0, 0.0]
}

fn test_available_backends_includes_cpu() {
	backs := available_backends()
	mut has_cpu := false
	for b in backs {
		if b == .cpu {
			has_cpu = true
		}
	}
	assert has_cpu
}

fn test_new_context_cpu_backend() {
	ctx := new_context(.cpu)
	assert ctx.backend == .cpu
	assert ctx.strict == false
}
