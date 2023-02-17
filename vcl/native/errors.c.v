module native

pub const (
	// Generally an unexpected result from an OpenCL function (e.g. success but null pointer)
	err_unknown = error('vcl_cl: unknown error')
)

// ErrVCL converts that OpenCL error code to an V error
pub type ErrVCL = int

pub fn (e ErrVCL) err() IError {
	err := match e {
		native.success { '' }
		native.device_not_found { native.err_device_not_found }
		native.device_not_available { native.err_device_not_available }
		native.compiler_not_available { native.err_compiler_not_available }
		native.mem_object_allocation_failure { native.err_mem_object_allocation_failure }
		native.out_of_resources { native.err_out_of_resources }
		native.out_of_host_memory { native.err_out_of_host_memory }
		native.profiling_info_not_available { native.err_profiling_info_not_available }
		native.mem_copy_overlap { native.err_mem_copy_overlap }
		native.image_format_mismatch { native.err_image_format_mismatch }
		native.image_format_not_supported { native.err_image_format_not_supported }
		native.build_program_failure { native.err_build_program_failure }
		native.map_failure { native.err_map_failure }
		native.misaligned_sub_buffer_offset { native.err_misaligned_sub_buffer_offset }
		native.exec_status_error_for_events_in_wait_list { native.err_exec_status_error_for_events_in_wait_list }
		native.invalid_value { native.err_invalid_value }
		native.invalid_device_type { native.err_invalid_device_type }
		native.invalid_platform { native.err_invalid_platform }
		native.invalid_device { native.err_invalid_device }
		native.invalid_context { native.err_invalid_context }
		native.invalid_queue_properties { native.err_invalid_queue_properties }
		native.invalid_command_queue { native.err_invalid_command_queue }
		native.invalid_host_ptr { native.err_invalid_host_ptr }
		native.invalid_mem_object { native.err_invalid_mem_object }
		native.invalid_image_format_descriptor { native.err_invalid_image_format_descriptor }
		native.invalid_image_size { native.err_invalid_image_size }
		native.invalid_sampler { native.err_invalid_sampler }
		native.invalid_binary { native.err_invalid_binary }
		native.invalid_build_options { native.err_invalid_build_options }
		native.invalid_program { native.err_invalid_program }
		native.invalid_program_executable { native.err_invalid_program_executable }
		native.invalid_kernel_name { native.err_invalid_kernel_name }
		native.invalid_kernel_definition { native.err_invalid_kernel_definition }
		native.invalid_kernel { native.err_invalid_kernel }
		native.invalid_arg_index { native.err_invalid_arg_index }
		native.invalid_arg_value { native.err_invalid_arg_value }
		native.invalid_arg_size { native.err_invalid_arg_size }
		native.invalid_kernel_args { native.err_invalid_kernel_args }
		native.invalid_work_dimension { native.err_invalid_work_dimension }
		native.invalid_work_group_size { native.err_invalid_work_group_size }
		native.invalid_work_item_size { native.err_invalid_work_item_size }
		native.invalid_global_offset { native.err_invalid_global_offset }
		native.invalid_event_wait_list { native.err_invalid_event_wait_list }
		native.invalid_event { native.err_invalid_event }
		native.invalid_operation { native.err_invalid_operation }
		native.invalid_gl_object { native.err_invalid_gl_object }
		native.invalid_buffer_size { native.err_invalid_buffer_size }
		native.invalid_mip_level { native.err_invalid_mip_level }
		native.invalid_global_work_size { native.err_invalid_global_work_size }
		native.invalid_property { native.err_invalid_property }
		native.dl_sym_issue { native.err_dl_sym_issue }
		native.dl_open_issue { native.err_dl_open_issue }
		else { 'vcl_cl: error ${e}' }
	}
	return error_with_code(err, int(e))
}

pub fn vcl_error(code int) IError {
	if code == native.success {
		return none
	}
	return ErrVCL(code).err()
}

pub fn vcl_panic(code int) {
	if code != native.success {
		panic(ErrVCL(code).err())
	}
}

