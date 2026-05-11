module vulkan

// ============================================================================
// Vulkan C struct definitions (mapped via @[typedef])
//
// These mirror the C Vulkan structs from <vulkan/vulkan.h> and are used by
// both the dlopen and direct-linking compilation paths.
//
// All structs use @[typedef] to ensure correct C ABI compatibility.
// ============================================================================

@[typedef]
pub struct C.VkInstanceCreateInfo {
pub mut:
	sType                   u32
	pNext                   voidptr
	flags                   u32
	pApplicationInfo        &C.VkApplicationInfo
	enabledLayerCount       u32
	ppEnabledLayerNames     &char
	enabledExtensionCount   u32
	ppEnabledExtensionNames &char
}

@[typedef]
pub struct C.VkApplicationInfo {
pub mut:
	sType              u32
	pNext              voidptr
	pApplicationName   &char
	applicationVersion u32
	pEngineName        &char
	engineVersion      u32
	apiVersion         u32
}

@[typedef]
pub struct C.VkDeviceCreateInfo {
pub mut:
	sType                   u32
	pNext                   voidptr
	flags                   u32
	queueCreateInfoCount    u32
	pQueueCreateInfos       &C.VkDeviceQueueCreateInfo
	enabledLayerCount       u32
	ppEnabledLayerNames     &char
	enabledExtensionCount   u32
	ppEnabledExtensionNames &char
	pEnabledFeatures        &C.VkPhysicalDeviceFeatures
}

@[typedef]
pub struct C.VkDeviceQueueCreateInfo {
pub mut:
	sType            u32
	pNext            voidptr
	flags            u32
	queueFamilyIndex u32
	queueCount       u32
	pQueuePriorities &f32
}

@[typedef]
pub struct C.VkPhysicalDeviceProperties {
pub mut:
	apiVersion    u32
	driverVersion u32
	vendorID      u32
	deviceID      u32
	deviceType    u32
	deviceName    [256]u8
}

@[typedef]
pub struct C.VkPhysicalDeviceFeatures {
pub mut:
	robustBufferAccess                      u32
	fullDrawIndexUint32                     u32
	imageCubeArray                          u32
	independentBlend                        u32
	geometryShader                          u32
	tessellationShader                      u32
	sampleRateShading                       u32
	dualSrcBlend                            u32
	logicOp                                 u32
	multiDrawIndirect                       u32
	drawIndirectFirstInstance               u32
	depthClamp                              u32
	depthBiasClamp                          u32
	fillModeNonSolid                        u32
	depthBounds                             u32
	wideLines                               u32
	largePoints                             u32
	alphaToOne                              u32
	multiViewport                           u32
	samplerAnisotropy                       u32
	textureCompressionETC2                  u32
	textureCompressionASTC_LDR              u32
	textureCompressionBC                    u32
	occlusionQueryPrecise                   u32
	pipelineStatisticsQuery                 u32
	vertexPipelineStoresAndAtomics          u32
	fragmentStoresAndAtomics                u32
	shaderTessellationAndGeometryPointSize  u32
	shaderImageGatherExtended               u32
	shaderStorageImageExtendedFormats       u32
	shaderStorageImageMultisample           u32
	shaderStorageImageReadWithoutFormat     u32
	shaderStorageImageWriteWithoutFormat    u32
	shaderUniformBufferArrayDynamicIndexing u32
	shaderSampledImageArrayDynamicIndexing  u32
	shaderStorageBufferArrayDynamicIndexing u32
	shaderStorageImageArrayDynamicIndexing  u32
	shaderClipDistance                      u32
	shaderCullDistance                      u32
	shaderFloat64                           u32
	shaderInt64                             u32
	shaderInt16                             u32
	shaderResourceResidency                 u32
	shaderResourceMinLod                    u32
	sparseBinding                           u32
	sparseResidencyBuffer                   u32
	sparseResidencyImage2D                  u32
	sparseResidencyImage3D                  u32
	sparseResidency2Samples                 u32
	sparseResidency4Samples                 u32
	sparseResidency8Samples                 u32
	sparseResidency16Samples                u32
	sparseResidencyAliased                  u32
	variableMultisampleRate                 u32
	inheritedQueries                        u32
}

