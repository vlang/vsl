module vulkan

// ============================================================================
// Vulkan result codes
// ============================================================================

pub type Result = i32

pub const result_success = Result(0)
pub const result_not_ready = Result(1)
pub const result_timeout = Result(2)
pub const result_event_set = Result(3)
pub const result_event_reset = Result(4)
pub const result_incomplete = Result(5)
pub const result_error_out_of_host_memory = Result(-1)
pub const result_error_out_of_device_memory = Result(-2)
pub const result_error_initialization_failed = Result(-3)
pub const result_error_device_lost = Result(-4)
pub const result_error_extension_not_present = Result(-5)
pub const result_error_feature_not_present = Result(-6)
pub const result_error_incompatible_driver = Result(-7)
pub const result_error_too_many_objects = Result(-8)
pub const result_error_format_not_supported = Result(-9)
pub const result_error_surface_lost_khronos = Result(-1000000000)
pub const result_error_native_window_in_use_khronos = Result(-1000000001)
pub const result_error_out_of_date_khronos = Result(-1000001003)
pub const result_error_incompatible_display_khronos = Result(-1000003001)
pub const result_error_validation_failed_ext = Result(-1000011001)
pub const result_error_invalid_shader_nv = Result(-1000012000)

// ============================================================================
// VkStructureType
// ============================================================================

pub const structure_type_application_info = u32(0)
pub const structure_type_instance_create_info = u32(1)
pub const structure_type_device_queue_create_info = u32(2)
pub const structure_type_device_create_info = u32(3)
pub const structure_type_submit_info = u32(4)
pub const structure_type_memory_allocate_info = u32(5)
pub const structure_type_mapped_memory_range = u32(6)
pub const structure_type_bind_sparse_info = u32(7)
pub const structure_type_fence_create_info = u32(8)
pub const structure_type_semaphore_create_info = u32(9)
pub const structure_type_event_create_info = u32(10)
pub const structure_type_query_pool_create_info = u32(11)
pub const structure_type_buffer_create_info = u32(12)
pub const structure_type_buffer_view_create_info = u32(13)
pub const structure_type_image_create_info = u32(14)
pub const structure_type_image_view_create_info = u32(15)
pub const structure_type_shader_module_create_info = u32(16)
pub const structure_type_pipeline_cache_create_info = u32(17)
pub const structure_type_pipeline_shader_stage_create_info = u32(18)
pub const structure_type_pipeline_vertex_input_state_create_info = u32(19)
pub const structure_type_pipeline_input_assembly_state_create_info = u32(20)
pub const structure_type_pipeline_tessellation_state_create_info = u32(21)
pub const structure_type_pipeline_viewport_state_create_info = u32(22)
pub const structure_type_pipeline_rasterization_state_create_info = u32(23)
pub const structure_type_pipeline_multisample_state_create_info = u32(24)
pub const structure_type_pipeline_depth_stencil_state_create_info = u32(25)
pub const structure_type_pipeline_color_blend_state_create_info = u32(26)
pub const structure_type_pipeline_dynamic_state_create_info = u32(27)
pub const structure_type_graphics_pipeline_create_info = u32(28)
pub const structure_type_compute_pipeline_create_info = u32(29)
pub const structure_type_pipeline_layout_create_info = u32(30)
pub const structure_type_sampler_create_info = u32(31)
pub const structure_type_descriptor_set_layout_create_info = u32(32)
pub const structure_type_descriptor_pool_create_info = u32(33)
pub const structure_type_descriptor_set_allocate_info = u32(34)
pub const structure_type_write_descriptor_set = u32(35)
pub const structure_type_copy_descriptor_set = u32(36)
pub const structure_type_framebuffer_create_info = u32(37)
pub const structure_type_render_pass_create_info = u32(38)
pub const structure_type_command_pool_create_info = u32(39)
pub const structure_type_command_buffer_allocate_info = u32(40)
pub const structure_type_command_buffer_inheritance_info = u32(41)
pub const structure_type_command_buffer_begin_info = u32(42)
pub const structure_type_render_pass_begin_info = u32(43)
pub const structure_type_buffer_memory_barrier = u32(44)
pub const structure_type_image_memory_barrier = u32(45)
pub const structure_type_memory_barrier = u32(46)

// ============================================================================
// VkPipelineStageFlagBits
// ============================================================================

pub type PipelineStageFlags = u32

pub const pipeline_stage_top_of_pipe_bit = PipelineStageFlags(1 << 0)
pub const pipeline_stage_draw_indirect_bit = PipelineStageFlags(1 << 1)
pub const pipeline_stage_vertex_input_bit = PipelineStageFlags(1 << 2)
pub const pipeline_stage_vertex_shader_bit = PipelineStageFlags(1 << 3)
pub const pipeline_stage_tess_control_shader_bit = PipelineStageFlags(1 << 4)
pub const pipeline_stage_tess_evaluation_shader_bit = PipelineStageFlags(1 << 5)
pub const pipeline_stage_geometry_shader_bit = PipelineStageFlags(1 << 6)
pub const pipeline_stage_fragment_shader_bit = PipelineStageFlags(1 << 7)
pub const pipeline_stage_early_fragment_tests_bit = PipelineStageFlags(1 << 8)
pub const pipeline_stage_late_fragment_tests_bit = PipelineStageFlags(1 << 9)
pub const pipeline_stage_color_attachment_output_bit = PipelineStageFlags(1 << 10)
pub const pipeline_stage_compute_shader_bit = PipelineStageFlags(1 << 11)
pub const pipeline_stage_transfer_bit = PipelineStageFlags(1 << 12)
pub const pipeline_stage_host_bit = PipelineStageFlags(1 << 14)
pub const pipeline_stage_all_graphics_bit = PipelineStageFlags(1 << 14)
pub const pipeline_stage_all_commands_bit = PipelineStageFlags(1 << 15)

