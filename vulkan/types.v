module vulkan

// ============================================================================
// Vulkan result codes
// ============================================================================

// Result defines a public type used by this module.
pub type Result = i32

// result_success is a public constant used by this module.
pub const result_success = Result(0)
// result_not_ready is a public constant used by this module.
pub const result_not_ready = Result(1)
// result_timeout is a public constant used by this module.
pub const result_timeout = Result(2)
// result_event_set is a public constant used by this module.
pub const result_event_set = Result(3)
// result_event_reset is a public constant used by this module.
pub const result_event_reset = Result(4)
// result_incomplete is a public constant used by this module.
pub const result_incomplete = Result(5)
// result_error_out_of_host_memory is a public constant used by this module.
pub const result_error_out_of_host_memory = Result(-1)
// result_error_out_of_device_memory is a public constant used by this module.
pub const result_error_out_of_device_memory = Result(-2)
// result_error_initialization_failed is a public constant used by this module.
pub const result_error_initialization_failed = Result(-3)
// result_error_device_lost is a public constant used by this module.
pub const result_error_device_lost = Result(-4)
// result_error_extension_not_present is a public constant used by this module.
pub const result_error_extension_not_present = Result(-5)
// result_error_feature_not_present is a public constant used by this module.
pub const result_error_feature_not_present = Result(-6)
// result_error_incompatible_driver is a public constant used by this module.
pub const result_error_incompatible_driver = Result(-7)
// result_error_too_many_objects is a public constant used by this module.
pub const result_error_too_many_objects = Result(-8)
// result_error_format_not_supported is a public constant used by this module.
pub const result_error_format_not_supported = Result(-9)
// result_error_surface_lost_khronos is a public constant used by this module.
pub const result_error_surface_lost_khronos = Result(-1000000000)
// result_error_native_window_in_use_khronos is a public constant used by this module.
pub const result_error_native_window_in_use_khronos = Result(-1000000001)
// result_error_out_of_date_khronos is a public constant used by this module.
pub const result_error_out_of_date_khronos = Result(-1000001003)
// result_error_incompatible_display_khronos is a public constant used by this module.
pub const result_error_incompatible_display_khronos = Result(-1000003001)
// result_error_validation_failed_ext is a public constant used by this module.
pub const result_error_validation_failed_ext = Result(-1000011001)
// result_error_invalid_shader_nv is a public constant used by this module.
pub const result_error_invalid_shader_nv = Result(-1000012000)

// ============================================================================
// VkStructureType
// ============================================================================