pub const (
	// Common OpenCl errors
	err_device_not_found                          = 'vcl_cl: Device Not Found'
	err_device_not_available                      = 'vcl_cl: Device Not Available'
	err_compiler_not_available                    = 'vcl_cl: Compiler Not Available'
	err_mem_object_allocation_failure             = 'vcl_cl: Mem Object Allocation Failure'
	err_out_of_resources                          = 'vcl_cl: Out Of Resources'
	err_out_of_host_memory                        = 'vcl_cl: Out Of Host Memory'
	err_profiling_info_not_available              = 'vcl_cl: Profiling Info Not Available'
	err_mem_copy_overlap                          = 'vcl_cl: Mem Copy Overlap'
	err_image_format_mismatch                     = 'vcl_cl: Image Format Mismatch'
	err_image_format_not_supported                = 'vcl_cl: Image Format Not Supported'
	err_build_program_failure                     = 'vcl_cl: Build Program Failure'
	err_map_failure                               = 'vcl_cl: Map Failure'
	err_misaligned_sub_buffer_offset              = 'vcl_cl: Misaligned Sub Buffer Offset'
	err_exec_status_error_for_events_in_wait_list = 'vcl_cl: Exec Status Error For Events In Wait List'
	err_compile_program_failure                   = 'vcl_cl: Compile Program Failure'
	err_linker_not_available                      = 'vcl_cl: Linker Not Available'
	err_link_program_failure                      = 'vcl_cl: Link Program Failure'
	err_device_partition_failed                   = 'vcl_cl: Device Partition Failed'
	err_kernel_arg_info_not_available             = 'vcl_cl: Kernel Arg Info Not Available'
	err_invalid_value                             = 'vcl_cl: Invalid Value'
	err_invalid_device_type                       = 'vcl_cl: Invalid Device Type'
	err_invalid_platform                          = 'vcl_cl: Invalid Platform'
	err_invalid_device                            = 'vcl_cl: Invalid Device'
	err_invalid_context                           = 'vcl_cl: Invalid Context'
	err_invalid_queue_properties                  = 'vcl_cl: Invalid Queue Properties'
	err_invalid_command_queue                     = 'vcl_cl: Invalid Command Queue'
	err_invalid_host_ptr                          = 'vcl_cl: Invalid Host Ptr'
	err_invalid_mem_object                        = 'vcl_cl: Invalid Mem Object'
	err_invalid_image_format_descriptor           = 'vcl_cl: Invalid Image Format Descriptor'
	err_invalid_image_size                        = 'vcl_cl: Invalid Image Size'
	err_invalid_sampler                           = 'vcl_cl: Invalid Sampler'
	err_invalid_binary                            = 'vcl_cl: Invalid Binary'
	err_invalid_build_options                     = 'vcl_cl: Invalid Build Options'
	err_invalid_program                           = 'vcl_cl: Invalid Program'
	err_invalid_program_executable                = 'vcl_cl: Invalid Program Executable'
	err_invalid_kernel_name                       = 'vcl_cl: Invalid Kernel Name'
	err_invalid_kernel_definition                 = 'vcl_cl: Invalid Kernel Definition'
	err_invalid_kernel                            = 'vcl_cl: Invalid Kernel'
	err_invalid_arg_index                         = 'vcl_cl: Invalid Arg Index'
	err_invalid_arg_value                         = 'vcl_cl: Invalid Arg Value'
	err_invalid_arg_size                          = 'vcl_cl: Invalid Arg Size'
	err_invalid_kernel_args                       = 'vcl_cl: Invalid Kernel Args'
	err_invalid_work_dimension                    = 'vcl_cl: Invalid Work Dimension'
	err_invalid_work_group_size                   = 'vcl_cl: Invalid Work Group Size'
	err_invalid_work_item_size                    = 'vcl_cl: Invalid Work Item Size'
	err_invalid_global_offset                     = 'vcl_cl: Invalid Global Offset'
	err_invalid_event_wait_list                   = 'vcl_cl: Invalid Event Wait List'
	err_invalid_event                             = 'vcl_cl: Invalid Event'
	err_invalid_operation                         = 'vcl_cl: Invalid Operation'
	err_invalid_gl_object                         = 'vcl_cl: Invalid Gl Object'
	err_invalid_buffer_size                       = 'vcl_cl: Invalid Buffer Size'
	err_invalid_mip_level                         = 'vcl_cl: Invalid Mip Level'
	err_invalid_global_work_size                  = 'vcl_cl: Invalid Global Work Size'
	err_invalid_property                          = 'vcl_cl: Invalid Property'
	err_invalid_image_descriptor                  = 'vcl_cl: Invalid Image Descriptor'
	err_invalid_compiler_options                  = 'vcl_cl: Invalid Compiler Options'
	err_invalid_linker_options                    = 'vcl_cl: Invalid Linker Options'
	err_invalid_device_partition_count            = 'vcl_cl: Invalid Device Partition Count'

	// Dl errors
	err_dl_sym_issue                              = 'vcl_cl_dl: Not Found Dl Library'
	err_dl_open_issue                             = 'vcl_cl_dl: Not Found Dl Symbol'

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
	dl_sym_issue                                  = -73
	dl_open_issue                                 = -74
)
