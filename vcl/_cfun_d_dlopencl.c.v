module vcl

import vsl.vcl.internal.dl

fn map_dl_err_code(code int) int {
	match code {
		dl.dl_open_issue_code { return dl_sym_issue }
		dl.dl_no_path_issue_code { return dl_sym_issue }
		dl.dl_sym_issue_code { return dl_open_issue }
		dl.dl_close_issue_code { return dl_open_issue }
		dl.dl_register_issue_code { return dl_sym_issue }
		else { return code }
	}
}

type ClCreateBufferType = fn (context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int) ClMem

[inline]
fn cl_create_buffer(context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int) ClMem {
	f := dl.get_sym('clCreateBuffer') or {
		unsafe {
			*errcode_ret = map_dl_err_code(err.code())
		}
		return unsafe { ClMem(nil) }
	}
	sfn := ClCreateBufferType(f)
	return sfn(context, flags, size, host_ptr, errcode_ret)
}

type ClReleaseMemObjectType = fn (memobj ClMem) int

[inline]
fn cl_release_mem_object(memobj ClMem) int {
	f := dl.get_sym('clReleaseMemObject') or { return map_dl_err_code(err.code()) }
	sfn := ClReleaseMemObjectType(f)
	return sfn(memobj)
}

type ClEnqueueWriteBufferType = fn (command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_write_buffer(command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	f := dl.get_sym('clEnqueueWriteBuffer') or { return map_dl_err_code(err.code()) }
	sfn := ClEnqueueWriteBufferType(f)
	return sfn(command_queue, buffer, blocking_write, offset, cb, ptr, num_events_in_wait_list,
		event_wait_list, event)
}

type ClReleaseEventType = fn (event ClEvent) int

[inline]
fn cl_release_event(event ClEvent) int {
	f := dl.get_sym('clReleaseEvent') or { return map_dl_err_code(err.code()) }
	sfn := ClReleaseEventType(f)
	return sfn(event)
}

type ClWaitForEventsType = fn (num_events u32, event_list &ClEvent) int

[inline]
fn cl_wait_for_events(num_events u32, event_list &ClEvent) int {
	f := dl.get_sym('clWaitForEvents') or { return map_dl_err_code(err.code()) }
	sfn := ClWaitForEventsType(f)
	return sfn(num_events, event_list)
}

type ClEnqueueReadBufferType = fn (command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_read_buffer(command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	f := dl.get_sym('clEnqueueReadBuffer') or { return map_dl_err_code(err.code()) }
	sfn := ClEnqueueReadBufferType(f)
	return sfn(command_queue, buffer, blocking_read, offset, cb, ptr, num_events_in_wait_list,
		event_wait_list, event)
}

type ClReleaseProgramType = fn (program ClProgram) int

[inline]
fn cl_release_program(program ClProgram) int {
	f := dl.get_sym('clReleaseProgram') or { return map_dl_err_code(err.code()) }
	sfn := ClReleaseProgramType(f)
	return sfn(program)
}

type ClReleaseCommandQueueType = fn (command_queue ClCommandQueue) int

[inline]
fn cl_release_command_queue(command_queue ClCommandQueue) int {
	f := dl.get_sym('clReleaseCommandQueue') or { return map_dl_err_code(err.code()) }
	sfn := ClReleaseCommandQueueType(f)
	return sfn(command_queue)
}

type ClReleaseContextType = fn (context ClContext) int

[inline]
fn cl_release_context(context ClContext) int {
	f := dl.get_sym('clReleaseContext') or { return map_dl_err_code(err.code()) }
	sfn := ClReleaseContextType(f)
	return sfn(context)
}

type ClReleaseDeviceType = fn (device ClDeviceId) int

[inline]
fn cl_release_device(device ClDeviceId) int {
	f := dl.get_sym('clReleaseDevice') or { return map_dl_err_code(err.code()) }
	sfn := ClReleaseDeviceType(f)
	return sfn(device)
}

type ClGetDeviceInfoType = fn (device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int

[inline]
fn cl_get_device_info(device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int {
	f := dl.get_sym('clGetDeviceInfo') or { return map_dl_err_code(err.code()) }
	sfn := ClGetDeviceInfoType(f)
	return sfn(device, param_name, param_value_size, param_value, param_value_size_ret)
}

type ClGetDeviceIDsType = fn (platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32) int

[inline]
fn cl_get_device_i_ds(platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32) int {
	f := dl.get_sym('clGetDeviceIDs') or { return map_dl_err_code(err.code()) }
	sfn := ClGetDeviceIDsType(f)
	return sfn(platform, device_type, num_entries, devices, num_devices)
}

type ClCreateProgramWithSourceType = fn (context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int) ClProgram

[inline]
fn cl_create_program_with_source(context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int) ClProgram {
	f := dl.get_sym('clCreateProgramWithSource') or {
		unsafe {
			*errcode_ret = map_dl_err_code(err.code())
		}
		return unsafe { ClProgram(nil) }
	}
	sfn := ClCreateProgramWithSourceType(f)
	return sfn(context, count, strings, lengths, errcode_ret)
}

type ClCreateCommandQueueWithPropertiesType = fn (context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue

[inline]
fn cl_create_command_queue_with_properties(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue {
	f := dl.get_sym('clCreateCommandQueueWithProperties') or {
		unsafe {
			*errcode_ret = map_dl_err_code(err.code())
		}
		return unsafe { ClCommandQueue(nil) }
	}
	sfn := ClCreateCommandQueueWithPropertiesType(f)
	return sfn(context, device, properties, errcode_ret)
}

type ClCreateCommandQueueType = fn (context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue

[inline]
fn cl_create_command_queue(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue {
	f := dl.get_sym('clCreateCommandQueue') or {
		unsafe {
			*errcode_ret = map_dl_err_code(err.code())
		}
		return unsafe { ClCommandQueue(nil) }
	}
	sfn := ClCreateCommandQueueType(f)
	return sfn(context, device, properties, errcode_ret)
}

type ClBuildProgramType = fn (program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr) int

[inline]
fn cl_build_program(program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr) int {
	f := dl.get_sym('clBuildProgram') or { return map_dl_err_code(err.code()) }
	sfn := ClBuildProgramType(f)
	return sfn(program, num_devices, device_list, options, pfn_notify, user_data)
}

type ClGetProgramBuildInfoType = fn (program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int

[inline]
fn cl_get_program_build_info(program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int {
	f := dl.get_sym('clGetProgramBuildInfo') or { return map_dl_err_code(err.code()) }
	sfn := ClGetProgramBuildInfoType(f)
	return sfn(program, device, param_name, param_value_size, param_value, param_value_size_ret)
}

type ClCreateKernelType = fn (program ClProgram, kernel_name &char, errcode_ret &int) ClKernel

[inline]
fn cl_create_kernel(program ClProgram, kernel_name &char, errcode_ret &int) ClKernel {
	f := dl.get_sym('clCreateKernel') or {
		unsafe {
			*errcode_ret = map_dl_err_code(err.code())
		}
		return unsafe { ClKernel(nil) }
	}
	sfn := ClCreateKernelType(f)
	return sfn(program, kernel_name, errcode_ret)
}

type ClReleaseKernelType = fn (kernel ClKernel) int

[inline]
fn cl_release_kernel(kernel ClKernel) int {
	f := dl.get_sym('clReleaseKernel') or { return map_dl_err_code(err.code()) }
	sfn := ClReleaseKernelType(f)
	return sfn(kernel)
}

type ClSetKernelArgType = fn (kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr) int

[inline]
fn cl_set_kernel_arg(kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr) int {
	f := dl.get_sym('clSetKernelArg') or { return map_dl_err_code(err.code()) }
	sfn := ClSetKernelArgType(f)
	return sfn(kernel, arg_index, arg_size, arg_value)
}

type ClEnqueueNDRangeKernelType = fn (command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_nd_range_kernel(command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	f := dl.get_sym('clEnqueueNDRangeKernel') or { return map_dl_err_code(err.code()) }
	sfn := ClEnqueueNDRangeKernelType(f)
	return sfn(command_queue, kernel, work_dim, global_work_offset, global_work_size,
		local_work_size, num_events_in_wait_list, event_wait_list, event)
}

type ClGetPlatformIDsType = fn (num_entries u32, platforms &ClPlatformId, num_platforms &u32) int

[inline]
fn cl_get_platform_i_ds(num_entries u32, platforms &ClPlatformId, num_platforms &u32) int {
	f := dl.get_sym('clGetPlatformIDs') or { return map_dl_err_code(err.code()) }
	sfn := ClGetPlatformIDsType(f)
	return sfn(num_entries, platforms, num_platforms)
}

type ClCreateContextType = fn (properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int) ClContext

[inline]
fn cl_create_context(properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int) ClContext {
	f := dl.get_sym('clCreateContext') or {
		unsafe {
			*errcode_ret = map_dl_err_code(err.code())
		}
		return unsafe { ClContext(nil) }
	}
	sfn := ClCreateContextType(f)
	return sfn(properties, num_devices, devices, pfn_notify, user_data, errcode_ret)
}

type ClCreateImageType = fn (context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int) ClMem

[inline]
fn cl_create_image(context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int) ClMem {
	f := dl.get_sym('clCreateImage') or {
		unsafe {
			*errcode_ret = map_dl_err_code(err.code())
		}
		return unsafe { ClMem(nil) }
	}
	sfn := ClCreateImageType(f)
	return sfn(context, flags, format, desc, data, errcode_ret)
}


type clEnqueueReadImageType = fn (command_queue ClCommandQueue, image ClMem, blocking_read bool, origin3 [3]usize, region3 [3]usize, row_pitch usize, slice_pitch usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_read_image(command_queue ClCommandQueue, image ClMem, blocking_read bool,  origin3 [3]usize, region3 [3]usize, row_pitch usize, slice_pitch usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	h, f := dl.get_sym('clEnqueueReadImage') or { return err.code() }
	sfn := clEnqueueReadImageType(f)
	return sfn(command_queue, image, blocking_read, origin3, region3, row_pitch, slice_pitch,
		ptr, num_events_in_wait_list, event_wait_list, event)
}

type clEnqueueWriteImageType = fn (command_queue ClCommandQueue, image ClMem, blocking_write bool, origin3 [3]usize, region3 [3]usize, row_pitch usize, slice_pitch usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_write_image(command_queue ClCommandQueue, image ClMem, blocking_write bool,  origin3 [3]usize, region3 [3]usize, row_pitch usize, slice_pitch usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	h, f := dl.get_sym('clEnqueueWriteImage') or { return err.code() }
	sfn := clEnqueueWriteImageType(f)
	return sfn(command_queue, image, blocking_read, origin3, region3, row_pitch, slice_pitch,
		ptr, num_events_in_wait_list, event_wait_list, event)
}