// structure_type_application_info is a public constant used by this module.
pub const structure_type_application_info = u32(0)
// structure_type_instance_create_info is a public constant used by this module.
pub const structure_type_instance_create_info = u32(1)
// structure_type_device_queue_create_info is a public constant used by this module.
pub const structure_type_device_queue_create_info = u32(2)
// structure_type_device_create_info is a public constant used by this module.
pub const structure_type_device_create_info = u32(3)
// structure_type_submit_info is a public constant used by this module.
pub const structure_type_submit_info = u32(4)
// structure_type_memory_allocate_info is a public constant used by this module.
pub const structure_type_memory_allocate_info = u32(5)
// structure_type_mapped_memory_range is a public constant used by this module.
pub const structure_type_mapped_memory_range = u32(6)
// structure_type_bind_sparse_info is a public constant used by this module.
pub const structure_type_bind_sparse_info = u32(7)
// structure_type_fence_create_info is a public constant used by this module.
pub const structure_type_fence_create_info = u32(8)
// structure_type_semaphore_create_info is a public constant used by this module.
pub const structure_type_semaphore_create_info = u32(9)
// structure_type_event_create_info is a public constant used by this module.
pub const structure_type_event_create_info = u32(10)
// structure_type_query_pool_create_info is a public constant used by this module.
pub const structure_type_query_pool_create_info = u32(11)
// structure_type_buffer_create_info is a public constant used by this module.
pub const structure_type_buffer_create_info = u32(12)
// structure_type_buffer_view_create_info is a public constant used by this module.
pub const structure_type_buffer_view_create_info = u32(13)
// structure_type_image_create_info is a public constant used by this module.
pub const structure_type_image_create_info = u32(14)
// structure_type_image_view_create_info is a public constant used by this module.
pub const structure_type_image_view_create_info = u32(15)
// structure_type_shader_module_create_info is a public constant used by this module.
pub const structure_type_shader_module_create_info = u32(16)
// structure_type_pipeline_cache_create_info is a public constant used by this module.
pub const structure_type_pipeline_cache_create_info = u32(17)
// structure_type_pipeline_shader_stage_create_info is a public constant used by this module.
pub const structure_type_pipeline_shader_stage_create_info = u32(18)
// structure_type_pipeline_vertex_input_state_create_info is a public constant used by this module.
pub const structure_type_pipeline_vertex_input_state_create_info = u32(19)
// structure_type_pipeline_input_assembly_state_create_info is a public constant used by this module.
pub const structure_type_pipeline_input_assembly_state_create_info = u32(20)
// structure_type_pipeline_tessellation_state_create_info is a public constant used by this module.
pub const structure_type_pipeline_tessellation_state_create_info = u32(21)
// structure_type_pipeline_viewport_state_create_info is a public constant used by this module.
pub const structure_type_pipeline_viewport_state_create_info = u32(22)
// structure_type_pipeline_rasterization_state_create_info is a public constant used by this module.
pub const structure_type_pipeline_rasterization_state_create_info = u32(23)
// structure_type_pipeline_multisample_state_create_info is a public constant used by this module.
pub const structure_type_pipeline_multisample_state_create_info = u32(24)
// structure_type_pipeline_depth_stencil_state_create_info is a public constant used by this module.
pub const structure_type_pipeline_depth_stencil_state_create_info = u32(25)
// structure_type_pipeline_color_blend_state_create_info is a public constant used by this module.
pub const structure_type_pipeline_color_blend_state_create_info = u32(26)
// structure_type_pipeline_dynamic_state_create_info is a public constant used by this module.
pub const structure_type_pipeline_dynamic_state_create_info = u32(27)
// structure_type_graphics_pipeline_create_info is a public constant used by this module.
pub const structure_type_graphics_pipeline_create_info = u32(28)
// structure_type_compute_pipeline_create_info is a public constant used by this module.
pub const structure_type_compute_pipeline_create_info = u32(29)
// structure_type_pipeline_layout_create_info is a public constant used by this module.
pub const structure_type_pipeline_layout_create_info = u32(30)
// structure_type_sampler_create_info is a public constant used by this module.
pub const structure_type_sampler_create_info = u32(31)
// structure_type_descriptor_set_layout_create_info is a public constant used by this module.
pub const structure_type_descriptor_set_layout_create_info = u32(32)
// structure_type_descriptor_pool_create_info is a public constant used by this module.
pub const structure_type_descriptor_pool_create_info = u32(33)
// structure_type_descriptor_set_allocate_info is a public constant used by this module.
pub const structure_type_descriptor_set_allocate_info = u32(34)
// structure_type_write_descriptor_set is a public constant used by this module.
pub const structure_type_write_descriptor_set = u32(35)
// structure_type_copy_descriptor_set is a public constant used by this module.
pub const structure_type_copy_descriptor_set = u32(36)
// structure_type_framebuffer_create_info is a public constant used by this module.
pub const structure_type_framebuffer_create_info = u32(37)
// structure_type_render_pass_create_info is a public constant used by this module.
pub const structure_type_render_pass_create_info = u32(38)
// structure_type_command_pool_create_info is a public constant used by this module.
pub const structure_type_command_pool_create_info = u32(39)
// structure_type_command_buffer_allocate_info is a public constant used by this module.
pub const structure_type_command_buffer_allocate_info = u32(40)
// structure_type_command_buffer_inheritance_info is a public constant used by this module.
pub const structure_type_command_buffer_inheritance_info = u32(41)
// structure_type_command_buffer_begin_info is a public constant used by this module.
pub const structure_type_command_buffer_begin_info = u32(42)
// structure_type_render_pass_begin_info is a public constant used by this module.
pub const structure_type_render_pass_begin_info = u32(43)
// structure_type_buffer_memory_barrier is a public constant used by this module.
pub const structure_type_buffer_memory_barrier = u32(44)
// structure_type_image_memory_barrier is a public constant used by this module.
pub const structure_type_image_memory_barrier = u32(45)
// structure_type_memory_barrier is a public constant used by this module.
pub const structure_type_memory_barrier = u32(46)

// ============================================================================
// VkPipelineStageFlagBits
// ============================================================================

// PipelineStageFlags defines a public type used by this module.
pub type PipelineStageFlags = u32

