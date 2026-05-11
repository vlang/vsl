module vulkan

import vsl.vulkan.internal.dl

// ============================================================================
// Vulkan function pointer types and dlopen-based wrappers
//
// Each function is resolved at runtime via dlsym and cast to the appropriate
// function pointer type before calling. Compiled when -d vsl_vulkan_dlopen.
// ============================================================================

// --------------------------------------------------------------------------
// Instance
// --------------------------------------------------------------------------

type FnCreateInstance = fn (&C.VkInstanceCreateInfo, &AllocationCallbacks, &VkInstance) Result

@['inline']
fn vk_create_instance(pCreateInfo &C.VkInstanceCreateInfo, pAllocator &AllocationCallbacks, pInstance &VkInstance) Result {
	f := dl.get_sym('vkCreateInstance') or { return result_error_extension_not_present }
	sfn := FnCreateInstance(f)
	return sfn(pCreateInfo, pAllocator, pInstance)
}

type FnDestroyInstance = fn (VkInstance, &AllocationCallbacks)

@['inline']
fn vk_destroy_instance(instance VkInstance, pAllocator &AllocationCallbacks) {
	f := dl.get_sym('vkDestroyInstance') or { return }
	sfn := FnDestroyInstance(f)
	sfn(instance, pAllocator)
}

// --------------------------------------------------------------------------
// Physical device discovery
// --------------------------------------------------------------------------

type FnEnumeratePhysicalDevices = fn (VkInstance, &u32, &VkPhysicalDevice) Result

@['inline']
fn vk_enumerate_physical_devices(instance VkInstance, pPhysicalDeviceCount &u32, pPhysicalDevices &VkPhysicalDevice) Result {
	f := dl.get_sym('vkEnumeratePhysicalDevices') or { return result_error_extension_not_present }
	sfn := FnEnumeratePhysicalDevices(f)
	return sfn(instance, pPhysicalDeviceCount, pPhysicalDevices)
}

type FnGetPhysicalDeviceProperties = fn (VkPhysicalDevice, &C.VkPhysicalDeviceProperties)

@['inline']
fn vk_get_physical_device_properties(gpu VkPhysicalDevice, pProperties &C.VkPhysicalDeviceProperties) {
	f := dl.get_sym('vkGetPhysicalDeviceProperties') or { return }
	sfn := FnGetPhysicalDeviceProperties(f)
	sfn(gpu, pProperties)
}

type FnGetPhysicalDeviceMemoryProperties = fn (VkPhysicalDevice, &C.VkPhysicalDeviceMemoryProperties)

@['inline']
fn vk_get_physical_device_memory_properties(gpu VkPhysicalDevice, pMemoryProperties &C.VkPhysicalDeviceMemoryProperties) {
	f := dl.get_sym('vkGetPhysicalDeviceMemoryProperties') or { return }
	sfn := FnGetPhysicalDeviceMemoryProperties(f)
	sfn(gpu, pMemoryProperties)
}

type FnGetPhysicalDeviceQueueFamilyProperties = fn (VkPhysicalDevice, &u32, &C.VkQueueFamilyProperties)

@['inline']
fn vk_get_physical_device_queue_family_properties(gpu VkPhysicalDevice, pCount &u32, pProperties &C.VkQueueFamilyProperties) {
	f := dl.get_sym('vkGetPhysicalDeviceQueueFamilyProperties') or { return }
	sfn := FnGetPhysicalDeviceQueueFamilyProperties(f)
	sfn(gpu, pCount, pProperties)
}

type FnGetPhysicalDeviceFeatures = fn (VkPhysicalDevice, &C.VkPhysicalDeviceFeatures)

@['inline']
fn vk_get_physical_device_features(gpu VkPhysicalDevice, pFeatures &C.VkPhysicalDeviceFeatures) {
	f := dl.get_sym('vkGetPhysicalDeviceFeatures') or { return }
	sfn := FnGetPhysicalDeviceFeatures(f)
	sfn(gpu, pFeatures)
}

// --------------------------------------------------------------------------
// Device creation
// --------------------------------------------------------------------------

type FnCreateDevice = fn (VkPhysicalDevice, &C.VkDeviceCreateInfo, &AllocationCallbacks, &VkDevice) Result

@['inline']
fn vk_create_device(gpu VkPhysicalDevice, pCreateInfo &C.VkDeviceCreateInfo, pAllocator &AllocationCallbacks, pDevice &VkDevice) Result {
	f := dl.get_sym('vkCreateDevice') or { return result_error_extension_not_present }
	sfn := FnCreateDevice(f)
	return sfn(gpu, pCreateInfo, pAllocator, pDevice)
}

