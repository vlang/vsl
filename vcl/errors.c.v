module vcl

// Generally an unexpected result from an OpenCL function (e.g. success but null pointer)
const err_unknown = error('vcl_cl: unknown error')

// ErrVCL converts that OpenCL error code to an V error
pub type ErrVCL = int

pub fn (e ErrVCL) err() IError {
	if e == success {
		return none
	}

	err := match e {
		device_not_found { err_device_not_found }
		device_not_available { err_device_not_available }
		compiler_not_available { err_compiler_not_available }
		mem_object_allocation_failure { err_mem_object_allocation_failure }
		out_of_resources { err_out_of_resources }
		out_of_host_memory { err_out_of_host_memory }
		profiling_info_not_available { err_profiling_info_not_available }
		mem_copy_overlap { err_mem_copy_overlap }
		image_format_mismatch { err_image_format_mismatch }
		image_format_not_supported { err_image_format_not_supported }
		build_program_failure { err_build_program_failure }
		map_failure { err_map_failure }
		misaligned_sub_buffer_offset { err_misaligned_sub_buffer_offset }
		exec_status_error_for_events_in_wait_list { err_exec_status_error_for_events_in_wait_list }
		compile_program_failure { err_compile_program_failure }
		linker_not_available { err_linker_not_available }
		link_program_failure { err_link_program_failure }
		device_partition_failed { err_device_partition_failed }
		kernel_arg_info_not_available { err_kernel_arg_info_not_available }
		invalid_value { err_invalid_value }
		invalid_device_type { err_invalid_device_type }
		invalid_platform { err_invalid_platform }
		invalid_device { err_invalid_device }
		invalid_context { err_invalid_context }
		invalid_queue_properties { err_invalid_queue_properties }
		invalid_command_queue { err_invalid_command_queue }
		invalid_host_ptr { err_invalid_host_ptr }
		invalid_mem_object { err_invalid_mem_object }
		invalid_image_format_descriptor { err_invalid_image_format_descriptor }
		invalid_image_size { err_invalid_image_size }
		invalid_sampler { err_invalid_sampler }
		invalid_binary { err_invalid_binary }
		invalid_build_options { err_invalid_build_options }
		invalid_program { err_invalid_program }
		invalid_program_executable { err_invalid_program_executable }
		invalid_kernel_name { err_invalid_kernel_name }
		invalid_kernel_definition { err_invalid_kernel_definition }
		invalid_kernel { err_invalid_kernel }
		invalid_arg_index { err_invalid_arg_index }
		invalid_arg_value { err_invalid_arg_value }
		invalid_arg_size { err_invalid_arg_size }
		invalid_kernel_args { err_invalid_kernel_args }
		invalid_work_dimension { err_invalid_work_dimension }
		invalid_work_group_size { err_invalid_work_group_size }
		invalid_work_item_size { err_invalid_work_item_size }
		invalid_global_offset { err_invalid_global_offset }
		invalid_event_wait_list { err_invalid_event_wait_list }
		invalid_event { err_invalid_event }
		invalid_operation { err_invalid_operation }
		invalid_gl_object { err_invalid_gl_object }
		invalid_buffer_size { err_invalid_buffer_size }
		invalid_mip_level { err_invalid_mip_level }
		invalid_global_work_size { err_invalid_global_work_size }
		invalid_property { err_invalid_property }
		invalid_image_descriptor { err_invalid_image_descriptor }
		invalid_compiler_options { err_invalid_compiler_options }
		invalid_linker_options { err_invalid_linker_options }
		invalid_device_partition_count { err_invalid_device_partition_count }
		invalid_pipe_size { err_invalid_pipe_size }
		invalid_device_queue { err_invalid_device_queue }
		invalid_spec_id { err_invalid_spec_id }
		max_size_restriction_exceeded { err_max_size_restriction_exceeded }
		dl_sym_issue { err_dl_sym_issue }
		dl_open_issue { err_dl_open_issue }
		else { 'vcl_cl: error ${e}' }
	}
	return error_with_code(err, int(e))
}

