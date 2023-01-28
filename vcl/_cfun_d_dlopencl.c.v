module vcl

import dl
import os
import vsl.vcl.utils

const (
	dl_open_issue    = not_found_dl_library
	dl_sym_opt_issue = not_found_dl_symbol
)

fn dl_open() !voidptr {
	$if globalcl ? {
		handle := utils.get_cl_handle()
		if !isnil(handle) {
			return handle
		}
	}

	if vcl_path := os.getenv_opt('VCL_LIBOPENCL_PATH') {
		for path in vcl_path.split(':') {
			if handle := dl.open_opt(path, dl.rtld_lazy) {
				$if globalcl ? {
					utils.set_cl_handle(handle)
				}
				return handle
			}
		}
	}

	for path in utils.default_paths {
		if handle := dl.open_opt(path, dl.rtld_lazy) {
			$if globalcl ? {
				utils.set_cl_handle(handle)
			}
			return handle
		}
	}

	return error('Could not find OpenCL library')
}

fn dl_close(handle voidptr) {
	dl.close(handle)
}

fn dl_sym_opt(name string) !(voidptr, voidptr) {
	$if globalcl ? {
		if sym := utils.get_cl_sym_opt_map()[name] {
			return utils.get_cl_handle(), sym
		}
	}
	handle := dl_open() or { return error_with_code('', vcl.dl_open_issue) }
	sym := dl.sym_opt(handle, name) or {
		dl_close(handle)
		return error_with_code('', vcl.dl_sym_opt_issue)
	}
	$if globalcl ? {
		utils.set_cl_sym_opt_map(name, sym)
	}
	return handle, sym
}

fn cleanup() {
	$if globalcl ? {
		handle := utils.get_cl_handle()
		if !isnil(handle) {
			dl_close(handle)
		}
	}
}

type ClCreateBufferType = fn (context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int) ClMem

[inline]
fn cl_create_buffer(context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int) ClMem {
	h, f := dl_sym_opt('clCreateBuffer') or {
		unsafe {
			*errcode_ret = err.code()
		}
		return unsafe { ClMem(nil) }
	}
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClCreateBufferType(f)
	return sfn(context, flags, size, host_ptr, errcode_ret)
}

type ClReleaseMemObjectType = fn (memobj ClMem) int

[inline]
fn cl_release_mem_object(memobj ClMem) int {
	h, f := dl_sym_opt('clReleaseMemObject') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClReleaseMemObjectType(f)
	return sfn(memobj)
}