type FnDestroyDevice = fn (VkDevice, &AllocationCallbacks)

@['inline']
fn vk_destroy_device(device VkDevice, pAllocator &AllocationCallbacks) {
	f := dl.get_sym('vkDestroyDevice') or { return }
	sfn := FnDestroyDevice(f)
	sfn(device, pAllocator)
}

// --------------------------------------------------------------------------
// Queue
// --------------------------------------------------------------------------

type FnGetDeviceQueue = fn (VkDevice, u32, u32, &VkQueue)

@['inline']
fn vk_get_device_queue(device VkDevice, queueFamilyIndex u32, queueIndex u32, pQueue &VkQueue) {
	f := dl.get_sym('vkGetDeviceQueue') or { return }
	sfn := FnGetDeviceQueue(f)
	sfn(device, queueFamilyIndex, queueIndex, pQueue)
}

type FnQueueSubmit = fn (VkQueue, u32, &C.VkSubmitInfo, VkFence) Result

@['inline']
fn vk_queue_submit(queue VkQueue, submitCount u32, pSubmitInfos &C.VkSubmitInfo, fence VkFence) Result {
	f := dl.get_sym('vkQueueSubmit') or { return result_error_extension_not_present }
	sfn := FnQueueSubmit(f)
	return sfn(queue, submitCount, pSubmitInfos, fence)
}

type FnQueueWaitIdle = fn (VkQueue) Result

@['inline']
fn vk_queue_wait_idle(queue VkQueue) Result {
	f := dl.get_sym('vkQueueWaitIdle') or { return result_error_extension_not_present }
	sfn := FnQueueWaitIdle(f)
	return sfn(queue)
}

type FnDeviceWaitIdle = fn (VkDevice) Result

@['inline']
fn vk_device_wait_idle(device VkDevice) Result {
	f := dl.get_sym('vkDeviceWaitIdle') or { return result_error_extension_not_present }
	sfn := FnDeviceWaitIdle(f)
	return sfn(device)
}

// --------------------------------------------------------------------------
// Memory
// --------------------------------------------------------------------------

type FnAllocateMemory = fn (VkDevice, &C.VkMemoryAllocateInfo, &AllocationCallbacks, &VkDeviceMemory) Result

@['inline']
fn vk_allocate_memory(device VkDevice, pAllocateInfo &C.VkMemoryAllocateInfo, pAllocator &AllocationCallbacks, pMemory &VkDeviceMemory) Result {
	f := dl.get_sym('vkAllocateMemory') or { return result_error_extension_not_present }
	sfn := FnAllocateMemory(f)
	return sfn(device, pAllocateInfo, pAllocator, pMemory)
}

type FnFreeMemory = fn (VkDevice, VkDeviceMemory, &AllocationCallbacks)

@['inline']
fn vk_free_memory(device VkDevice, memory VkDeviceMemory, pAllocator &AllocationCallbacks) {
	f := dl.get_sym('vkFreeMemory') or { return }
	sfn := FnFreeMemory(f)
	sfn(device, memory, pAllocator)
}

type FnMapMemory = fn (VkDevice, VkDeviceMemory, DeviceSize, DeviceSize, u32, &voidptr) Result

@['inline']
fn vk_map_memory(device VkDevice, memory VkDeviceMemory, offset DeviceSize, size DeviceSize, flags u32, ppData &voidptr) Result {
	f := dl.get_sym('vkMapMemory') or { return result_error_extension_not_present }
	sfn := FnMapMemory(f)
	return sfn(device, memory, offset, size, flags, ppData)
}

type FnUnmapMemory = fn (VkDevice, VkDeviceMemory)

@['inline']
fn vk_unmap_memory(device VkDevice, memory VkDeviceMemory) {
	f := dl.get_sym('vkUnmapMemory') or { return }
	sfn := FnUnmapMemory(f)
	sfn(device, memory)
}

type FnFlushMappedMemoryRanges = fn (VkDevice, u32, &C.VkMappedMemoryRange) Result

@['inline']
fn vk_flush_mapped_memory_ranges(device VkDevice, memoryRangeCount u32, pMemoryRanges &C.VkMappedMemoryRange) Result {
	f := dl.get_sym('vkFlushMappedMemoryRanges') or { return result_error_extension_not_present }
	sfn := FnFlushMappedMemoryRanges(f)
	return sfn(device, memoryRangeCount, pMemoryRanges)
}

