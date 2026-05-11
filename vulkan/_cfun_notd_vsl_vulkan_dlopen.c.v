module vulkan

// ============================================================================
// Vulkan direct C function wrappers
//
// Each function is linked directly from libvulkan. Compiled by default
// (when -d vsl_vulkan_dlopen is NOT provided).
// ============================================================================

// --------------------------------------------------------------------------
// Instance
// --------------------------------------------------------------------------

fn C.vkCreateInstance(&C.VkInstanceCreateInfo, &AllocationCallbacks, &VkInstance) Result

@[inline]
fn vk_create_instance(pCreateInfo &C.VkInstanceCreateInfo, pAllocator &AllocationCallbacks, pInstance &VkInstance) Result {
	return C.vkCreateInstance(pCreateInfo, pAllocator, pInstance)
}

fn C.vkDestroyInstance(VkInstance, &AllocationCallbacks)

@[inline]
fn vk_destroy_instance(instance VkInstance, pAllocator &AllocationCallbacks) {
	C.vkDestroyInstance(instance, pAllocator)
}

// --------------------------------------------------------------------------
// Physical device discovery
// --------------------------------------------------------------------------

fn C.vkEnumeratePhysicalDevices(VkInstance, &u32, &VkPhysicalDevice) Result

@[inline]
fn vk_enumerate_physical_devices(instance VkInstance, pPhysicalDeviceCount &u32, pPhysicalDevices &VkPhysicalDevice) Result {
	return C.vkEnumeratePhysicalDevices(instance, pPhysicalDeviceCount, pPhysicalDevices)
}

fn C.vkGetPhysicalDeviceProperties(VkPhysicalDevice, &C.VkPhysicalDeviceProperties)

@[inline]
fn vk_get_physical_device_properties(gpu VkPhysicalDevice, pProperties &C.VkPhysicalDeviceProperties) {
	C.vkGetPhysicalDeviceProperties(gpu, pProperties)
}

fn C.vkGetPhysicalDeviceMemoryProperties(VkPhysicalDevice, &C.VkPhysicalDeviceMemoryProperties)

@[inline]
fn vk_get_physical_device_memory_properties(gpu VkPhysicalDevice, pMemoryProperties &C.VkPhysicalDeviceMemoryProperties) {
	C.vkGetPhysicalDeviceMemoryProperties(gpu, pMemoryProperties)
}

fn C.vkGetPhysicalDeviceQueueFamilyProperties(VkPhysicalDevice, &u32, &C.VkQueueFamilyProperties)

@[inline]
fn vk_get_physical_device_queue_family_properties(gpu VkPhysicalDevice, pCount &u32, pProperties &C.VkQueueFamilyProperties) {
	C.vkGetPhysicalDeviceQueueFamilyProperties(gpu, pCount, pProperties)
}

fn C.vkGetPhysicalDeviceFeatures(VkPhysicalDevice, &C.VkPhysicalDeviceFeatures)

@[inline]
fn vk_get_physical_device_features(gpu VkPhysicalDevice, pFeatures &C.VkPhysicalDeviceFeatures) {
	C.vkGetPhysicalDeviceFeatures(gpu, pFeatures)
}

// --------------------------------------------------------------------------
// Device creation
// --------------------------------------------------------------------------

fn C.vkCreateDevice(VkPhysicalDevice, &C.VkDeviceCreateInfo, &AllocationCallbacks, &VkDevice) Result

@[inline]
fn vk_create_device(gpu VkPhysicalDevice, pCreateInfo &C.VkDeviceCreateInfo, pAllocator &AllocationCallbacks, pDevice &VkDevice) Result {
	return C.vkCreateDevice(gpu, pCreateInfo, pAllocator, pDevice)
}

fn C.vkDestroyDevice(VkDevice, &AllocationCallbacks)

@[inline]
fn vk_destroy_device(device VkDevice, pAllocator &AllocationCallbacks) {
	C.vkDestroyDevice(device, pAllocator)
}

// --------------------------------------------------------------------------
// Queue
// --------------------------------------------------------------------------

fn C.vkGetDeviceQueue(VkDevice, u32, u32, &VkQueue)

@[inline]
fn vk_get_device_queue(device VkDevice, queueFamilyIndex u32, queueIndex u32, pQueue &VkQueue) {
	C.vkGetDeviceQueue(device, queueFamilyIndex, queueIndex, pQueue)
}

fn C.vkQueueSubmit(VkQueue, u32, &C.VkSubmitInfo, VkFence) Result