// pipeline_stage_top_of_pipe_bit is a public constant used by this module.
pub const pipeline_stage_top_of_pipe_bit = PipelineStageFlags(1 << 0)
// pipeline_stage_draw_indirect_bit is a public constant used by this module.
pub const pipeline_stage_draw_indirect_bit = PipelineStageFlags(1 << 1)
// pipeline_stage_vertex_input_bit is a public constant used by this module.
pub const pipeline_stage_vertex_input_bit = PipelineStageFlags(1 << 2)
// pipeline_stage_vertex_shader_bit is a public constant used by this module.
pub const pipeline_stage_vertex_shader_bit = PipelineStageFlags(1 << 3)
// pipeline_stage_tess_control_shader_bit is a public constant used by this module.
pub const pipeline_stage_tess_control_shader_bit = PipelineStageFlags(1 << 4)
// pipeline_stage_tess_evaluation_shader_bit is a public constant used by this module.
pub const pipeline_stage_tess_evaluation_shader_bit = PipelineStageFlags(1 << 5)
// pipeline_stage_geometry_shader_bit is a public constant used by this module.
pub const pipeline_stage_geometry_shader_bit = PipelineStageFlags(1 << 6)
// pipeline_stage_fragment_shader_bit is a public constant used by this module.
pub const pipeline_stage_fragment_shader_bit = PipelineStageFlags(1 << 7)
// pipeline_stage_early_fragment_tests_bit is a public constant used by this module.
pub const pipeline_stage_early_fragment_tests_bit = PipelineStageFlags(1 << 8)
// pipeline_stage_late_fragment_tests_bit is a public constant used by this module.
pub const pipeline_stage_late_fragment_tests_bit = PipelineStageFlags(1 << 9)
// pipeline_stage_color_attachment_output_bit is a public constant used by this module.
pub const pipeline_stage_color_attachment_output_bit = PipelineStageFlags(1 << 10)
// pipeline_stage_compute_shader_bit is a public constant used by this module.
pub const pipeline_stage_compute_shader_bit = PipelineStageFlags(1 << 11)
// pipeline_stage_transfer_bit is a public constant used by this module.
pub const pipeline_stage_transfer_bit = PipelineStageFlags(1 << 12)
// pipeline_stage_host_bit is a public constant used by this module.
pub const pipeline_stage_host_bit = PipelineStageFlags(1 << 14)
// pipeline_stage_all_graphics_bit is a public constant used by this module.
pub const pipeline_stage_all_graphics_bit = PipelineStageFlags(1 << 15)
// pipeline_stage_all_commands_bit is a public constant used by this module.
pub const pipeline_stage_all_commands_bit = PipelineStageFlags(1 << 16)

// ============================================================================
// VkAccessFlagBits
// ============================================================================

// access_indirect_command_read_bit is a public constant used by this module.
pub const access_indirect_command_read_bit = u32(1 << 0)
// access_index_read_bit is a public constant used by this module.
pub const access_index_read_bit = u32(1 << 1)
// access_vertex_attribute_read_bit is a public constant used by this module.
pub const access_vertex_attribute_read_bit = u32(1 << 2)
// access_uniform_read_bit is a public constant used by this module.
pub const access_uniform_read_bit = u32(1 << 3)
// access_input_attachment_read_bit is a public constant used by this module.
pub const access_input_attachment_read_bit = u32(1 << 4)
// access_shader_read_bit is a public constant used by this module.
pub const access_shader_read_bit = u32(1 << 5)
// access_shader_write_bit is a public constant used by this module.
pub const access_shader_write_bit = u32(1 << 6)
// access_color_attachment_read_bit is a public constant used by this module.
pub const access_color_attachment_read_bit = u32(1 << 7)
// access_color_attachment_write_bit is a public constant used by this module.
pub const access_color_attachment_write_bit = u32(1 << 8)
// access_depth_stencil_attachment_read_bit is a public constant used by this module.
pub const access_depth_stencil_attachment_read_bit = u32(1 << 9)
// access_depth_stencil_attachment_write_bit is a public constant used by this module.
pub const access_depth_stencil_attachment_write_bit = u32(1 << 10)
// access_transfer_read_bit is a public constant used by this module.
pub const access_transfer_read_bit = u32(1 << 11)
// access_transfer_write_bit is a public constant used by this module.
pub const access_transfer_write_bit = u32(1 << 12)
// access_host_read_bit is a public constant used by this module.
pub const access_host_read_bit = u32(1 << 13)
// access_host_write_bit is a public constant used by this module.
pub const access_host_write_bit = u32(1 << 14)
// access_memory_read_bit is a public constant used by this module.
pub const access_memory_read_bit = u32(1 << 15)
// access_memory_write_bit is a public constant used by this module.
pub const access_memory_write_bit = u32(1 << 16)