type FnGetMemoryRequirements = fn (VkDevice, VkBuffer, &C.VkMemoryRequirements)

@['inline']
fn vk_get_memory_requirements(device VkDevice, buffer VkBuffer, pMemoryRequirements &C.VkMemoryRequirements) {
	f := dl.get_sym('vkGetBufferMemoryRequirements') or { return }
	sfn := FnGetMemoryRequirements(f)
	sfn(device, buffer, pMemoryRequirements)
}

// --------------------------------------------------------------------------
// Buffer
// --------------------------------------------------------------------------

type FnCreateBuffer = fn (VkDevice, &C.VkBufferCreateInfo, &AllocationCallbacks, &VkBuffer) Result

@['inline']
fn vk_create_buffer(device VkDevice, pCreateInfo &C.VkBufferCreateInfo, pAllocator &AllocationCallbacks, pBuffer &VkBuffer) Result {
	f := dl.get_sym('vkCreateBuffer') or { return result_error_extension_not_present }
	sfn := FnCreateBuffer(f)
	return sfn(device, pCreateInfo, pAllocator, pBuffer)
}

type FnDestroyBuffer = fn (VkDevice, VkBuffer, &AllocationCallbacks)

@['inline']
fn vk_destroy_buffer(device VkDevice, buffer VkBuffer, pAllocator &AllocationCallbacks) {
	f := dl.get_sym('vkDestroyBuffer') or { return }
	sfn := FnDestroyBuffer(f)
	sfn(device, buffer, pAllocator)
}

type FnBindBufferMemory = fn (VkDevice, VkBuffer, VkDeviceMemory, DeviceSize) Result

@['inline']
fn vk_bind_buffer_memory(device VkDevice, buffer VkBuffer, memory VkDeviceMemory, memOffset DeviceSize) Result {
	f := dl.get_sym('vkBindBufferMemory') or { return result_error_extension_not_present }
	sfn := FnBindBufferMemory(f)
	return sfn(device, buffer, memory, memOffset)
}

// --------------------------------------------------------------------------
// Shader module
// --------------------------------------------------------------------------

type FnCreateShaderModule = fn (VkDevice, &C.VkShaderModuleCreateInfo, &AllocationCallbacks, &VkShaderModule) Result

@['inline']
fn vk_create_shader_module(device VkDevice, pCreateInfo &C.VkShaderModuleCreateInfo, pAllocator &AllocationCallbacks, pShaderModule &VkShaderModule) Result {
	f := dl.get_sym('vkCreateShaderModule') or { return result_error_extension_not_present }
	sfn := FnCreateShaderModule(f)
	return sfn(device, pCreateInfo, pAllocator, pShaderModule)
}

type FnDestroyShaderModule = fn (VkDevice, VkShaderModule, &AllocationCallbacks)

@['inline']
fn vk_destroy_shader_module(device VkDevice, shaderModule VkShaderModule, pAllocator &AllocationCallbacks) {
	f := dl.get_sym('vkDestroyShaderModule') or { return }
	sfn := FnDestroyShaderModule(f)
	sfn(device, shaderModule, pAllocator)
}

// --------------------------------------------------------------------------
// Pipeline layout
// --------------------------------------------------------------------------

type FnCreatePipelineLayout = fn (VkDevice, &C.VkPipelineLayoutCreateInfo, &AllocationCallbacks, &VkPipelineLayout) Result

@['inline']
fn vk_create_pipeline_layout(device VkDevice, pCreateInfo &C.VkPipelineLayoutCreateInfo, pAllocator &AllocationCallbacks, pPipelineLayout &VkPipelineLayout) Result {
	f := dl.get_sym('vkCreatePipelineLayout') or { return result_error_extension_not_present }
	sfn := FnCreatePipelineLayout(f)
	return sfn(device, pCreateInfo, pAllocator, pPipelineLayout)
}

type FnDestroyPipelineLayout = fn (VkDevice, VkPipelineLayout, &AllocationCallbacks)

@['inline']
fn vk_destroy_pipeline_layout(device VkDevice, pipelineLayout VkPipelineLayout, pAllocator &AllocationCallbacks) {
	f := dl.get_sym('vkDestroyPipelineLayout') or { return }
	sfn := FnDestroyPipelineLayout(f)
	sfn(device, pipelineLayout, pAllocator)
}

// --------------------------------------------------------------------------
// Compute pipeline
// --------------------------------------------------------------------------