@[inline]
fn vk_queue_submit(queue VkQueue, submitCount u32, pSubmitInfos &C.VkSubmitInfo, fence VkFence) Result {
	return C.vkQueueSubmit(queue, submitCount, pSubmitInfos, fence)
}

fn C.vkQueueWaitIdle(VkQueue) Result

@[inline]
fn vk_queue_wait_idle(queue VkQueue) Result {
	return C.vkQueueWaitIdle(queue)
}

fn C.vkDeviceWaitIdle(VkDevice) Result

@[inline]
fn vk_device_wait_idle(device VkDevice) Result {
	return C.vkDeviceWaitIdle(device)
}

// --------------------------------------------------------------------------
// Memory
// --------------------------------------------------------------------------

fn C.vkAllocateMemory(VkDevice, &C.VkMemoryAllocateInfo, &AllocationCallbacks, &VkDeviceMemory) Result

@[inline]
fn vk_allocate_memory(device VkDevice, pAllocateInfo &C.VkMemoryAllocateInfo, pAllocator &AllocationCallbacks, pMemory &VkDeviceMemory) Result {
	return C.vkAllocateMemory(device, pAllocateInfo, pAllocator, pMemory)
}

fn C.vkFreeMemory(VkDevice, VkDeviceMemory, &AllocationCallbacks)

@[inline]
fn vk_free_memory(device VkDevice, memory VkDeviceMemory, pAllocator &AllocationCallbacks) {
	C.vkFreeMemory(device, memory, pAllocator)
}

fn C.vkMapMemory(VkDevice, VkDeviceMemory, DeviceSize, DeviceSize, u32, &voidptr) Result

@[inline]
fn vk_map_memory(device VkDevice, memory VkDeviceMemory, offset DeviceSize, size DeviceSize, flags u32, ppData &voidptr) Result {
	return C.vkMapMemory(device, memory, offset, size, flags, ppData)
}

fn C.vkUnmapMemory(VkDevice, VkDeviceMemory)

@[inline]
fn vk_unmap_memory(device VkDevice, memory VkDeviceMemory) {
	C.vkUnmapMemory(device, memory)
}

fn C.vkFlushMappedMemoryRanges(VkDevice, u32, &C.VkMappedMemoryRange) Result

@[inline]
fn vk_flush_mapped_memory_ranges(device VkDevice, memoryRangeCount u32, pMemoryRanges &C.VkMappedMemoryRange) Result {
	return C.vkFlushMappedMemoryRanges(device, memoryRangeCount, pMemoryRanges)
}

fn C.vkGetBufferMemoryRequirements(VkDevice, VkBuffer, &C.VkMemoryRequirements)

@[inline]
fn vk_get_memory_requirements(device VkDevice, buffer VkBuffer, pMemoryRequirements &C.VkMemoryRequirements) {
	C.vkGetBufferMemoryRequirements(device, buffer, pMemoryRequirements)
}

// --------------------------------------------------------------------------
// Buffer
// --------------------------------------------------------------------------

fn C.vkCreateBuffer(VkDevice, &C.VkBufferCreateInfo, &AllocationCallbacks, &VkBuffer) Result

@[inline]
fn vk_create_buffer(device VkDevice, pCreateInfo &C.VkBufferCreateInfo, pAllocator &AllocationCallbacks, pBuffer &VkBuffer) Result {
	return C.vkCreateBuffer(device, pCreateInfo, pAllocator, pBuffer)
}

fn C.vkDestroyBuffer(VkDevice, VkBuffer, &AllocationCallbacks)

@[inline]
fn vk_destroy_buffer(device VkDevice, buffer VkBuffer, pAllocator &AllocationCallbacks) {
	C.vkDestroyBuffer(device, buffer, pAllocator)
}

fn C.vkBindBufferMemory(VkDevice, VkBuffer, VkDeviceMemory, DeviceSize) Result

@[inline]
fn vk_bind_buffer_memory(device VkDevice, buffer VkBuffer, memory VkDeviceMemory, memOffset DeviceSize) Result {
	return C.vkBindBufferMemory(device, buffer, memory, memOffset)
}

// --------------------------------------------------------------------------
// Shader module
// --------------------------------------------------------------------------

fn C.vkCreateShaderModule(VkDevice, &C.VkShaderModuleCreateInfo, &AllocationCallbacks, &VkShaderModule) Result