type ClEnqueueWriteBufferType = fn (command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_write_buffer(command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	h, f := dl_sym_opt('clEnqueueWriteBuffer') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClEnqueueWriteBufferType(f)
	return sfn(command_queue, buffer, blocking_write, offset, cb, ptr, num_events_in_wait_list,
		event_wait_list, event)
}

type ClReleaseEventType = fn (event ClEvent) int

[inline]
fn cl_release_event(event ClEvent) int {
	h, f := dl_sym_opt('clReleaseEvent') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClReleaseEventType(f)
	return sfn(event)
}

type ClWaitForEventsType = fn (num_events u32, event_list &ClEvent) int

[inline]
fn cl_wait_for_events(num_events u32, event_list &ClEvent) int {
	h, f := dl_sym_opt('clWaitForEvents') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClWaitForEventsType(f)
	return sfn(num_events, event_list)
}

type ClEnqueueReadBufferType = fn (command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_read_buffer(command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	h, f := dl_sym_opt('clEnqueueReadBuffer') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClEnqueueReadBufferType(f)
	return sfn(command_queue, buffer, blocking_read, offset, cb, ptr, num_events_in_wait_list,
		event_wait_list, event)
}

type ClReleaseProgramType = fn (program ClProgram) int

[inline]
fn cl_release_program(program ClProgram) int {
	h, f := dl_sym_opt('clReleaseProgram') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClReleaseProgramType(f)
	return sfn(program)
}

type ClReleaseCommandQueueType = fn (command_queue ClCommandQueue) int

[inline]
fn cl_release_command_queue(command_queue ClCommandQueue) int {
	h, f := dl_sym_opt('clReleaseCommandQueue') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClReleaseCommandQueueType(f)
	return sfn(command_queue)
}

type ClReleaseContextType = fn (context ClContext) int

[inline]
fn cl_release_context(context ClContext) int {
	h, f := dl_sym_opt('clReleaseContext') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClReleaseContextType(f)
	return sfn(context)
}

type ClReleaseDeviceType = fn (device ClDeviceId) int

[inline]
fn cl_release_device(device ClDeviceId) int {
	h, f := dl_sym_opt('clReleaseDevice') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClReleaseDeviceType(f)
	return sfn(device)
}

type ClGetDeviceInfoType = fn (device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int

[inline]
fn cl_get_device_info(device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int {
	h, f := dl_sym_opt('clGetDeviceInfo') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClGetDeviceInfoType(f)
	return sfn(device, param_name, param_value_size, param_value, param_value_size_ret)
}

type ClGetDeviceIDsType = fn (platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32) int

[inline]
fn cl_get_device_i_ds(platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32) int {
	h, f := dl_sym_opt('clGetDeviceIDs') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClGetDeviceIDsType(f)
	return sfn(platform, device_type, num_entries, devices, num_devices)
}

type ClCreateProgramWithSourceType = fn (context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int) ClProgram

[inline]
fn cl_create_program_with_source(context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int) ClProgram {
	h, f := dl_sym_opt('clCreateProgramWithSource') or {
		unsafe {
			*errcode_ret = err.code()
		}
		return unsafe { ClProgram(nil) }
	}
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClCreateProgramWithSourceType(f)
	return sfn(context, count, strings, lengths, errcode_ret)
}

type ClCreateCommandQueueWithPropertiesType = fn (context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue

[inline]
fn cl_create_command_queue_with_properties(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue {
	h, f := dl_sym_opt('clCreateCommandQueueWithProperties') or {
		unsafe {
			*errcode_ret = err.code()
		}
		return unsafe { ClCommandQueue(nil) }
	}
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClCreateCommandQueueWithPropertiesType(f)
	return sfn(context, device, properties, errcode_ret)
}

type ClCreateCommandQueueType = fn (context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue

[inline]
fn cl_create_command_queue(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue {
	h, f := dl_sym_opt('clCreateCommandQueue') or {
		unsafe {
			*errcode_ret = err.code()
		}
		return unsafe { ClCommandQueue(nil) }
	}
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClCreateCommandQueueType(f)
	return sfn(context, device, properties, errcode_ret)
}

type ClBuildProgramType = fn (program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr) int

[inline]
fn cl_build_program(program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr) int {
	h, f := dl_sym_opt('clBuildProgram') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClBuildProgramType(f)
	return sfn(program, num_devices, device_list, options, pfn_notify, user_data)
}

type ClGetProgramBuildInfoType = fn (program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int

[inline]
fn cl_get_program_build_info(program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int {
	h, f := dl_sym_opt('clGetProgramBuildInfo') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClGetProgramBuildInfoType(f)
	return sfn(program, device, param_name, param_value_size, param_value, param_value_size_ret)
}

type ClCreateKernelType = fn (program ClProgram, kernel_name &char, errcode_ret &int) ClKernel

[inline]
fn cl_create_kernel(program ClProgram, kernel_name &char, errcode_ret &int) ClKernel {
	h, f := dl_sym_opt('clCreateKernel') or {
		unsafe {
			*errcode_ret = err.code()
		}
		return unsafe { ClKernel(nil) }
	}
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClCreateKernelType(f)
	return sfn(program, kernel_name, errcode_ret)
}

type ClReleaseKernelType = fn (kernel ClKernel) int

[inline]
fn cl_release_kernel(kernel ClKernel) int {
	h, f := dl_sym_opt('clReleaseKernel') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClReleaseKernelType(f)
	return sfn(kernel)
}

type ClSetKernelArgType = fn (kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr) int

[inline]
fn cl_set_kernel_arg(kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr) int {
	h, f := dl_sym_opt('clSetKernelArg') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClSetKernelArgType(f)
	return sfn(kernel, arg_index, arg_size, arg_value)
}

type ClEnqueueNDRangeKernelType = fn (command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_nd_range_kernel(command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	h, f := dl_sym_opt('clEnqueueNDRangeKernel') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClEnqueueNDRangeKernelType(f)
	return sfn(command_queue, kernel, work_dim, global_work_offset, global_work_size,
		local_work_size, num_events_in_wait_list, event_wait_list, event)
}

type ClGetPlatformIDsType = fn (num_entries u32, platforms &ClPlatformId, num_platforms &u32) int

[inline]
fn cl_get_platform_i_ds(num_entries u32, platforms &ClPlatformId, num_platforms &u32) int {
	h, f := dl_sym_opt('clGetPlatformIDs') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClGetPlatformIDsType(f)
	return sfn(num_entries, platforms, num_platforms)
}

type ClCreateContextType = fn (properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int) ClContext

[inline]
fn cl_create_context(properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int) ClContext {
	h, f := dl_sym_opt('clCreateContext') or {
		unsafe {
			*errcode_ret = err.code()
		}
		return unsafe { ClContext(nil) }
	}
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClCreateContextType(f)
	return sfn(properties, num_devices, devices, pfn_notify, user_data, errcode_ret)
}

type ClCreateImageType = fn (context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int) ClMem

[inline]
fn cl_create_image(context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int) ClMem {
	h, f := dl_sym_opt('clCreateImage') or {
		unsafe {
			*errcode_ret = err.code()
		}
		return unsafe { ClMem(nil) }
	}
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := ClCreateImageType(f)
	return sfn(context, flags, format, desc, data, errcode_ret)
}


type clEnqueueReadImageType = fn (command_queue ClCommandQueue, image ClMem, blocking_read bool, origin3 usize, region3 usize, row_pitch usize, slice_pitch usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int
[inline]
fn cl_enqueue_read_image(command_queue ClCommandQueue, image ClMem, blocking_read bool, origin3 usize, region3 usize, row_pitch usize, slice_pitch usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int{
	h, f := dl_sym_opt('clEnqueueReadImage') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := clEnqueueReadImageType(f)
	return sfn(command_queue, image, blocking_read, origin3, region3, row_pitch, slice_pitch, ptr, num_events_in_wait_list, event_wait_list, event)
}

type clEnqueueWriteImageType = fn(command_queue ClCommandQueue, image ClMem, blocking_write bool, origin3 usize, region3 usize, row_pitch usize, slice_pitch usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int
[inline]
fn cl_enqueue_write_image(command_queue ClCommandQueue, image ClMem, blocking_write bool, origin3 usize, region3 usize, row_pitch usize, slice_pitch usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int{
	h, f := dl_sym_opt('clEnqueueWriteImage') or { return err.code() }
	$if !globalcl ? {
		defer {
			dl_close(h)
		}
	}
	sfn := clEnqueueWriteImageType(f)
	return sfn(command_queue, image, blocking_read, origin3, region3, row_pitch, slice_pitch, ptr, num_events_in_wait_list, event_wait_list, event)
}