type FnCreateComputePipelines = fn (VkDevice, VkPipelineCache, u32, &C.VkComputePipelineCreateInfo, &AllocationCallbacks, &VkPipeline) Result

@['inline']
fn vk_create_compute_pipelines(device VkDevice, pipelineCache VkPipelineCache, createInfoCount u32, pCreateInfos &C.VkComputePipelineCreateInfo, pAllocator &AllocationCallbacks, pPipelines &VkPipeline) Result {
	f := dl.get_sym('vkCreateComputePipelines') or { return result_error_extension_not_present }
	sfn := FnCreateComputePipelines(f)
	return sfn(device, pipelineCache, createInfoCount, pCreateInfos, pAllocator, pPipelines)
}

type FnDestroyPipeline = fn (VkDevice, VkPipeline, &AllocationCallbacks)

@['inline']
fn vk_destroy_pipeline(device VkDevice, pipeline VkPipeline, pAllocator &AllocationCallbacks) {
	f := dl.get_sym('vkDestroyPipeline') or { return }
	sfn := FnDestroyPipeline(f)
	sfn(device, pipeline, pAllocator)
}

// --------------------------------------------------------------------------
// Descriptor set layout
// --------------------------------------------------------------------------

type FnCreateDescriptorSetLayout = fn (VkDevice, &C.VkDescriptorSetLayoutCreateInfo, &AllocationCallbacks, &VkDescriptorSetLayout) Result

@['inline']
fn vk_create_descriptor_set_layout(device VkDevice, pCreateInfo &C.VkDescriptorSetLayoutCreateInfo, pAllocator &AllocationCallbacks, pSetLayout &VkDescriptorSetLayout) Result {
	f := dl.get_sym('vkCreateDescriptorSetLayout') or { return result_error_extension_not_present }
	sfn := FnCreateDescriptorSetLayout(f)
	return sfn(device, pCreateInfo, pAllocator, pSetLayout)
}

type FnDestroyDescriptorSetLayout = fn (VkDevice, VkDescriptorSetLayout, &AllocationCallbacks)

@['inline']
fn vk_destroy_descriptor_set_layout(device VkDevice, descriptorSetLayout VkDescriptorSetLayout, pAllocator &AllocationCallbacks) {
	f := dl.get_sym('vkDestroyDescriptorSetLayout') or { return }
	sfn := FnDestroyDescriptorSetLayout(f)
	sfn(device, descriptorSetLayout, pAllocator)
}

// --------------------------------------------------------------------------
// Descriptor pool / sets
// --------------------------------------------------------------------------

type FnCreateDescriptorPool = fn (VkDevice, &C.VkDescriptorPoolCreateInfo, &AllocationCallbacks, &VkDescriptorPool) Result

@['inline']
fn vk_create_descriptor_pool(device VkDevice, pCreateInfo &C.VkDescriptorPoolCreateInfo, pAllocator &AllocationCallbacks, pDescriptorPool &VkDescriptorPool) Result {
	f := dl.get_sym('vkCreateDescriptorPool') or { return result_error_extension_not_present }
	sfn := FnCreateDescriptorPool(f)
	return sfn(device, pCreateInfo, pAllocator, pDescriptorPool)
}

type FnDestroyDescriptorPool = fn (VkDevice, VkDescriptorPool, &AllocationCallbacks)

@['inline']
fn vk_destroy_descriptor_pool(device VkDevice, descriptorPool VkDescriptorPool, pAllocator &AllocationCallbacks) {
	f := dl.get_sym('vkDestroyDescriptorPool') or { return }
	sfn := FnDestroyDescriptorPool(f)
	sfn(device, descriptorPool, pAllocator)
}

type FnAllocateDescriptorSets = fn (VkDevice, &C.VkDescriptorSetAllocateInfo, &VkDescriptorSet) Result

@['inline']
fn vk_allocate_descriptor_sets(device VkDevice, pAllocateInfo &C.VkDescriptorSetAllocateInfo, pDescriptorSets &VkDescriptorSet) Result {
	f := dl.get_sym('vkAllocateDescriptorSets') or { return result_error_extension_not_present }
	sfn := FnAllocateDescriptorSets(f)
	return sfn(device, pAllocateInfo, pDescriptorSets)
}

type FnFreeDescriptorSets = fn (VkDevice, VkDescriptorPool, u32, &VkDescriptorSet) Result

