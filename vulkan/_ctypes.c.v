module vulkan

// ============================================================================
// Vulkan Compute handle type aliases
//
// All Vulkan handles are opaque C pointers wrapped via V type aliases.
// Reference: VK_MAKE_HANDLE macro from vulkan_core.h
// ============================================================================

pub type VkInstance = voidptr
pub type VkPhysicalDevice = voidptr
pub type VkDevice = voidptr
pub type VkQueue = voidptr
pub type VkCommandBuffer = voidptr
pub type VkCommandPool = voidptr

pub type VkBuffer = voidptr
pub type VkDeviceMemory = voidptr
pub type VkShaderModule = voidptr

pub type VkPipeline = voidptr
pub type VkPipelineLayout = voidptr
pub type VkPipelineCache = voidptr
pub type VkDescriptorSetLayout = voidptr
pub type VkDescriptorPool = voidptr
pub type VkDescriptorSet = voidptr

pub type VkFence = voidptr
pub type VkSemaphore = voidptr

// AllocationCallbacks is always NULL/voidptr in our usage.
pub type AllocationCallbacks = voidptr
