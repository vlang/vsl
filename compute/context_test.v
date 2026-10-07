module compute

import math

fn test_op_supported_cpu() {
	assert op_supported(.cpu, 'gemm')
	assert op_supported(.cpu, 'relu')
	assert op_supported(.cpu, 'softmax')
	assert op_supported(.cpu, 'layernorm')
	assert op_supported(.cpu, 'conv2d')
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
	assert cpu.supports('conv2d')
}

fn test_cpu_conv2d_dispatch_uses_nchw_layout() {
	ctx := new_context(.cpu)
	input := [f64(1), 2, 3, 4, 5, 6, 7, 8, 9]
	kernel := [f64(1), 0, 0, 1]
	out := conv2d(ctx, input, kernel, 1, 3, 3, 1, 1, 2, 2, 1, 1) or { panic(err) }
	assert out == [6.0, 8.0, 12.0, 14.0]
}

fn test_cpu_conv2d_batches_and_channels() {
	cpu := new_cpu_backend()
	input := [f64(1), 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
	kernel := [f64(1), 0, 0, 1]
	out := cpu.conv2d(input, kernel, 2, 2, 2, 2, 2, 1, 1, 1, 1) or { panic(err) }
	assert out == [1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
}

fn test_cpu_conv2d_rejects_bad_shapes_and_strides() {
	cpu := new_cpu_backend()
	if _ := cpu.conv2d([f64(1)], [1], 1, 3, 3, 1, 1, 2, 2, 1, 1) {
		assert false, 'expected invalid input length to fail'
	}
	if _ := cpu.conv2d([f64(1)], [1], 1, 1, 1, 1, 1, 1, 1, 0, 1) {
		assert false, 'expected zero stride to fail'
	}
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

fn test_unavailable_backend_falls_back_unless_strict() {
	for backend in [Backend.cuda, .vcl, .vulkan] {
		if backend in available_backends() {
			continue
		}
		ctx := new_context(backend)
		fallback := ctx.resolve_backend() or { panic(err) }
		assert fallback.name() == 'cpu'

		mut strict_ctx := new_context(backend)
		strict_ctx.with_strict(true)
		mut rejected := false
		_ := strict_ctx.resolve_backend() or {
			rejected = err.msg().contains('not available in this build')
			new_cpu_backend()
		}
		assert rejected
	}
}
