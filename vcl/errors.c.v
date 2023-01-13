module vcl

const (
	// Generally an unexpected result from an OpenCL function (e.g. success but null pointer)
	err_unknown = error('cl: unknown error')
)

// ErrVCL converts that OpenCL error code to an V error
pub type ErrVCL = int

pub fn (e ErrVCL) err() IError {
	err := match e {
		vcl.success { '' }
		vcl.device_not_found { vcl.err_device_not_found }
		vcl.device_not_available { vcl.err_device_not_available }
		vcl.compiler_not_available { vcl.err_compiler_not_available }
		vcl.mem_object_allocation_failure { vcl.err_mem_object_allocation_failure }
		vcl.out_of_resources { vcl.err_out_of_resources }
		vcl.out_of_host_memory { vcl.err_out_of_host_memory }
		vcl.profiling_info_not_available { vcl.err_profiling_info_not_available }
		vcl.mem_copy_overlap { vcl.err_mem_copy_overlap }
		vcl.image_format_mismatch { vcl.err_image_format_mismatch }
		vcl.image_format_not_supported { vcl.err_image_format_not_supported }
		vcl.build_program_failure { vcl.err_build_program_failure }
		vcl.map_failure { vcl.err_map_failure }
		vcl.misaligned_sub_buffer_offset { vcl.err_misaligned_sub_buffer_offset }
		vcl.exec_status_error_for_events_in_wait_list { vcl.err_exec_status_error_for_events_in_wait_list }
		vcl.invalid_value { vcl.err_invalid_value }
		vcl.invalid_device_type { vcl.err_invalid_device_type }
		vcl.invalid_platform { vcl.err_invalid_platform }
		vcl.invalid_device { vcl.err_invalid_device }
		vcl.invalid_context { vcl.err_invalid_context }
		vcl.invalid_queue_properties { vcl.err_invalid_queue_properties }
		vcl.invalid_command_queue { vcl.err_invalid_command_queue }
		vcl.invalid_host_ptr { vcl.err_invalid_host_ptr }
		vcl.invalid_mem_object { vcl.err_invalid_mem_object }
		vcl.invalid_image_format_descriptor { vcl.err_invalid_image_format_descriptor }
		vcl.invalid_image_size { vcl.err_invalid_image_size }
		vcl.invalid_sampler { vcl.err_invalid_sampler }
		vcl.invalid_binary { vcl.err_invalid_binary }
		vcl.invalid_build_options { vcl.err_invalid_build_options }
		vcl.invalid_program { vcl.err_invalid_program }
		vcl.invalid_program_executable { vcl.err_invalid_program_executable }
		vcl.invalid_kernel_name { vcl.err_invalid_kernel_name }
		vcl.invalid_kernel_definition { vcl.err_invalid_kernel_definition }
		vcl.invalid_kernel { vcl.err_invalid_kernel }
		vcl.invalid_arg_index { vcl.err_invalid_arg_index }
		vcl.invalid_arg_value { vcl.err_invalid_arg_value }
		vcl.invalid_arg_size { vcl.err_invalid_arg_size }
		vcl.invalid_kernel_args { vcl.err_invalid_kernel_args }
		vcl.invalid_work_dimension { vcl.err_invalid_work_dimension }
		vcl.invalid_work_group_size { vcl.err_invalid_work_group_size }
		vcl.invalid_work_item_size { vcl.err_invalid_work_item_size }
		vcl.invalid_global_offset { vcl.err_invalid_global_offset }
		vcl.invalid_event_wait_list { vcl.err_invalid_event_wait_list }
		vcl.invalid_event { vcl.err_invalid_event }
		vcl.invalid_operation { vcl.err_invalid_operation }
		vcl.invalid_gl_object { vcl.err_invalid_gl_object }
		vcl.invalid_buffer_size { vcl.err_invalid_buffer_size }
		vcl.invalid_mip_level { vcl.err_invalid_mip_level }
		vcl.invalid_global_work_size { vcl.err_invalid_global_work_size }
		vcl.invalid_property { vcl.err_invalid_property }
		else { 'cl: error ${e}' }
	}
	return error_with_code(err, int(e))
}

pub fn vcl_error(code int) IError {
	if code == vcl.success {
		return none
	}
	return ErrVCL(code).err()
}

pub fn vcl_panic(code int) {
	if code != vcl.success {
		panic(ErrVCL(code).err())
	}
}

