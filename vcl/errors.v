module vcl

const (
	// Generally an unexpected result from an OpenCL function (e.g. CL_SUCCESS but null pointer)
	err_unknown = error('cl: unknown error')
)

// ErrVCL converts that OpenCL error code to an V error
pub type ErrVCL = int

pub fn (e ErrVCL) err() IError {
	err := match e {
		C.CL_SUCCESS { '' }
		C.CL_DEVICE_NOT_FOUND { vcl.err_device_not_found }
		C.CL_DEVICE_NOT_AVAILABLE { vcl.err_device_not_available }
		C.CL_COMPILER_NOT_AVAILABLE { vcl.err_compiler_not_available }
		C.CL_MEM_OBJECT_ALLOCATION_FAILURE { vcl.err_mem_object_allocation_failure }
		C.CL_OUT_OF_RESOURCES { vcl.err_out_of_resources }
		C.CL_OUT_OF_HOST_MEMORY { vcl.err_out_of_host_memory }
		C.CL_PROFILING_INFO_NOT_AVAILABLE { vcl.err_profiling_info_not_available }
		C.CL_MEM_COPY_OVERLAP { vcl.err_mem_copy_overlap }
		C.CL_IMAGE_FORMAT_MISMATCH { vcl.err_image_format_mismatch }
		C.CL_IMAGE_FORMAT_NOT_SUPPORTED { vcl.err_image_format_not_supported }
		C.CL_BUILD_PROGRAM_FAILURE { vcl.err_build_program_failure }
		C.CL_MAP_FAILURE { vcl.err_map_failure }
		C.CL_MISALIGNED_SUB_BUFFER_OFFSET { vcl.err_misaligned_sub_buffer_offset }
		C.CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST { vcl.err_exec_status_error_for_events_in_wait_list }
		C.CL_INVALID_VALUE { vcl.err_invalid_value }
		C.CL_INVALID_DEVICE_TYPE { vcl.err_invalid_device_type }
		C.CL_INVALID_PLATFORM { vcl.err_invalid_platform }
		C.CL_INVALID_DEVICE { vcl.err_invalid_device }
		C.CL_INVALID_CONTEXT { vcl.err_invalid_context }
		C.CL_INVALID_QUEUE_PROPERTIES { vcl.err_invalid_queue_properties }
		C.CL_INVALID_COMMAND_QUEUE { vcl.err_invalid_command_queue }
		C.CL_INVALID_HOST_PTR { vcl.err_invalid_host_ptr }
		C.CL_INVALID_MEM_OBJECT { vcl.err_invalid_mem_object }
		C.CL_INVALID_IMAGE_FORMAT_DESCRIPTOR { vcl.err_invalid_image_format_descriptor }
		C.CL_INVALID_IMAGE_SIZE { vcl.err_invalid_image_size }
		C.CL_INVALID_SAMPLER { vcl.err_invalid_sampler }
		C.CL_INVALID_BINARY { vcl.err_invalid_binary }
		C.CL_INVALID_BUILD_OPTIONS { vcl.err_invalid_build_options }
		C.CL_INVALID_PROGRAM { vcl.err_invalid_program }
		C.CL_INVALID_PROGRAM_EXECUTABLE { vcl.err_invalid_program_executable }
		C.CL_INVALID_KERNEL_NAME { vcl.err_invalid_kernel_name }
		C.CL_INVALID_KERNEL_DEFINITION { vcl.err_invalid_kernel_definition }
		C.CL_INVALID_KERNEL { vcl.err_invalid_kernel }
		C.CL_INVALID_ARG_INDEX { vcl.err_invalid_arg_index }
		C.CL_INVALID_ARG_VALUE { vcl.err_invalid_arg_value }
		C.CL_INVALID_ARG_SIZE { vcl.err_invalid_arg_size }
		C.CL_INVALID_KERNEL_ARGS { vcl.err_invalid_kernel_args }
		C.CL_INVALID_WORK_DIMENSION { vcl.err_invalid_work_dimension }
		C.CL_INVALID_WORK_GROUP_SIZE { vcl.err_invalid_work_group_size }
		C.CL_INVALID_WORK_ITEM_SIZE { vcl.err_invalid_work_item_size }
		C.CL_INVALID_GLOBAL_OFFSET { vcl.err_invalid_global_offset }
		C.CL_INVALID_EVENT_WAIT_LIST { vcl.err_invalid_event_wait_list }
		C.CL_INVALID_EVENT { vcl.err_invalid_event }
		C.CL_INVALID_OPERATION { vcl.err_invalid_operation }
		C.CL_INVALID_GL_OBJECT { vcl.err_invalid_gl_object }
		C.CL_INVALID_BUFFER_SIZE { vcl.err_invalid_buffer_size }
		C.CL_INVALID_MIP_LEVEL { vcl.err_invalid_mip_level }
		C.CL_INVALID_GLOBAL_WORK_SIZE { vcl.err_invalid_global_work_size }
		C.CL_INVALID_PROPERTY { err_invalid_propert }
		else { 'cl: error $e' }
	}
	return error_with_code(err, int(e))
}

pub fn vcl_error(code int) IError {
	if code == C.CL_SUCCESS {
		return none
	}
	return error_with_code(ErrVCL(code).err(), code)
}

pub fn vcl_panic(code int) {
	if code != C.CL_SUCCESS {
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
)