pub fn error_from_code(code int) IError {
	return ErrVCL(code).err()
}

pub fn error_or_default[T](code int, default T) !T {
	if code == success {
		return default
	}
	return ErrVCL(code).err()
}

pub fn typed_error[T](code int) !T {
	if code == success {
		return
	}
	return ErrVCL(code).err()
}

pub fn vcl_error(code int) ! {
	err := ErrVCL(code).err()
	match err {
		none {}
		else {
			return err
		}
	}
}

pub fn panic_on_error(code int) {
	err := ErrVCL(code).err()
	match err {
		none {}
		else {
			panic(err)
		}
	}
}

// Common OpenCl errors
const err_device_not_found = 'vcl_cl: Device Not Found'
const err_device_not_available = 'vcl_cl: Device Not Available'
const err_compiler_not_available = 'vcl_cl: Compiler Not Available'
const err_mem_object_allocation_failure = 'vcl_cl: Mem Object Allocation Failure'
const err_out_of_resources = 'vcl_cl: Out Of Resources'
const err_out_of_host_memory = 'vcl_cl: Out Of Host Memory'
const err_profiling_info_not_available = 'vcl_cl: Profiling Info Not Available'
const err_mem_copy_overlap = 'vcl_cl: Mem Copy Overlap'
const err_image_format_mismatch = 'vcl_cl: Image Format Mismatch'
const err_image_format_not_supported = 'vcl_cl: Image Format Not Supported'
const err_build_program_failure = 'vcl_cl: Build Program Failure'
const err_map_failure = 'vcl_cl: Map Failure'
const err_misaligned_sub_buffer_offset = 'vcl_cl: Misaligned Sub Buffer Offset'
const err_exec_status_error_for_events_in_wait_list = 'vcl_cl: Exec Status Error For Events In Wait List'
const err_compile_program_failure = 'vcl_cl: Compile Program Failure'
const err_linker_not_available = 'vcl_cl: Linker Not Available'
const err_link_program_failure = 'vcl_cl: Link Program Failure'
const err_device_partition_failed = 'vcl_cl: Device Partition Failed'
const err_kernel_arg_info_not_available = 'vcl_cl: Kernel Arg Info Not Available'
const err_invalid_value = 'vcl_cl: Invalid Value'
const err_invalid_device_type = 'vcl_cl: Invalid Device Type'
const err_invalid_platform = 'vcl_cl: Invalid Platform'
const err_invalid_device = 'vcl_cl: Invalid Device'
const err_invalid_context = 'vcl_cl: Invalid Context'
const err_invalid_queue_properties = 'vcl_cl: Invalid Queue Properties'
const err_invalid_command_queue = 'vcl_cl: Invalid Command Queue'
const err_invalid_host_ptr = 'vcl_cl: Invalid Host Ptr'
const err_invalid_mem_object = 'vcl_cl: Invalid Mem Object'
const err_invalid_image_format_descriptor = 'vcl_cl: Invalid Image Format Descriptor'
const err_invalid_image_size = 'vcl_cl: Invalid Image Size'
const err_invalid_sampler = 'vcl_cl: Invalid Sampler'
const err_invalid_binary = 'vcl_cl: Invalid Binary'
const err_invalid_build_options = 'vcl_cl: Invalid Build Options'
const err_invalid_program = 'vcl_cl: Invalid Program'
const err_invalid_program_executable = 'vcl_cl: Invalid Program Executable'
const err_invalid_kernel_name = 'vcl_cl: Invalid Kernel Name'
const err_invalid_kernel_definition = 'vcl_cl: Invalid Kernel Definition'
const err_invalid_kernel = 'vcl_cl: Invalid Kernel'
const err_invalid_arg_index = 'vcl_cl: Invalid Arg Index'
const err_invalid_arg_value = 'vcl_cl: Invalid Arg Value'
const err_invalid_arg_size = 'vcl_cl: Invalid Arg Size'
const err_invalid_kernel_args = 'vcl_cl: Invalid Kernel Args'
const err_invalid_work_dimension = 'vcl_cl: Invalid Work Dimension'
const err_invalid_work_group_size = 'vcl_cl: Invalid Work Group Size'
const err_invalid_work_item_size = 'vcl_cl: Invalid Work Item Size'
const err_invalid_global_offset = 'vcl_cl: Invalid Global Offset'
const err_invalid_event_wait_list = 'vcl_cl: Invalid Event Wait List'
const err_invalid_event = 'vcl_cl: Invalid Event'
const err_invalid_operation = 'vcl_cl: Invalid Operation'
const err_invalid_gl_object = 'vcl_cl: Invalid Gl Object'
const err_invalid_buffer_size = 'vcl_cl: Invalid Buffer Size'
const err_invalid_mip_level = 'vcl_cl: Invalid Mip Level'
const err_invalid_global_work_size = 'vcl_cl: Invalid Global Work Size'
const err_invalid_property = 'vcl_cl: Invalid Property'
const err_invalid_image_descriptor = 'vcl_cl: Invalid Image Descriptor'
const err_invalid_compiler_options = 'vcl_cl: Invalid Compiler Options'
const err_invalid_linker_options = 'vcl_cl: Invalid Linker Options'
const err_invalid_device_partition_count = 'vcl_cl: Invalid Device Partition Count'
const err_invalid_pipe_size = 'vcl_cl: Invalid Pipe Size'
const err_invalid_device_queue = 'vcl_cl: Invalid Device Queue'
const err_invalid_spec_id = 'vcl_cl: Invalid Spec Id'
const err_max_size_restriction_exceeded = 'vcl_cl: Max Size Restriction exceeded'