const (
	// Common OpenCl errors
	err_device_not_found                          = 'cl: Device Not Found'
	err_device_not_available                      = 'cl: Device Not Available'
	err_compiler_not_available                    = 'cl: Compiler Not Available'
	err_mem_object_allocation_failure             = 'cl: Mem Object Allocation Failure'
	err_out_of_resources                          = 'cl: Out Of Resources'
	err_out_of_host_memory                        = 'cl: Out Of Host Memory'
	err_profiling_info_not_available              = 'cl: Profiling Info Not Available'
	err_mem_copy_overlap                          = 'cl: Mem Copy Overlap'
	err_image_format_mismatch                     = 'cl: Image Format Mismatch'
	err_image_format_not_supported                = 'cl: Image Format Not Supported'
	err_build_program_failure                     = 'cl: Build Program Failure'
	err_map_failure                               = 'cl: Map Failure'
	err_misaligned_sub_buffer_offset              = 'cl: Misaligned Sub Buffer Offset'
	err_exec_status_error_for_events_in_wait_list = 'cl: Exec Status Error For Events In Wait List'
	err_compile_program_failure                   = 'cl: Compile Program Failure'
	err_linker_not_available                      = 'cl: Linker Not Available'
	err_link_program_failure                      = 'cl: Link Program Failure'
	err_device_partition_failed                   = 'cl: Device Partition Failed'
	err_kernel_arg_info_not_available             = 'cl: Kernel Arg Info Not Available'
	err_invalid_value                             = 'cl: Invalid Value'
	err_invalid_device_type                       = 'cl: Invalid Device Type'
	err_invalid_platform                          = 'cl: Invalid Platform'
	err_invalid_device                            = 'cl: Invalid Device'
	err_invalid_context                           = 'cl: Invalid Context'
	err_invalid_queue_properties                  = 'cl: Invalid Queue Properties'
	err_invalid_command_queue                     = 'cl: Invalid Command Queue'
	err_invalid_host_ptr                          = 'cl: Invalid Host Ptr'
	err_invalid_mem_object                        = 'cl: Invalid Mem Object'
	err_invalid_image_format_descriptor           = 'cl: Invalid Image Format Descriptor'
	err_invalid_image_size                        = 'cl: Invalid Image Size'
	err_invalid_sampler                           = 'cl: Invalid Sampler'
	err_invalid_binary                            = 'cl: Invalid Binary'
	err_invalid_build_options                     = 'cl: Invalid Build Options'
	err_invalid_program                           = 'cl: Invalid Program'
	err_invalid_program_executable                = 'cl: Invalid Program Executable'
	err_invalid_kernel_name                       = 'cl: Invalid Kernel Name'
	err_invalid_kernel_definition                 = 'cl: Invalid Kernel Definition'
	err_invalid_kernel                            = 'cl: Invalid Kernel'
	err_invalid_arg_index                         = 'cl: Invalid Arg Index'
	err_invalid_arg_value                         = 'cl: Invalid Arg Value'
	err_invalid_arg_size                          = 'cl: Invalid Arg Size'
	err_invalid_kernel_args                       = 'cl: Invalid Kernel Args'
	err_invalid_work_dimension                    = 'cl: Invalid Work Dimension'
	err_invalid_work_group_size                   = 'cl: Invalid Work Group Size'
	err_invalid_work_item_size                    = 'cl: Invalid Work Item Size'
	err_invalid_global_offset                     = 'cl: Invalid Global Offset'
	err_invalid_event_wait_list                   = 'cl: Invalid Event Wait List'
	err_invalid_event                             = 'cl: Invalid Event'
	err_invalid_operation                         = 'cl: Invalid Operation'
	err_invalid_gl_object                         = 'cl: Invalid Gl Object'
	err_invalid_buffer_size                       = 'cl: Invalid Buffer Size'
	err_invalid_mip_level                         = 'cl: Invalid Mip Level'
	err_invalid_global_work_size                  = 'cl: Invalid Global Work Size'
	err_invalid_property                          = 'cl: Invalid Property'
	err_invalid_image_descriptor                  = 'cl: Invalid Image Descriptor'
	err_invalid_compiler_options                  = 'cl: Invalid Compiler Options'
	err_invalid_linker_options                    = 'cl: Invalid Linker Options'
	err_invalid_device_partition_count            = 'cl: Invalid Device Partition Count'

	// err codes
	success                                       = 0
	device_not_found                              = -1
	device_not_available                          = -2
	compiler_not_available                        = -3
	mem_object_allocation_failure                 = -4
	out_of_resources                              = -5
	out_of_host_memory                            = -6
	profiling_info_not_available                  = -7
	mem_copy_overlap                              = -8
	image_format_mismatch                         = -9
	image_format_not_supported                    = -10
	build_program_failure                         = -11
	map_failure                                   = -12
	misaligned_sub_buffer_offset                  = -13
	exec_status_error_for_events_in_wait_list     = -14
	compile_program_failure                       = -15
	linker_not_available                          = -16
	link_program_failure                          = -17
	device_partition_failed                       = -18
	kernel_arg_info_not_available                 = -19
	invalid_value                                 = -30
	invalid_device_type                           = -31
	invalid_platform                              = -32
	invalid_device                                = -33
	invalid_context                               = -34
	invalid_queue_properties                      = -35
	invalid_command_queue                         = -36
	invalid_host_ptr                              = -37
	invalid_mem_object                            = -38
	invalid_image_format_descriptor               = -39
	invalid_image_size                            = -40
	invalid_sampler                               = -41
	invalid_binary                                = -42
	invalid_build_options                         = -43
	invalid_program                               = -44
	invalid_program_executable                    = -45
	invalid_kernel_name                           = -46
	invalid_kernel_definition                     = -47
	invalid_kernel                                = -48
	invalid_arg_index                             = -49
	invalid_arg_value                             = -50
	invalid_arg_size                              = -51
	invalid_kernel_args                           = -52
	invalid_work_dimension                        = -53
	invalid_work_group_size                       = -54
	invalid_work_item_size                        = -55
	invalid_global_offset                         = -56
	invalid_event_wait_list                       = -57
	invalid_event                                 = -58
	invalid_operation                             = -59
	invalid_gl_object                             = -60
	invalid_buffer_size                           = -61
	invalid_mip_level                             = -62
	invalid_global_work_size                      = -63
	invalid_property                              = -64
	invalid_image_descriptor                      = -65
	invalid_compiler_options                      = -66
	invalid_linker_options                        = -67
	invalid_device_partition_count                = -68
	invalid_pipe_size                             = -69
	invalid_device_queue                          = -70
	invalid_spec_id                               = -71
	max_size_restriction_exceeded                 = -72
)

