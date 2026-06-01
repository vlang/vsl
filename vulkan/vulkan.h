#ifndef VSL_VULKAN_H
#define VSL_VULKAN_H

// Vulkan C header — provides VkInstanceCreateInfo, VkDeviceCreateInfo, etc.
// Required for C compilation: @[typedef] structs reference C Vulkan types.
//
// On Linux: install vulkan-loader-devel or mesa-vulkan-drivers.
// On macOS: install LunarG Vulkan SDK from https://vulkan.lunang.com
#include <vulkan/vulkan.h>

// --------------------------------------------------------------------------
// C helper functions
//
// V 0.5.1 has struct layout issues with @[typedef] structs containing pointer
// fields. These C helpers ensure correct ABI-compliant struct construction.
// Pattern matches vsl/vcl/vcl.h which provides create_image_desc and friends.
// --------------------------------------------------------------------------

// vk_create_instance_simple creates a VkInstance with minimal configuration.
// Equivalent to vulkan new_device()'s instance creation but done in C.
static inline int vk_create_instance_simple(
    const char *app_name,
    uint32_t app_version,
    const char *engine_name,
    uint32_t engine_version,
    VkInstance *out)
{
    VkApplicationInfo app = {
        .sType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = app_name,
        .applicationVersion = app_version,
        .pEngineName = engine_name,
        .engineVersion = engine_version,
        .apiVersion = VK_API_VERSION_1_0,
    };
    VkInstanceCreateInfo info = {
        .sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pApplicationInfo = &app,
    };
    return (int)vkCreateInstance(&info, NULL, out);
}

// vk_compute_pipeline_binding_count returns the number of storage buffer
// bindings used by our compute pipelines. Useful for descriptor pool sizing.
static inline uint32_t vk_compute_pipeline_binding_count(void) {
    return 4;
}

// vk_create_sampler creates a simple nearest-neighbor sampler.
static inline int vk_create_sampler_simple(
    VkDevice device,
    VkSampler *out)
{
    VkSamplerCreateInfo info = {
        .sType = VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
        .magFilter = VK_FILTER_NEAREST,
        .minFilter = VK_FILTER_NEAREST,
        .mipmapMode = VK_SAMPLER_MIPMAP_MODE_NEAREST,
        .addressModeU = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
        .addressModeV = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
        .addressModeW = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
    };
    return (int)vkCreateSampler(device, &info, NULL, out);
}

// vk_create_device_simple creates a logical device with a single compute queue.
// Returns VK_SUCCESS on success, with out_device and out_queue populated.
// Works around V 0.5.1 @[typedef] struct layout bug for VkDeviceCreateInfo.
static inline int vk_create_device_simple(
    VkPhysicalDevice gpu,
    uint32_t queueFamilyIndex,
    VkDevice *out_device,
    VkQueue *out_queue)
{
    float priority = 1.0f;
    VkDeviceQueueCreateInfo queue_info = {
        .sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex = queueFamilyIndex,
        .queueCount = 1,
        .pQueuePriorities = &priority,
    };
    VkPhysicalDeviceFeatures features = {};
    vkGetPhysicalDeviceFeatures(gpu, &features);
    VkDeviceCreateInfo info = {
        .sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .queueCreateInfoCount = 1,
        .pQueueCreateInfos = &queue_info,
        .pEnabledFeatures = &features,
    };
    VkResult res = vkCreateDevice(gpu, &info, NULL, out_device);
    if (res != VK_SUCCESS) return (int)res;
    vkGetDeviceQueue(*out_device, queueFamilyIndex, 0, out_queue);
    return VK_SUCCESS;
}