@[typedef]
pub struct C.VkPhysicalDeviceMemoryProperties {
pub mut:
	memoryTypeCount u32
	memoryTypes     [32]C.VkMemoryType
	memoryHeapCount u32
	memoryHeaps     [16]C.VkMemoryHeap
}

@[typedef]
pub struct C.VkMemoryType {
pub mut:
	propertyFlags MemoryPropertyFlags
	heapIndex     u32
}

@[typedef]
pub struct C.VkMemoryHeap {
pub mut:
	size  DeviceSize
	flags u32
}

@[typedef]
pub struct C.VkQueueFamilyProperties {
pub mut:
	queueFlags                  u32
	queueCount                  u32
	timestampValidBits          u32
	minImageTransferGranularity [3]u32
}

@[typedef]
pub struct C.VkMemoryAllocateInfo {
pub mut:
	sType           u32
	pNext           voidptr
	allocationSize  DeviceSize
	memoryTypeIndex u32
}

@[typedef]
pub struct C.VkMemoryRequirements {
pub mut:
	size           DeviceSize
	alignment      DeviceSize
	memoryTypeBits u32
}

@[typedef]
pub struct C.VkBufferCreateInfo {
pub mut:
	sType       u32
	pNext       voidptr
	flags       u32
	size        DeviceSize
	usage       u32
	sharingMode u32
}

@[typedef]
pub struct C.VkShaderModuleCreateInfo {
pub mut:
	sType    u32
	pNext    voidptr
	flags    u32
	codeSize usize
	pCode    &u32
}

@[typedef]
pub struct C.VkPipelineShaderStageCreateInfo {
pub mut:
	sType               u32
	pNext               voidptr
	flags               u32
	stage               u32
	module              VkShaderModule
	pName               &char
	pSpecializationInfo voidptr
}

@[typedef]
pub struct C.VkComputePipelineCreateInfo {
pub mut:
	sType              u32
	pNext              voidptr
	flags              u32
	stage              C.VkPipelineShaderStageCreateInfo
	layout             VkPipelineLayout
	basePipelineHandle VkPipeline
	basePipelineIndex  i32
}

@[typedef]
pub struct C.VkPipelineLayoutCreateInfo {
pub mut:
	sType                  u32
	pNext                  voidptr
	flags                  u32
	setLayoutCount         u32
	pSetLayouts            &VkDescriptorSetLayout
	pushConstantRangeCount u32
	pPushConstantRanges    voidptr
}

@[typedef]
pub struct C.VkDescriptorSetLayoutCreateInfo {
pub mut:
	sType        u32
	pNext        voidptr
	flags        u32
	bindingCount u32
	pBindings    &C.VkDescriptorSetLayoutBinding
}

@[typedef]
pub struct C.VkDescriptorSetLayoutBinding {
pub mut:
	binding            u32
	descriptorType     u32
	descriptorCount    u32
	stageFlags         u32
	pImmutableSamplers voidptr
}

@[typedef]
pub struct C.VkDescriptorPoolCreateInfo {
pub mut:
	sType         u32
	pNext         voidptr
	flags         u32
	maxSets       u32
	poolSizeCount u32
	pPoolSizes    &C.VkDescriptorPoolSize
}

@[typedef]
pub struct C.VkDescriptorPoolSize {
pub mut:
	type            u32
	descriptorCount u32
}

@[typedef]
pub struct C.VkDescriptorSetAllocateInfo {
pub mut:
	sType              u32
	pNext              voidptr
	descriptorPool     VkDescriptorPool
	descriptorSetCount u32
	pSetLayouts        &VkDescriptorSetLayout
}

@[typedef]
pub struct C.VkWriteDescriptorSet {
pub mut:
	sType            u32
	pNext            voidptr
	dstSet           VkDescriptorSet
	dstBinding       u32
	dstArrayElement  u32
	descriptorCount  u32
	descriptorType   u32
	pImageInfo       voidptr
	pBufferInfo      &C.VkDescriptorBufferInfo
	pTexelBufferView voidptr
}

@[typedef]
pub struct C.VkCopyDescriptorSet {
pub mut:
	sType           u32
	pNext           voidptr
	srcSet          VkDescriptorSet
	srcBinding      u32
	srcArrayElement u32
	dstSet          VkDescriptorSet
	dstBinding      u32
	dstArrayElement u32
	descriptorCount u32
}

