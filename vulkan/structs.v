module vulkan

// ============================================================================
// Struct re-exports
//
// All Vulkan struct types are defined in internal/loader.c.v
// as @[typedef] C.VkXxx structs. Use them directly in all public code.
//
// Example:
//   info := C.VkBufferCreateInfo{
//       sType: structure_type_buffer_create_info
//       size:  1024
//       usage: buffer_usage_storage_buffer_bit
//       sharingMode: u32(0)  // VK_SHARING_MODE_EXCLUSIVE
//   }
//
// This file is intentionally empty — all structs come from loader.c.v.