@[inline]
fn vk_create_shader_module(device VkDevice, pCreateInfo &C.VkShaderModuleCreateInfo, pAllocator &AllocationCallbacks, pShaderModule &VkShaderModule) Result {
	return C.vkCreateShaderModule(device, pCreateInfo, pAllocator, pShaderModule)
}

fn C.vkDestroyShaderModule(VkDevice, VkShaderModule, &AllocationCallbacks)

@[inline]
fn vk_destroy_shader_module(device VkDevice, shaderModule VkShaderModule, pAllocator &AllocationCallbacks) {
	C.vkDestroyShaderModule(device, shaderModule, pAllocator)
}

// --------------------------------------------------------------------------
// Pipeline layout
// --------------------------------------------------------------------------

fn C.vkCreatePipelineLayout(VkDevice, &C.VkPipelineLayoutCreateInfo, &AllocationCallbacks, &VkPipelineLayout) Result

@[inline]
fn vk_create_pipeline_layout(device VkDevice, pCreateInfo &C.VkPipelineLayoutCreateInfo, pAllocator &AllocationCallbacks, pPipelineLayout &VkPipelineLayout) Result {
	return C.vkCreatePipelineLayout(device, pCreateInfo, pAllocator, pPipelineLayout)
}

fn C.vkDestroyPipelineLayout(VkDevice, VkPipelineLayout, &AllocationCallbacks)

@[inline]
fn vk_destroy_pipeline_layout(device VkDevice, pipelineLayout VkPipelineLayout, pAllocator &AllocationCallbacks) {
	C.vkDestroyPipelineLayout(device, pipelineLayout, pAllocator)
}

// --------------------------------------------------------------------------
// Compute pipeline
// --------------------------------------------------------------------------

fn C.vkCreateComputePipelines(VkDevice, VkPipelineCache, u32, &C.VkComputePipelineCreateInfo, &AllocationCallbacks, &VkPipeline) Result

@[inline]
fn vk_create_compute_pipelines(device VkDevice, pipelineCache VkPipelineCache, createInfoCount u32, pCreateInfos &C.VkComputePipelineCreateInfo, pAllocator &AllocationCallbacks, pPipelines &VkPipeline) Result {
	return C.vkCreateComputePipelines(device, pipelineCache, createInfoCount, pCreateInfos,
		pAllocator, pPipelines)
}

fn C.vkDestroyPipeline(VkDevice, VkPipeline, &AllocationCallbacks)

@[inline]
fn vk_destroy_pipeline(device VkDevice, pipeline VkPipeline, pAllocator &AllocationCallbacks) {
	C.vkDestroyPipeline(device, pipeline, pAllocator)
}

// --------------------------------------------------------------------------
// Descriptor set layout
// --------------------------------------------------------------------------

fn C.vkCreateDescriptorSetLayout(VkDevice, &C.VkDescriptorSetLayoutCreateInfo, &AllocationCallbacks, &VkDescriptorSetLayout) Result

@[inline]
fn vk_create_descriptor_set_layout(device VkDevice, pCreateInfo &C.VkDescriptorSetLayoutCreateInfo, pAllocator &AllocationCallbacks, pSetLayout &VkDescriptorSetLayout) Result {
	return C.vkCreateDescriptorSetLayout(device, pCreateInfo, pAllocator, pSetLayout)
}

fn C.vkDestroyDescriptorSetLayout(VkDevice, VkDescriptorSetLayout, &AllocationCallbacks)

@[inline]
fn vk_destroy_descriptor_set_layout(device VkDevice, descriptorSetLayout VkDescriptorSetLayout, pAllocator &AllocationCallbacks) {
	C.vkDestroyDescriptorSetLayout(device, descriptorSetLayout, pAllocator)
}

// --------------------------------------------------------------------------
// Descriptor pool / sets
// --------------------------------------------------------------------------

fn C.vkCreateDescriptorPool(VkDevice, &C.VkDescriptorPoolCreateInfo, &AllocationCallbacks, &VkDescriptorPool) Result

@[inline]
fn vk_create_descriptor_pool(device VkDevice, pCreateInfo &C.VkDescriptorPoolCreateInfo, pAllocator &AllocationCallbacks, pDescriptorPool &VkDescriptorPool) Result {
	return C.vkCreateDescriptorPool(device, pCreateInfo, pAllocator, pDescriptorPool)
}

fn C.vkDestroyDescriptorPool(VkDevice, VkDescriptorPool, &AllocationCallbacks)

@[inline]
fn vk_destroy_descriptor_pool(device VkDevice, descriptorPool VkDescriptorPool, pAllocator &AllocationCallbacks) {
	C.vkDestroyDescriptorPool(device, descriptorPool, pAllocator)
}