// Dl errors
const err_dl_sym_issue = 'vcl_cl_dl: Not Found Dl Library'
const err_dl_open_issue = 'vcl_cl_dl: Not Found Dl Symbol'

// err codes
const success = 0
const device_not_found = -1
const device_not_available = -2
const compiler_not_available = -3
const mem_object_allocation_failure = -4
const out_of_resources = -5
const out_of_host_memory = -6
const profiling_info_not_available = -7
const mem_copy_overlap = -8
const image_format_mismatch = -9
const image_format_not_supported = -10
const build_program_failure = -11
const map_failure = -12
const misaligned_sub_buffer_offset = -13
const exec_status_error_for_events_in_wait_list = -14
const compile_program_failure = -15
const linker_not_available = -16
const link_program_failure = -17
const device_partition_failed = -18
const kernel_arg_info_not_available = -19
const invalid_value = -30
const invalid_device_type = -31
const invalid_platform = -32
const invalid_device = -33
const invalid_context = -34
const invalid_queue_properties = -35
const invalid_command_queue = -36
const invalid_host_ptr = -37
const invalid_mem_object = -38
const invalid_image_format_descriptor = -39
const invalid_image_size = -40
const invalid_sampler = -41
const invalid_binary = -42
const invalid_build_options = -43
const invalid_program = -44
const invalid_program_executable = -45
const invalid_kernel_name = -46
const invalid_kernel_definition = -47
const invalid_kernel = -48
const invalid_arg_index = -49
const invalid_arg_value = -50
const invalid_arg_size = -51
const invalid_kernel_args = -52
const invalid_work_dimension = -53
const invalid_work_group_size = -54
const invalid_work_item_size = -55
const invalid_global_offset = -56
const invalid_event_wait_list = -57
const invalid_event = -58
const invalid_operation = -59
const invalid_gl_object = -60
const invalid_buffer_size = -61
const invalid_mip_level = -62
const invalid_global_work_size = -63
const invalid_property = -64
const invalid_image_descriptor = -65
const invalid_compiler_options = -66
const invalid_linker_options = -67
const invalid_device_partition_count = -68
const invalid_pipe_size = -69
const invalid_device_queue = -70
const invalid_spec_id = -71
const max_size_restriction_exceeded = -72
const dl_sym_issue = -73
const dl_open_issue = -74
