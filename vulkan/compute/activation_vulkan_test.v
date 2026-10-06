module compute

import math
import os
import vsl.vulkan

fn test_activation_vulkan_f32_matches_cpu() ! {
	if os.getenv('VSL_TEST_VULKAN') != '1' {
		return
	}
	dev := vulkan.new_device() or { return }
	defer { dev.release() or {} }

	input := [f32(-20), -3, -1, 0, 1, 3, 20, f32(math.inf(-1))]
	softplus := softplus_vulkan_f32(dev, input)!
	selu := selu_vulkan_f32(dev, input)!
	hardswish := hardswish_vulkan_f32(dev, input)!

	for i, x in input {
		x64 := f64(x)
		softplus_expected := if x64 > 0 {
			x64 + math.log1p(math.exp(-x64))
		} else {
			math.log1p(math.exp(x64))
		}
		selu_expected := if x64 > 0 {
			1.0507009873554805 * x64
		} else {
			1.0507009873554805 * 1.6732632423543772 * math.expm1(x64)
		}
		hardswish_expected := if x64 <= -3.0 {
			0.0
		} else if x64 >= 3.0 {
			x64
		} else {
			x64 * math.max(0.0, math.min(x64 + 3.0, 6.0)) / 6.0
		}
		assert math.abs(f64(softplus[i]) - softplus_expected) < 1e-5
		assert math.abs(f64(selu[i]) - selu_expected) < 1e-5
		assert math.abs(f64(hardswish[i]) - hardswish_expected) < 1e-5
	}
}