fn C.vkAllocateDescriptorSets(VkDevice, &C.VkDescriptorSetAllocateInfo, &VkDescriptorSet) Result

@[inline]
fn vk_allocate_descriptor_sets(device VkDevice, pAllocateInfo &C.VkDescriptorSetAllocateInfo, pDescriptorSets &VkDescriptorSet) Result {
	return C.vkAllocateDescriptorSets(device, pAllocateInfo, pDescriptorSets)
}

fn C.vkFreeDescriptorSets(VkDevice, VkDescriptorPool, u32, &VkDescriptorSet) Result

@[inline]
fn vk_free_descriptor_sets(device VkDevice, descriptorPool VkDescriptorPool, descriptorSetCount u32, pDescriptorSets &VkDescriptorSet) Result {
	return C.vkFreeDescriptorSets(device, descriptorPool, descriptorSetCount, pDescriptorSets)
}

// vkUpdateDescriptorSets returns void in the Vulkan C API.
// The wrapper must match _cfun_d_vsl_vulkan_dlopen.c.v (void return).
fn C.vkUpdateDescriptorSets(VkDevice, u32, &C.VkWriteDescriptorSet, u32, &C.VkCopyDescriptorSet)

@[inline]
fn vk_update_descriptor_sets(device VkDevice, writeCount u32, pWrites &C.VkWriteDescriptorSet, copyCount u32, pCopies &C.VkCopyDescriptorSet) {
	C.vkUpdateDescriptorSets(device, writeCount, pWrites, copyCount, pCopies)
}

// --------------------------------------------------------------------------
// Command pool / buffers
// --------------------------------------------------------------------------

fn C.vkCreateCommandPool(VkDevice, &C.VkCommandPoolCreateInfo, &AllocationCallbacks, &VkCommandPool) Result

@[inline]
fn vk_create_command_pool(device VkDevice, pCreateInfo &C.VkCommandPoolCreateInfo, pAllocator &AllocationCallbacks, pCommandPool &VkCommandPool) Result {
	return C.vkCreateCommandPool(device, pCreateInfo, pAllocator, pCommandPool)
}

fn C.vkDestroyCommandPool(VkDevice, VkCommandPool, &AllocationCallbacks)

@[inline]
fn vk_destroy_command_pool(device VkDevice, commandPool VkCommandPool, pAllocator &AllocationCallbacks) {
	C.vkDestroyCommandPool(device, commandPool, pAllocator)
}

fn C.vkAllocateCommandBuffers(VkDevice, &C.VkCommandBufferAllocateInfo, &VkCommandBuffer) Result

@[inline]
fn vk_allocate_command_buffers(device VkDevice, pAllocateInfo &C.VkCommandBufferAllocateInfo, pCommandBuffers &VkCommandBuffer) Result {
	return C.vkAllocateCommandBuffers(device, pAllocateInfo, pCommandBuffers)
}

fn C.vkFreeCommandBuffers(VkDevice, VkCommandPool, u32, &VkCommandBuffer)

@[inline]
fn vk_free_command_buffers(device VkDevice, commandPool VkCommandPool, commandBufferCount u32, pCommandBuffers &VkCommandBuffer) {
	C.vkFreeCommandBuffers(device, commandPool, commandBufferCount, pCommandBuffers)
}

fn C.vkBeginCommandBuffer(VkCommandBuffer, &C.VkCommandBufferBeginInfo) Result

@[inline]
fn vk_begin_command_buffer(commandBuffer VkCommandBuffer, pBeginInfo &C.VkCommandBufferBeginInfo) Result {
	return C.vkBeginCommandBuffer(commandBuffer, pBeginInfo)
}

fn C.vkEndCommandBuffer(VkCommandBuffer) Result

@[inline]
fn vk_end_command_buffer(commandBuffer VkCommandBuffer) Result {
	return C.vkEndCommandBuffer(commandBuffer)
}

// --------------------------------------------------------------------------
// Fence / sync
// --------------------------------------------------------------------------

fn C.vkCreateFence(VkDevice, &C.VkFenceCreateInfo, &AllocationCallbacks, &VkFence) Result

@[inline]
fn vk_create_fence(device VkDevice, pCreateInfo &C.VkFenceCreateInfo, pAllocator &AllocationCallbacks, pFence &VkFence) Result {
	return C.vkCreateFence(device, pCreateInfo, pAllocator, pFence)
}