@['inline']
fn vk_free_descriptor_sets(device VkDevice, descriptorPool VkDescriptorPool, descriptorSetCount u32, pDescriptorSets &VkDescriptorSet) Result {
	f := dl.get_sym('vkFreeDescriptorSets') or { return result_error_extension_not_present }
	sfn := FnFreeDescriptorSets(f)
	return sfn(device, descriptorPool, descriptorSetCount, pDescriptorSets)
}

type FnUpdateDescriptorSets = fn (VkDevice, u32, &C.VkWriteDescriptorSet, u32, &C.VkCopyDescriptorSet)

@['inline']
fn vk_update_descriptor_sets(device VkDevice, writeCount u32, pWrites &C.VkWriteDescriptorSet, copyCount u32, pCopies &C.VkCopyDescriptorSet) {
	f := dl.get_sym('vkUpdateDescriptorSets') or { return }
	sfn := FnUpdateDescriptorSets(f)
	sfn(device, writeCount, pWrites, copyCount, pCopies)
}

// --------------------------------------------------------------------------
// Command pool / buffers
// --------------------------------------------------------------------------

type FnCreateCommandPool = fn (VkDevice, &C.VkCommandPoolCreateInfo, &AllocationCallbacks, &VkCommandPool) Result

@['inline']
fn vk_create_command_pool(device VkDevice, pCreateInfo &C.VkCommandPoolCreateInfo, pAllocator &AllocationCallbacks, pCommandPool &VkCommandPool) Result {
	f := dl.get_sym('vkCreateCommandPool') or { return result_error_extension_not_present }
	sfn := FnCreateCommandPool(f)
	return sfn(device, pCreateInfo, pAllocator, pCommandPool)
}

type FnDestroyCommandPool = fn (VkDevice, VkCommandPool, &AllocationCallbacks)

@['inline']
fn vk_destroy_command_pool(device VkDevice, commandPool VkCommandPool, pAllocator &AllocationCallbacks) {
	f := dl.get_sym('vkDestroyCommandPool') or { return }
	sfn := FnDestroyCommandPool(f)
	sfn(device, commandPool, pAllocator)
}

type FnAllocateCommandBuffers = fn (VkDevice, &C.VkCommandBufferAllocateInfo, &VkCommandBuffer) Result

@['inline']
fn vk_allocate_command_buffers(device VkDevice, pAllocateInfo &C.VkCommandBufferAllocateInfo, pCommandBuffers &VkCommandBuffer) Result {
	f := dl.get_sym('vkAllocateCommandBuffers') or { return result_error_extension_not_present }
	sfn := FnAllocateCommandBuffers(f)
	return sfn(device, pAllocateInfo, pCommandBuffers)
}

type FnFreeCommandBuffers = fn (VkDevice, VkCommandPool, u32, &VkCommandBuffer)

@['inline']
fn vk_free_command_buffers(device VkDevice, commandPool VkCommandPool, commandBufferCount u32, pCommandBuffers &VkCommandBuffer) {
	f := dl.get_sym('vkFreeCommandBuffers') or { return }
	sfn := FnFreeCommandBuffers(f)
	sfn(device, commandPool, commandBufferCount, pCommandBuffers)
}

type FnBeginCommandBuffer = fn (VkCommandBuffer, &C.VkCommandBufferBeginInfo) Result

@['inline']
fn vk_begin_command_buffer(commandBuffer VkCommandBuffer, pBeginInfo &C.VkCommandBufferBeginInfo) Result {
	f := dl.get_sym('vkBeginCommandBuffer') or { return result_error_extension_not_present }
	sfn := FnBeginCommandBuffer(f)
	return sfn(commandBuffer, pBeginInfo)
}

type FnEndCommandBuffer = fn (VkCommandBuffer) Result

@['inline']
fn vk_end_command_buffer(commandBuffer VkCommandBuffer) Result {
	f := dl.get_sym('vkEndCommandBuffer') or { return result_error_extension_not_present }
	sfn := FnEndCommandBuffer(f)
	return sfn(commandBuffer)
}

// --------------------------------------------------------------------------
// Fence / sync
// --------------------------------------------------------------------------

type FnCreateFence = fn (VkDevice, &C.VkFenceCreateInfo, &AllocationCallbacks, &VkFence) Result

@['inline']
fn vk_create_fence(device VkDevice, pCreateInfo &C.VkFenceCreateInfo, pAllocator &AllocationCallbacks, pFence &VkFence) Result {
	f := dl.get_sym('vkCreateFence') or { return result_error_extension_not_present }
	sfn := FnCreateFence(f)
	return sfn(device, pCreateInfo, pAllocator, pFence)
}