// ============================================================================
// Queue flags
// ============================================================================

// QueueFlags defines a public type used by this module.
pub type QueueFlags = u32

// queue_graphics_bit is a public constant used by this module.
pub const queue_graphics_bit = QueueFlags(1 << 0)
// queue_compute_bit is a public constant used by this module.
pub const queue_compute_bit = QueueFlags(1 << 1)
// queue_transfer_bit is a public constant used by this module.
pub const queue_transfer_bit = QueueFlags(1 << 2)
// queue_sparse_binding_bit is a public constant used by this module.
pub const queue_sparse_binding_bit = QueueFlags(1 << 3)

// ============================================================================
// Memory property flags
// ============================================================================

// MemoryPropertyFlags defines a public type used by this module.
pub type MemoryPropertyFlags = u32

// memory_property_host_visible_bit is a public constant used by this module.
pub const memory_property_host_visible_bit = MemoryPropertyFlags(2)
// memory_property_device_local_bit is a public constant used by this module.
pub const memory_property_device_local_bit = MemoryPropertyFlags(1)
// memory_property_host_coherent_bit is a public constant used by this module.
pub const memory_property_host_coherent_bit = MemoryPropertyFlags(1 << 2)
// memory_property_host_cached_bit is a public constant used by this module.
pub const memory_property_host_cached_bit = MemoryPropertyFlags(1 << 3)
// memory_property_lazily_allocated_bit is a public constant used by this module.
pub const memory_property_lazily_allocated_bit = MemoryPropertyFlags(1 << 4)

// ============================================================================
// Descriptor types
// ============================================================================

// descriptor_type_sampler is a public constant used by this module.
pub const descriptor_type_sampler = u32(0)
// descriptor_type_combined_image_sampler is a public constant used by this module.
pub const descriptor_type_combined_image_sampler = u32(1)
// descriptor_type_sampled_image is a public constant used by this module.
pub const descriptor_type_sampled_image = u32(2)
// descriptor_type_storage_image is a public constant used by this module.
pub const descriptor_type_storage_image = u32(3)
// descriptor_type_uniform_texel_buffer is a public constant used by this module.
pub const descriptor_type_uniform_texel_buffer = u32(4)
// descriptor_type_storage_texel_buffer is a public constant used by this module.
pub const descriptor_type_storage_texel_buffer = u32(5)
// descriptor_type_uniform_buffer is a public constant used by this module.
pub const descriptor_type_uniform_buffer = u32(6)
// descriptor_type_storage_buffer is a public constant used by this module.
pub const descriptor_type_storage_buffer = u32(7)
// descriptor_type_uniform_buffer_dynamic is a public constant used by this module.
pub const descriptor_type_uniform_buffer_dynamic = u32(8)
// descriptor_type_storage_buffer_dynamic is a public constant used by this module.
pub const descriptor_type_storage_buffer_dynamic = u32(9)
// descriptor_type_input_attachment is a public constant used by this module.
pub const descriptor_type_input_attachment = u32(10)

// ============================================================================
// Shader stage flags
// ============================================================================

// shader_stage_vertex_bit is a public constant used by this module.
pub const shader_stage_vertex_bit = u32(1 << 0)
// shader_stage_tess_control_bit is a public constant used by this module.
pub const shader_stage_tess_control_bit = u32(1 << 1)
// shader_stage_tess_evaluation_bit is a public constant used by this module.
pub const shader_stage_tess_evaluation_bit = u32(1 << 2)
// shader_stage_geometry_bit is a public constant used by this module.
pub const shader_stage_geometry_bit = u32(1 << 3)
// shader_stage_fragment_bit is a public constant used by this module.
pub const shader_stage_fragment_bit = u32(1 << 4)
// shader_stage_compute_bit is a public constant used by this module.
pub const shader_stage_compute_bit = u32(1 << 5)
// shader_stage_all_graphics is a public constant used by this module.
pub const shader_stage_all_graphics = u32(0x1f)
// shader_stage_all is a public constant used by this module.
pub const shader_stage_all = u32(0x7fffffff)

// ============================================================================
// Buffer usage flags
// ============================================================================

