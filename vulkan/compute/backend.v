// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module compute

import vsl.vulkan

// VulkanBackend implements ComputeBackend using the Vulkan compute API.
pub struct VulkanBackend {
mut:
	dev &vulkan.Device
}

pub fn new_vulkan_backend(dev &vulkan.Device) VulkanBackend {
	return VulkanBackend{
		dev: dev
	}
}

pub fn (b &VulkanBackend) name() string {
	return 'vulkan'
}

pub fn (b &VulkanBackend) supports(op string) bool {
	return op in ['gemm', 'gemv', 'relu', 'sigmoid']
}

pub fn (b &VulkanBackend) gemm(a_data []f64, b_data []f64, m int, n int, k int) ![]f64 {
	return vk_compute.gemm_vulkan(b.dev, a_data, b_data, m, n, k)
}

pub fn (b &VulkanBackend) gemv(a_data []f64, x_data []f64, m int, n int) ![]f64 {
	return vk_compute.gemv_vulkan(b.dev, a_data, x_data, m, n)
}

pub fn (b &VulkanBackend) relu(x_data []f64) ![]f64 {
	return vk_compute.relu_vulkan(b.dev, x_data)
}

pub fn (b &VulkanBackend) sigmoid(x_data []f64) ![]f64 {
	return vk_compute.sigmoid_vulkan(b.dev, x_data)
}

pub fn (b &VulkanBackend) tanh(x_data []f64) ![]f64 {
	return error('VulkanBackend.tanh: not implemented yet')
}

pub fn (b &VulkanBackend) add_vec(a_data []f64, b_data []f64) ![]f64 {
	return error('VulkanBackend.add_vec: not implemented yet')
}

pub fn (b &VulkanBackend) mul_vec(a_data []f64, b_data []f64) ![]f64 {
	return error('VulkanBackend.mul_vec: not implemented yet')
}

pub fn (b &VulkanBackend) add_scalar(x_data []f64, s f64) ![]f64 {
	return error('VulkanBackend.add_scalar: not implemented yet')
}

pub fn (b &VulkanBackend) mul_scalar(x_data []f64, s f64) ![]f64 {
	return error('VulkanBackend.mul_scalar: not implemented yet')
}

pub fn (b &VulkanBackend) softmax(x_data []f64) ![]f64 {
	return error('VulkanBackend.softmax: not implemented yet')
}

pub fn (b &VulkanBackend) layernorm(x_data []f64, gamma []f64, beta []f64) ![]f64 {
	return error('VulkanBackend.layernorm: not implemented yet')
}

pub fn (b &VulkanBackend) conv2d(input []f64, kernel []f64, batch int, in_h int, in_w int, in_ch int, out_ch int, k_h int, k_w int, stride_h int, stride_w int) ![]f64 {
	return error('VulkanBackend.conv2d: not implemented yet')
}

// to_internal converts row-major to Vulkan's column-major layout.
pub fn (b &VulkanBackend) to_internal(data []f64, rows int, cols int) ![]f64 {
	return row_to_col_major(data, rows, cols)
}

// from_internal converts Vulkan's column-major layout back to row-major.
pub fn (b &VulkanBackend) from_internal(data []f64, rows int, cols int) ![]f64 {
	return col_to_row_major(data, rows, cols)
}