// ============================================================================
// VkAccessFlagBits
// ============================================================================

pub const access_indirect_command_read_bit = u32(1 << 0)
pub const access_index_read_bit = u32(1 << 1)
pub const access_vertex_attribute_read_bit = u32(1 << 2)
pub const access_uniform_read_bit = u32(1 << 3)
pub const access_input_attachment_read_bit = u32(1 << 4)
pub const access_shader_read_bit = u32(1 << 5)
pub const access_shader_write_bit = u32(1 << 6)
pub const access_color_attachment_read_bit = u32(1 << 7)
pub const access_color_attachment_write_bit = u32(1 << 8)
pub const access_depth_stencil_attachment_read_bit = u32(1 << 9)
pub const access_depth_stencil_attachment_write_bit = u32(1 << 10)
pub const access_transfer_read_bit = u32(1 << 11)
pub const access_transfer_write_bit = u32(1 << 12)
pub const access_host_read_bit = u32(1 << 13)
pub const access_host_write_bit = u32(1 << 14)
pub const access_memory_read_bit = u32(1 << 15)
pub const access_memory_write_bit = u32(1 << 16)

// ============================================================================
// Queue flags
// ============================================================================

pub type QueueFlags = u32

pub const queue_graphics_bit = QueueFlags(1 << 0)
pub const queue_compute_bit = QueueFlags(1 << 1)
pub const queue_transfer_bit = QueueFlags(1 << 2)
pub const queue_sparse_binding_bit = QueueFlags(1 << 3)

// ============================================================================
// Memory property flags
// ============================================================================

pub type MemoryPropertyFlags = u32

pub const memory_property_host_visible_bit = MemoryPropertyFlags(2)
pub const memory_property_device_local_bit = MemoryPropertyFlags(1)
pub const memory_property_host_coherent_bit = MemoryPropertyFlags(1 << 2)
pub const memory_property_host_cached_bit = MemoryPropertyFlags(1 << 3)
pub const memory_property_lazily_allocated_bit = MemoryPropertyFlags(1 << 4)

// ============================================================================
// Descriptor types
// ============================================================================

pub const descriptor_type_sampler = u32(0)
pub const descriptor_type_combined_image_sampler = u32(1)
pub const descriptor_type_sampled_image = u32(2)
pub const descriptor_type_storage_image = u32(3)
pub const descriptor_type_uniform_texel_buffer = u32(4)
pub const descriptor_type_storage_texel_buffer = u32(5)
pub const descriptor_type_uniform_buffer = u32(6)
pub const descriptor_type_storage_buffer = u32(7)
pub const descriptor_type_uniform_buffer_dynamic = u32(8)
pub const descriptor_type_storage_buffer_dynamic = u32(9)
pub const descriptor_type_input_attachment = u32(10)

// ============================================================================
// Shader stage flags
// ============================================================================

pub const shader_stage_vertex_bit = u32(1 << 0)
pub const shader_stage_tess_control_bit = u32(1 << 1)
pub const shader_stage_tess_evaluation_bit = u32(1 << 2)
pub const shader_stage_geometry_bit = u32(1 << 3)
pub const shader_stage_fragment_bit = u32(1 << 4)
pub const shader_stage_compute_bit = u32(1 << 5)
pub const shader_stage_all_graphics = u32(0x1f)
pub const shader_stage_all = u32(0x7fffffff)

// ============================================================================
// Buffer usage flags
// ============================================================================

pub const buffer_usage_transfer_src_bit = u32(1 << 0)
pub const buffer_usage_transfer_dst_bit = u32(1 << 1)
pub const buffer_usage_uniform_texel_buffer_bit = u32(1 << 2)
pub const buffer_usage_storage_texel_buffer_bit = u32(1 << 3)
pub const buffer_usage_uniform_buffer_bit = u32(1 << 4)
pub const buffer_usage_storage_buffer_bit = u32(1 << 5)
pub const buffer_usage_index_buffer_bit = u32(1 << 6)
pub const buffer_usage_vertex_buffer_bit = u32(1 << 7)
pub const buffer_usage_indirect_buffer_bit = u32(1 << 8)

// ============================================================================
// Pipeline bind points
// ============================================================================

pub const pipeline_bind_point_compute = u32(1)
pub const pipeline_bind_point_graphics = u32(0)

// ============================================================================
// Command buffer level
// ============================================================================

pub const command_buffer_level_primary = u32(0)
pub const command_buffer_level_secondary = u32(1)

// ============================================================================
// Memory heaps
// ============================================================================

pub type MemoryHeapFlags = u32

pub const memory_heap_device_local_bit = MemoryHeapFlags(1 << 0)

// ============================================================================
// Misc
// ============================================================================

pub type DeviceSize = u64

// All GLSL compute shaders use local_size_x = 256.
pub const workgroup_size_x = u32(256)