// buffer_usage_transfer_src_bit is a public constant used by this module.
pub const buffer_usage_transfer_src_bit = u32(1 << 0)
// buffer_usage_transfer_dst_bit is a public constant used by this module.
pub const buffer_usage_transfer_dst_bit = u32(1 << 1)
// buffer_usage_uniform_texel_buffer_bit is a public constant used by this module.
pub const buffer_usage_uniform_texel_buffer_bit = u32(1 << 2)
// buffer_usage_storage_texel_buffer_bit is a public constant used by this module.
pub const buffer_usage_storage_texel_buffer_bit = u32(1 << 3)
// buffer_usage_uniform_buffer_bit is a public constant used by this module.
pub const buffer_usage_uniform_buffer_bit = u32(1 << 4)
// buffer_usage_storage_buffer_bit is a public constant used by this module.
pub const buffer_usage_storage_buffer_bit = u32(1 << 5)
// buffer_usage_index_buffer_bit is a public constant used by this module.
pub const buffer_usage_index_buffer_bit = u32(1 << 6)
// buffer_usage_vertex_buffer_bit is a public constant used by this module.
pub const buffer_usage_vertex_buffer_bit = u32(1 << 7)
// buffer_usage_indirect_buffer_bit is a public constant used by this module.
pub const buffer_usage_indirect_buffer_bit = u32(1 << 8)

// ============================================================================
// Pipeline bind points
// ============================================================================

// pipeline_bind_point_compute is a public constant used by this module.
pub const pipeline_bind_point_compute = u32(1)
// pipeline_bind_point_graphics is a public constant used by this module.
pub const pipeline_bind_point_graphics = u32(0)

// ============================================================================
// Command buffer level
// ============================================================================

// command_buffer_level_primary is a public constant used by this module.
pub const command_buffer_level_primary = u32(0)
// command_buffer_level_secondary is a public constant used by this module.
pub const command_buffer_level_secondary = u32(1)

// ============================================================================
// Memory heaps
// ============================================================================

// MemoryHeapFlags defines a public type used by this module.
pub type MemoryHeapFlags = u32

// memory_heap_device_local_bit is a public constant used by this module.
pub const memory_heap_device_local_bit = MemoryHeapFlags(1 << 0)

// ============================================================================
// Misc
// ============================================================================

// DeviceSize defines a public type used by this module.
pub type DeviceSize = u64

// All GLSL compute shaders use local_size_x = 256.
pub const workgroup_size_x = u32(256)

// Validation layer and debug extension names (used with VK_LAYER_KHRONOS_validation)
pub const khronos_validation_layer_name = 'VK_LAYER_KHRONOS_validation'
// ext_debug_utils_extension_name is a public constant used by this module.
pub const ext_debug_utils_extension_name = 'VK_EXT_debug_utils'

// VkDebugUtilsMessageSeverityFlagBitsEXT
pub type DebugUtilsMessageSeverityFlagsEXT = u32

// debug_utils_message_severity_verbose_bit_ext is a public constant used by this module.
pub const debug_utils_message_severity_verbose_bit_ext = DebugUtilsMessageSeverityFlagsEXT(0x0001)
// debug_utils_message_severity_info_bit_ext is a public constant used by this module.
pub const debug_utils_message_severity_info_bit_ext = DebugUtilsMessageSeverityFlagsEXT(0x0010)
// debug_utils_message_severity_warning_bit_ext is a public constant used by this module.
pub const debug_utils_message_severity_warning_bit_ext = DebugUtilsMessageSeverityFlagsEXT(0x0100)
// debug_utils_message_severity_error_bit_ext is a public constant used by this module.
pub const debug_utils_message_severity_error_bit_ext = DebugUtilsMessageSeverityFlagsEXT(0x1000)

// VkDebugUtilsMessageTypeFlagBitsEXT
pub type DebugUtilsMessageTypeFlagsEXT = u32

// debug_utils_message_type_general_bit_ext is a public constant used by this module.
pub const debug_utils_message_type_general_bit_ext = DebugUtilsMessageTypeFlagsEXT(0x0001)
// debug_utils_message_type_validation_bit_ext is a public constant used by this module.
pub const debug_utils_message_type_validation_bit_ext = DebugUtilsMessageTypeFlagsEXT(0x0002)
// debug_utils_message_type_performance_bit_ext is a public constant used by this module.
pub const debug_utils_message_type_performance_bit_ext = DebugUtilsMessageTypeFlagsEXT(0x0004)

// VkStructureType extensions (debug utils)
pub const structure_type_debug_utils_messenger_create_info_ext = u32(1000128004)