fn C.vkDestroyFence(VkDevice, VkFence, &AllocationCallbacks)

@[inline]
fn vk_destroy_fence(device VkDevice, fence VkFence, pAllocator &AllocationCallbacks) {
	C.vkDestroyFence(device, fence, pAllocator)
}

fn C.vkWaitForFences(VkDevice, u32, &VkFence, bool, u64) Result

@[inline]
fn vk_wait_for_fences(device VkDevice, fenceCount u32, pFences &VkFence, waitAll bool, timeout u64) Result {
	return C.vkWaitForFences(device, fenceCount, pFences, waitAll, timeout)
}

// --------------------------------------------------------------------------
// Command functions (barriers, dispatch, bind)
// --------------------------------------------------------------------------

fn C.vkCmdPipelineBarrier(VkCommandBuffer, PipelineStageFlags, PipelineStageFlags, u32, u32, &C.VkMemoryBarrier, u32, &C.VkBufferMemoryBarrier, u32, &C.VkImageMemoryBarrier)

@[inline]
fn vk_cmd_pipeline_barrier(cmdbuf VkCommandBuffer, srcStageMask PipelineStageFlags, dstStageMask PipelineStageFlags, dependencyFlags u32, memoryBarrierCount u32, pMemoryBarriers &C.VkMemoryBarrier, bufferMemoryBarrierCount u32, pBufferMemoryBarriers &C.VkBufferMemoryBarrier, imageMemoryBarrierCount u32, pImageMemoryBarriers &C.VkImageMemoryBarrier) {
	C.vkCmdPipelineBarrier(cmdbuf, srcStageMask, dstStageMask, dependencyFlags, memoryBarrierCount,
		pMemoryBarriers, bufferMemoryBarrierCount, pBufferMemoryBarriers, imageMemoryBarrierCount,
		pImageMemoryBarriers)
}

fn C.vkCmdDispatch(VkCommandBuffer, u32, u32, u32)

@[inline]
fn vk_cmd_dispatch(cmdbuf VkCommandBuffer, groupCountX u32, groupCountY u32, groupCountZ u32) {
	C.vkCmdDispatch(cmdbuf, groupCountX, groupCountY, groupCountZ)
}

fn C.vkCmdBindPipeline(VkCommandBuffer, u32, VkPipeline)

@[inline]
fn vk_cmd_bind_pipeline(cmdbuf VkCommandBuffer, pipelineBindPoint u32, pipeline VkPipeline) {
	C.vkCmdBindPipeline(cmdbuf, pipelineBindPoint, pipeline)
}

fn C.vkCmdBindDescriptorSets(VkCommandBuffer, u32, VkPipelineLayout, u32, u32, &VkDescriptorSet, u32, &u32)

@[inline]
fn vk_cmd_bind_descriptor_sets(cmdbuf VkCommandBuffer, pipelineBindPoint u32, layout VkPipelineLayout, firstSet u32, descriptorSetCount u32, pDescriptorSets &VkDescriptorSet, dynamicOffsetCount u32, pDynamicOffsets &u32) {
	C.vkCmdBindDescriptorSets(cmdbuf, pipelineBindPoint, layout, firstSet, descriptorSetCount,
		pDescriptorSets, dynamicOffsetCount, pDynamicOffsets)
}

// --------------------------------------------------------------------------
// Semaphore
// --------------------------------------------------------------------------

fn C.vkCreateSemaphore(VkDevice, &C.VkSemaphoreCreateInfo, &AllocationCallbacks, &VkSemaphore) Result

@[inline]
fn vk_create_semaphore(device VkDevice, pCreateInfo &C.VkSemaphoreCreateInfo, pAllocator &AllocationCallbacks, pSemaphore &VkSemaphore) Result {
	return C.vkCreateSemaphore(device, pCreateInfo, pAllocator, pSemaphore)
}

fn C.vkDestroySemaphore(VkDevice, VkSemaphore, &AllocationCallbacks)

@[inline]
fn vk_destroy_semaphore(device VkDevice, semaphore VkSemaphore, pAllocator &AllocationCallbacks) {
	C.vkDestroySemaphore(device, semaphore, pAllocator)
}

fn C.vkEnumerateInstanceLayerProperties(&u32, &C.VkLayerProperties) Result

@[inline]
fn vk_enumerate_instance_layer_properties(pPropertyCount &u32, pProperties &C.VkLayerProperties) Result {
	return C.vkEnumerateInstanceLayerProperties(pPropertyCount, pProperties)
}