type FnDestroyFence = fn (VkDevice, VkFence, &AllocationCallbacks)

@['inline']
fn vk_destroy_fence(device VkDevice, fence VkFence, pAllocator &AllocationCallbacks) {
	f := dl.get_sym('vkDestroyFence') or { return }
	sfn := FnDestroyFence(f)
	sfn(device, fence, pAllocator)
}

type FnWaitForFences = fn (VkDevice, u32, &VkFence, bool, u64) Result

@['inline']
fn vk_wait_for_fences(device VkDevice, fenceCount u32, pFences &VkFence, waitAll bool, timeout u64) Result {
	f := dl.get_sym('vkWaitForFences') or { return result_error_extension_not_present }
	sfn := FnWaitForFences(f)
	return sfn(device, fenceCount, pFences, waitAll, timeout)
}

// --------------------------------------------------------------------------
// Command functions (graphics pipeline barriers, dispatch)
// --------------------------------------------------------------------------

type FnCmdPipelineBarrier = fn (VkCommandBuffer, PipelineStageFlags, PipelineStageFlags, u32, u32, &C.VkMemoryBarrier, u32, &C.VkBufferMemoryBarrier, u32, &C.VkImageMemoryBarrier)

@['inline']
fn vk_cmd_pipeline_barrier(cmdbuf VkCommandBuffer, srcStageMask PipelineStageFlags, dstStageMask PipelineStageFlags, dependencyFlags u32, memoryBarrierCount u32, pMemoryBarriers &C.VkMemoryBarrier, bufferMemoryBarrierCount u32, pBufferMemoryBarriers &C.VkBufferMemoryBarrier, imageMemoryBarrierCount u32, pImageMemoryBarriers &C.VkImageMemoryBarrier) {
	f := dl.get_sym('vkCmdPipelineBarrier') or { return }
	sfn := FnCmdPipelineBarrier(f)
	sfn(cmdbuf, srcStageMask, dstStageMask, dependencyFlags, memoryBarrierCount, pMemoryBarriers,
		bufferMemoryBarrierCount, pBufferMemoryBarriers, imageMemoryBarrierCount,
		pImageMemoryBarriers)
}

type FnCmdDispatch = fn (VkCommandBuffer, u32, u32, u32)

@['inline']
fn vk_cmd_dispatch(cmdbuf VkCommandBuffer, groupCountX u32, groupCountY u32, groupCountZ u32) {
	f := dl.get_sym('vkCmdDispatch') or { return }
	sfn := FnCmdDispatch(f)
	sfn(cmdbuf, groupCountX, groupCountY, groupCountZ)
}

type FnCmdBindPipeline = fn (VkCommandBuffer, u32, VkPipeline)

@['inline']
fn vk_cmd_bind_pipeline(cmdbuf VkCommandBuffer, pipelineBindPoint u32, pipeline VkPipeline) {
	f := dl.get_sym('vkCmdBindPipeline') or { return }
	sfn := FnCmdBindPipeline(f)
	sfn(cmdbuf, pipelineBindPoint, pipeline)
}

type FnCmdBindDescriptorSets = fn (VkCommandBuffer, u32, VkPipelineLayout, u32, u32, &VkDescriptorSet, u32, &u32)

@['inline']
fn vk_cmd_bind_descriptor_sets(cmdbuf VkCommandBuffer, pipelineBindPoint u32, layout VkPipelineLayout, firstSet u32, descriptorSetCount u32, pDescriptorSets &VkDescriptorSet, dynamicOffsetCount u32, pDynamicOffsets &u32) {
	f := dl.get_sym('vkCmdBindDescriptorSets') or { return }
	sfn := FnCmdBindDescriptorSets(f)
	sfn(cmdbuf, pipelineBindPoint, layout, firstSet, descriptorSetCount, pDescriptorSets,
		dynamicOffsetCount, pDynamicOffsets)
}

type FnEnumerateInstanceLayerProperties = fn (&u32, &C.VkLayerProperties) Result

fn vk_enumerate_instance_layer_properties(pPropertyCount &u32, pProperties &C.VkLayerProperties) Result {
	f := dl.get_sym('vkEnumerateInstanceLayerProperties') or {
		return result_error_feature_not_present
	}
	sfn := FnEnumerateInstanceLayerProperties(f)
	return sfn(pPropertyCount, pProperties)
}