@[typedef]
pub struct C.VkDescriptorBufferInfo {
pub mut:
	buffer VkBuffer
	offset DeviceSize
	range  DeviceSize
}

@[typedef]
pub struct C.VkCommandPoolCreateInfo {
pub mut:
	sType            u32
	pNext            voidptr
	flags            u32
	queueFamilyIndex u32
}

@[typedef]
pub struct C.VkCommandBufferAllocateInfo {
pub mut:
	sType              u32
	pNext              voidptr
	commandPool        VkCommandPool
	level              u32
	commandBufferCount u32
}

@[typedef]
pub struct C.VkCommandBufferBeginInfo {
pub mut:
	sType            u32
	pNext            voidptr
	flags            u32
	pInheritanceInfo voidptr
}

@[typedef]
pub struct C.VkSubmitInfo {
pub mut:
	sType                u32
	pNext                voidptr
	waitSemaphoreCount   u32
	pWaitSemaphores      &VkSemaphore
	pWaitDstStageMask    &u32
	commandBufferCount   u32
	pCommandBuffers      &VkCommandBuffer
	signalSemaphoreCount u32
	pSignalSemaphores    &VkSemaphore
}

@[typedef]
pub struct C.VkFenceCreateInfo {
pub mut:
	sType u32
	pNext voidptr
	flags u32
}

@[typedef]
pub struct C.VkSemaphoreCreateInfo {
pub mut:
	sType u32
	pNext voidptr
	flags u32
}

@[typedef]
pub struct C.VkMappedMemoryRange {
pub mut:
	sType  u32
	pNext  voidptr
	memory VkDeviceMemory
	offset DeviceSize
	size   DeviceSize
}

@[typedef]
pub struct C.VkMemoryBarrier {
pub mut:
	sType         u32
	pNext         voidptr
	srcAccessMask u32
	dstAccessMask u32
}

@[typedef]
pub struct C.VkBufferMemoryBarrier {
pub mut:
	sType               u32
	pNext               voidptr
	srcAccessMask       u32
	dstAccessMask       u32
	srcQueueFamilyIndex u32
	dstQueueFamilyIndex u32
	buffer              VkBuffer
	offset              DeviceSize
	size                DeviceSize
}

@[typedef]
pub struct C.VkImageMemoryBarrier {
pub mut:
	sType               u32
	pNext               voidptr
	srcAccessMask       u32
	dstAccessMask       u32
	oldLayout           u32
	newLayout           u32
	srcQueueFamilyIndex u32
	dstQueueFamilyIndex u32
	image               voidptr
	subresourceRange    voidptr
}

// ============================================================================
// Result formatting (moved from loader.c.v)
// ============================================================================

pub fn (r Result) str() string {
	return match r {
		result_success { 'VK_SUCCESS' }
		result_not_ready { 'VK_NOT_READY' }
		result_timeout { 'VK_TIMEOUT' }
		result_error_out_of_host_memory { 'VK_ERROR_OUT_OF_HOST_MEMORY' }
		result_error_out_of_device_memory { 'VK_ERROR_OUT_OF_DEVICE_MEMORY' }
		result_error_initialization_failed { 'VK_ERROR_INITIALIZATION_FAILED' }
		result_error_device_lost { 'VK_ERROR_DEVICE_LOST' }
		result_error_extension_not_present { 'VK_ERROR_EXTENSION_NOT_PRESENT' }
		result_error_feature_not_present { 'VK_ERROR_FEATURE_NOT_PRESENT' }
		result_error_incompatible_driver { 'VK_ERROR_INCOMPATIBLE_DRIVER' }
		result_error_too_many_objects { 'VK_ERROR_TOO_MANY_OBJECTS' }
		result_error_format_not_supported { 'VK_ERROR_FORMAT_NOT_SUPPORTED' }
		else { 'VK_ERROR_UNKNOWN(${int(r)})' }
	}
}

pub fn (r Result) error() ! {
	if r == result_success {
		return
	}
	return error('vulkan: ${r.str()}')
}

@[typedef]
pub struct C.VkLayerProperties {
pub:
	layerName             [256]char
	specVersion           u32
	implementationVersion u32
	description           [256]char
}
