module vulkan

// ============================================================================
// C helper function wrappers (from vulkan.h)
//
// V 0.5.1 has struct layout issues with @[typedef] structs containing pointer
// fields when heap-allocated via V's builtin__memdup. These helpers construct
// structs in C where layout is guaranteed correct.
//
// Pattern matches vsl/vcl/vcl.h which provides create_image_desc and friends.
// ============================================================================

fn C.vk_create_instance_simple(&char, u32, &char, u32, &VkInstance) int

@[inline]
fn vk_create_instance_simple(app_name &char, app_version u32, engine_name &char, engine_version u32, out &VkInstance) ! {
	res := C.vk_create_instance_simple(app_name, app_version, engine_name, engine_version, out)
	if res != 0 {
		return error('vulkan: vkCreateInstance failed: ${res}')
	}
}

fn C.vk_create_device_simple(VkPhysicalDevice, u32, &VkDevice, &VkQueue) int

@[inline]
fn vk_create_device_simple(gpu VkPhysicalDevice, qfi u32, out_device &VkDevice, out_queue &VkQueue) ! {
	res := C.vk_create_device_simple(gpu, qfi, out_device, out_queue)
	if res != 0 {
		return error('vulkan: vkCreateDevice failed: ${res}')
	}
}

fn C.vk_compute_pipeline_binding_count() u32

@[inline]
pub fn compute_pipeline_binding_count() u32 {
	return C.vk_compute_pipeline_binding_count()
}

fn C.vk_create_compute_pipeline_simple(VkDevice, &char, &u32, usize, &VkShaderModule, &VkPipelineLayout, &VkPipeline, &VkDescriptorSetLayout, &VkDescriptorPool, &VkDescriptorSet) int

@[inline]
fn vk_create_compute_pipeline_simple(device VkDevice, entry_name &char, spv_code &u32, spv_size usize, out_shader_mod &VkShaderModule, out_layout &VkPipelineLayout, out_pipeline &VkPipeline, out_dsl &VkDescriptorSetLayout, out_dp &VkDescriptorPool, out_ds &VkDescriptorSet) ! {
	res := C.vk_create_compute_pipeline_simple(device, entry_name, spv_code, spv_size,
		out_shader_mod, out_layout, out_pipeline, out_dsl, out_dp, out_ds)
	if res != 0 {
		return error('vulkan: vkCreateComputePipelines failed: ${res}')
	}
}