// vk_create_compute_pipeline_simple creates a complete compute pipeline from SPIR-V.
// Returns all handles needed by the V wrapper. Works around V 0.5.1 struct layout
// bugs in VkComputePipelineCreateInfo and nested structs with pointer fields.
static inline int vk_create_compute_pipeline_simple(
    VkDevice device,
    const char *entry_name,
    const uint32_t *spv_code,
    size_t spv_size,
    VkShaderModule *out_shader_mod,
    VkPipelineLayout *out_layout,
    VkPipeline *out_pipeline,
    VkDescriptorSetLayout *out_dsl,
    VkDescriptorPool *out_dp,
    VkDescriptorSet *out_ds)
{
    // 1. Shader module
    VkShaderModuleCreateInfo sm = {
        .sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .codeSize = spv_size,
        .pCode = spv_code,
    };
    VkResult res = vkCreateShaderModule(device, &sm, NULL, out_shader_mod);
    if (res != VK_SUCCESS) return (int)res;

    // 2. Descriptor set layout (up to 8 storage buffer bindings; unused slots are ignored)
    enum { vsl_vk_max_storage_bindings = 8 };
    VkDescriptorSetLayoutBinding bindings[vsl_vk_max_storage_bindings];
    for (uint32_t i = 0; i < vsl_vk_max_storage_bindings; i++) {
        bindings[i] = (VkDescriptorSetLayoutBinding){
            i, VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, 1, VK_SHADER_STAGE_COMPUTE_BIT, NULL};
    }
    VkDescriptorSetLayoutCreateInfo dsl = {
        .sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        .bindingCount = vsl_vk_max_storage_bindings,
        .pBindings = bindings,
    };
    res = vkCreateDescriptorSetLayout(device, &dsl, NULL, out_dsl);
    if (res != VK_SUCCESS) {
        vkDestroyShaderModule(device, *out_shader_mod, NULL);
        return (int)res;
    }

    // 3. Pipeline layout
    VkPipelineLayoutCreateInfo pl = {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
        .setLayoutCount = 1,
        .pSetLayouts = out_dsl,
    };
    res = vkCreatePipelineLayout(device, &pl, NULL, out_layout);
    if (res != VK_SUCCESS) {
        vkDestroyDescriptorSetLayout(device, *out_dsl, NULL);
        vkDestroyShaderModule(device, *out_shader_mod, NULL);
        return (int)res;
    }

    // 4. Compute pipeline
    VkPipelineShaderStageCreateInfo stage = {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
        .stage = VK_SHADER_STAGE_COMPUTE_BIT,
        .module = *out_shader_mod,
        .pName = entry_name,
    };
    VkComputePipelineCreateInfo cpi = {
        .sType = VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO,
        .stage = stage,
        .layout = *out_layout,
    };
    res = vkCreateComputePipelines(device, VK_NULL_HANDLE, 1, &cpi, NULL, out_pipeline);
    if (res != VK_SUCCESS) {
        vkDestroyPipelineLayout(device, *out_layout, NULL);
        vkDestroyDescriptorSetLayout(device, *out_dsl, NULL);
        vkDestroyShaderModule(device, *out_shader_mod, NULL);
        return (int)res;
    }

    // 5. Descriptor pool
    VkDescriptorPoolSize pool_size = {VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, vsl_vk_max_storage_bindings};
    VkDescriptorPoolCreateInfo dp = {
        .sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO,
        .flags = VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT,
        .maxSets = 1,
        .poolSizeCount = 1,
        .pPoolSizes = &pool_size,
    };
    res = vkCreateDescriptorPool(device, &dp, NULL, out_dp);
    if (res != VK_SUCCESS) {
        vkDestroyPipeline(device, *out_pipeline, NULL);
        vkDestroyPipelineLayout(device, *out_layout, NULL);
        vkDestroyDescriptorSetLayout(device, *out_dsl, NULL);
        vkDestroyShaderModule(device, *out_shader_mod, NULL);
        return (int)res;
    }

    // 6. Allocate descriptor set
    VkDescriptorSetAllocateInfo ds = {
        .sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
        .descriptorPool = *out_dp,
        .descriptorSetCount = 1,
        .pSetLayouts = out_dsl,
    };
    res = vkAllocateDescriptorSets(device, &ds, out_ds);
    if (res != VK_SUCCESS) {
        vkDestroyDescriptorPool(device, *out_dp, NULL);
        vkDestroyPipeline(device, *out_pipeline, NULL);
        vkDestroyPipelineLayout(device, *out_layout, NULL);
        vkDestroyDescriptorSetLayout(device, *out_dsl, NULL);
        vkDestroyShaderModule(device, *out_shader_mod, NULL);
        return (int)res;
    }

    return VK_SUCCESS;
}

#endif // VSL_VULKAN_H
