module vulkan

// ============================================================================
// Compute pipeline — wraps a SPIR-V shader into a vkPipeline
//
// Mirrors VCL Kernel pattern:
//   - ShaderModule + entry name → pipeline
//   - Descriptor set layout with bindings for storage buffers
//   - ComputePipeline layout + compute pipeline cached on Device
//
// Pipeline construction is delegated to a C helper (vk_create_compute_pipeline_simple)
// to work around V 0.5.1 @[typedef] struct layout bugs with nested pointer fields.
// ============================================================================

// ComputePipeline wraps a compiled Vulkan compute pipeline.
pub struct ComputePipeline {
pub mut:
	device          &Device
	pipeline_handle VkPipeline
	layout          VkPipelineLayout
	dsl             VkDescriptorSetLayout
	dp              VkDescriptorPool
	ds              VkDescriptorSet
}

// create_pipeline compiles a SPIR-V shader into a compute pipeline.
// The entry point name must match the GLSL `main` function (e.g., "main" for `main()`).
pub fn (d &Device) create_pipeline(spv []u32, entry string) !&ComputePipeline {
	mut shader_mod := VkShaderModule(unsafe { nil })
	mut layout := VkPipelineLayout(unsafe { nil })
	mut pl := VkPipeline(unsafe { nil })
	mut dsl := VkDescriptorSetLayout(unsafe { nil })
	mut dp := VkDescriptorPool(unsafe { nil })
	mut ds := VkDescriptorSet(unsafe { nil })

	// Delegate all Vulkan struct construction to C helper (avoids V's struct layout bug)
	vk_create_compute_pipeline_simple(
		d.device,
		entry.str,
		&spv[0],
		usize(spv.len * 4),
		&shader_mod,
		&layout,
		&pl,
		&dsl,
		&dp,
		&ds,
	)!

	// Shader module is no longer needed after pipeline creation
	vk_destroy_shader_module(d.device, shader_mod, unsafe { nil })

	return &ComputePipeline{
		device:          d
		pipeline_handle: pl
		layout:          layout
		dsl:             dsl
		dp:              dp
		ds:              ds
	}
}

// release destroys the pipeline and its resources.
pub fn (mut p ComputePipeline) release() {
	if isnil(p.device) {
		return
	}
	vk_device_wait_idle(p.device.device)
	vk_free_descriptor_sets(p.device.device, p.dp, 1, &p.ds)
	vk_destroy_descriptor_pool(p.device.device, p.dp, unsafe { nil })
	vk_destroy_pipeline(p.device.device, p.pipeline_handle, unsafe { nil })
	vk_destroy_pipeline_layout(p.device.device, p.layout, unsafe { nil })
	vk_destroy_descriptor_set_layout(p.device.device, p.dsl, unsafe { nil })
}

// update_buffer updates descriptor set binding to point to a GPU buffer.
pub fn (p &ComputePipeline) update_buffer(binding u32, buf &GpuBuffer) ! {
	buffer_info := C.VkDescriptorBufferInfo{
		buffer: buf.buf
		offset: DeviceSize(0)
		range:  buf.size
	}
	write := C.VkWriteDescriptorSet{
		sType:           structure_type_write_descriptor_set
		dstSet:          p.ds
		dstBinding:      binding
		descriptorCount: 1
		descriptorType:  descriptor_type_storage_buffer
		pBufferInfo:    &buffer_info
	}
	vk_update_descriptor_sets(p.device.device, 1, &write, 0, unsafe { nil })
}
