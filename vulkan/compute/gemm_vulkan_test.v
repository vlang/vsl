module compute

import math
import vsl.vulkan

fn test_gemm_vulkan_matches_reference_with_partial_dimensions() {
	mut dev := vulkan.new_device() or { return }
	defer {
		dev.release() or {}
	}
	for dims in [[3, 5, 7], [17, 19, 23], [31, 16, 18]] {
		m := dims[0]
		n := dims[1]
		k := dims[2]
		a := []f32{len: m * k, init: f32(index % 11 + 1) / 11}
		b := []f32{len: k * n, init: f32(index % 7 + 1) / 7}
		actual := gemm_vulkan_f32(dev, a, b, m, n, k) or { panic(err) }
		for row in 0 .. m {
			for column in 0 .. n {
				mut expected := f32(0)
				for inner in 0 .. k {
					expected += a[row * k + inner] * b[inner * n + column]
				}
				assert math.abs(actual[row * n + column] - expected) < 1e-4
			}
		}
	}
}
