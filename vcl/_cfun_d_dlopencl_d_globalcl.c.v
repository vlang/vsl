module vcl

import dl
import os

const (
	dl_open_issue    = not_found_dl_library
	dl_sym_opt_issue = not_found_dl_symbol
)

const (
	darwin_default_paths  = [
		'libOpenCL${dl.dl_ext}',
		'/System/Library/Frameworks/OpenCL.framework/OpenCL',
	]
	android_default_paths = [
		'libOpenCL${dl.dl_ext}',
		'/system/lib64/libOpenCL${dl.dl_ext}',
		'/system/vendor/lib64/libOpenCL${dl.dl_ext}',
		'/system/vendor/lib64/egl/libGLES_mali${dl.dl_ext}',
		'/system/vendor/lib64/libPVROCL${dl.dl_ext}',
		'/data/data/org.pocl.libs/files/lib64/libpocl${dl.dl_ext}',
		'/system/lib/libOpenCL${dl.dl_ext}',
		'/system/vendor/lib/libOpenCL${dl.dl_ext}',
		'/system/vendor/lib/egl/libGLES_mali${dl.dl_ext}',
		'/system/vendor/lib/libPVROCL${dl.dl_ext}',
		'/data/data/org.pocl.libs/files/lib/libpocl${dl.dl_ext}',
		'/system_ext/lib64/libOpenCL_system${dl.dl_ext}',
	]
	windows_default_paths = [
		'OpenCL${dl.dl_ext}',
	]
	linux_default_paths   = ['libOpenCL${dl.dl_ext}', '/usr/lib/libOpenCL${dl.dl_ext}',
		'/usr/local/lib/libOpenCL${dl.dl_ext}', '/usr/local/lib/libpocl${dl.dl_ext}',
		'/usr/lib64/libOpenCL${dl.dl_ext}', '/usr/lib32/libOpenCL${dl.dl_ext}']
)

fn dl_open() !voidptr {
	default_paths := $if windows {
		vcl.windows_default_paths
	} $else $if linux {
		vcl.linux_default_paths
	} $else $if darwin {
		vcl.darwin_default_paths
	} $else $if android || termux {
		vcl.android_default_paths
	} $else {
		[]string{}
	}

	if vcl_path := os.getenv_opt('VCL_LIBOPENCL_PATH') {
		for path in vcl_path.split(':') {
			if handle := dl.open_opt(path, dl.rtld_lazy) {
				return handle
			}
		}
	}

	for path in default_paths {
		if handle := dl.open_opt(path, dl.rtld_lazy) {
			return handle
		}
	}

	return error('Could not find OpenCL library')
}

fn dl_close(handle voidptr) {
	dl.close(handle)
}


__global (
	handle                                      = unsafe { nil }
	cl_create_buffer_sym                        = ClCreateBufferType(unsafe { nil })
	cl_release_mem_object_sym                   = ClReleaseMemObjectType(unsafe { nil })
	cl_enqueue_write_buffer_sym                 = ClEnqueueWriteBufferType(unsafe { nil })
	cl_release_event_sym                        = ClReleaseEventType(unsafe { nil })
	cl_wait_for_events_sym                      = ClWaitForEventsType(unsafe { nil })
	cl_enqueue_read_buffer_sym                  = ClEnqueueReadBufferType(unsafe { nil })
	cl_release_program_sym                      = ClReleaseProgramType(unsafe { nil })
	cl_release_command_queue_sym                = ClReleaseCommandQueueType(unsafe { nil })
	cl_release_context_sym                      = ClReleaseContextType(unsafe { nil })
	cl_release_device_sym                       = ClReleaseDeviceType(unsafe { nil })
	cl_get_device_info_sym                      = ClGetDeviceInfoType(unsafe { nil })
	cl_get_device_i_ds_sym                      = ClGetDeviceIDsType(unsafe { nil })
	cl_create_program_with_source_sym           = ClCreateProgramWithSourceType(unsafe { nil })
	cl_create_command_queue_with_properties_sym = ClCreateCommandQueueWithPropertiesType(unsafe { nil })
	cl_create_command_queue_sym                 = ClCreateCommandQueueType(unsafe { nil })
	cl_build_program_sym                        = ClBuildProgramType(unsafe { nil })
	cl_get_program_build_info_sym               = ClGetProgramBuildInfoType(unsafe { nil })
	cl_create_kernel_sym                        = ClCreateKernelType(unsafe { nil })
	cl_release_kernel_sym                       = ClReleaseKernelType(unsafe { nil })
	cl_set_kernel_arg_sym                       = ClSetKernelArgType(unsafe { nil })
	cl_enqueue_n_d_range_kernel_sym             = ClEnqueueNDRangeKernelType(unsafe { nil })
	cl_get_platform_i_ds_sym                    = ClGetPlatformIDsType(unsafe { nil })
	cl_create_context_sym                       = ClCreateContextType(unsafe { nil })
	cl_create_image_sym                         = ClCreateImageType(unsafe { nil })
)

fn init() {
	handle = dl_open() or { panic('Could not open OpenCL library') }
}

fn clear() {
	dl_close(handle)
}

type ClCreateBufferType = fn (context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int) ClMem

[inline]
fn cl_create_buffer(context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int) ClMem {
	if cl_create_buffer_sym == ClCreateBufferType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clCreateBuffer') or {
			unsafe {
				*errcode_ret = dl_sym_opt_issue
			}
			return unsafe { ClMem(nil) }
		}
		cl_create_buffer_sym = ClCreateBufferType(f)
	}
	return cl_create_buffer_sym(context, flags, size, host_ptr, errcode_ret)
}

type ClReleaseMemObjectType = fn (memobj ClMem) int

[inline]
fn cl_release_mem_object(memobj ClMem) int {
	if cl_release_mem_object_sym == ClReleaseMemObjectType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clReleaseMemObject') or { return dl_sym_opt_issue }
		cl_release_mem_object_sym = ClReleaseMemObjectType(f)
	}
	return cl_release_mem_object_sym(memobj)
}

type ClEnqueueWriteBufferType = fn (command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_write_buffer(command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	if cl_enqueue_write_buffer_sym == ClEnqueueWriteBufferType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clEnqueueWriteBuffer') or { return dl_sym_opt_issue }
		cl_enqueue_write_buffer_sym = ClEnqueueWriteBufferType(f)
	}
	return cl_enqueue_write_buffer_sym(command_queue, buffer, blocking_write, offset,
		cb, ptr, num_events_in_wait_list, event_wait_list, event)
}

type ClReleaseEventType = fn (event ClEvent) int

[inline]
fn cl_release_event(event ClEvent) int {
	if cl_release_event_sym == ClReleaseEventType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clReleaseEvent') or { return dl_sym_opt_issue }
		cl_release_event_sym = ClReleaseEventType(f)
	}
	return cl_release_event_sym(event)
}

type ClWaitForEventsType = fn (num_events u32, event_list &ClEvent) int

[inline]
fn cl_wait_for_events(num_events u32, event_list &ClEvent) int {
	if cl_wait_for_events_sym == ClWaitForEventsType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clWaitForEvents') or { return dl_sym_opt_issue }
		cl_wait_for_events_sym = ClWaitForEventsType(f)
	}
	return cl_wait_for_events_sym(num_events, event_list)
}

type ClEnqueueReadBufferType = fn (command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_read_buffer(command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	if cl_enqueue_read_buffer_sym == ClEnqueueReadBufferType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clEnqueueReadBuffer') or { return dl_sym_opt_issue }
		cl_enqueue_read_buffer_sym = ClEnqueueReadBufferType(f)
	}
	return cl_enqueue_read_buffer_sym(command_queue, buffer, blocking_read, offset, cb,
		ptr, num_events_in_wait_list, event_wait_list, event)
}

type ClReleaseProgramType = fn (program ClProgram) int

[inline]
fn cl_release_program(program ClProgram) int {
	if cl_release_program_sym == ClReleaseProgramType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clReleaseProgram') or { return dl_sym_opt_issue }
		cl_release_program_sym = ClReleaseProgramType(f)
	}
	return cl_release_program_sym(program)
}

type ClReleaseCommandQueueType = fn (command_queue ClCommandQueue) int

[inline]
fn cl_release_command_queue(command_queue ClCommandQueue) int {
	if cl_release_command_queue_sym == ClReleaseCommandQueueType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clReleaseCommandQueue') or { return dl_sym_opt_issue }
		cl_release_command_queue_sym = ClReleaseCommandQueueType(f)
	}
	return cl_release_command_queue_sym(command_queue)
}

type ClReleaseContextType = fn (context ClContext) int

[inline]
fn cl_release_context(context ClContext) int {
	if cl_release_context_sym == ClReleaseContextType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clReleaseContext') or { return dl_sym_opt_issue }
		cl_release_context_sym = ClReleaseContextType(f)
	}
	return cl_release_context_sym(context)
}

type ClReleaseDeviceType = fn (device ClDeviceId) int

[inline]
fn cl_release_device(device ClDeviceId) int {
	if cl_release_device_sym == ClReleaseDeviceType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clReleaseDevice') or { return dl_sym_opt_issue }
		cl_release_device_sym = ClReleaseDeviceType(f)
	}
	return cl_release_device_sym(device)
}

type ClGetDeviceInfoType = fn (device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int

[inline]
fn cl_get_device_info(device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int {
	if cl_get_device_info_sym == ClGetDeviceInfoType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clGetDeviceInfo') or { return dl_sym_opt_issue }
		cl_get_device_info_sym = ClGetDeviceInfoType(f)
	}
	return cl_get_device_info_sym(device, param_name, param_value_size, param_value, param_value_size_ret)
}

type ClGetDeviceIDsType = fn (platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32) int

[inline]
fn cl_get_device_i_ds(platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32) int {
	if cl_get_device_i_ds_sym == ClGetDeviceIDsType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clGetDeviceIDs') or { return dl_sym_opt_issue }
		cl_get_device_i_ds_sym = ClGetDeviceIDsType(f)
	}
	return cl_get_device_i_ds_sym(platform, device_type, num_entries, devices, num_devices)
}

type ClCreateProgramWithSourceType = fn (context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int) ClProgram

[inline]
fn cl_create_program_with_source(context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int) ClProgram {
	if cl_create_program_with_source_sym == ClCreateProgramWithSourceType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clCreateProgramWithSource') or {
			unsafe {
				*errcode_ret = dl_sym_opt_issue
			}
			return unsafe { ClProgram(nil) }
		}
		cl_create_program_with_source_sym = ClCreateProgramWithSourceType(f)
	}
	return cl_create_program_with_source_sym(context, count, strings, lengths, errcode_ret)
}

type ClCreateCommandQueueWithPropertiesType = fn (context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue

[inline]
fn cl_create_command_queue_with_properties(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue {
	if cl_create_command_queue_with_properties_sym == ClCreateCommandQueueWithPropertiesType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clCreateCommandQueueWithProperties') or {
			unsafe {
				*errcode_ret = dl_sym_opt_issue
			}
			return unsafe { ClCommandQueue(nil) }
		}
		cl_create_command_queue_with_properties_sym = ClCreateCommandQueueWithPropertiesType(f)
	}
	return cl_create_command_queue_with_properties_sym(context, device, properties, errcode_ret)
}

type ClCreateCommandQueueType = fn (context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue

[inline]
fn cl_create_command_queue(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue {
	if cl_create_command_queue_sym == ClCreateCommandQueueType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clCreateCommandQueue') or {
			unsafe {
				*errcode_ret = dl_sym_opt_issue
			}
			return unsafe { ClCommandQueue(nil) }
		}
		cl_create_command_queue_sym = ClCreateCommandQueueType(f)
	}
	return cl_create_command_queue_sym(context, device, properties, errcode_ret)
}

type ClBuildProgramType = fn (program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr) int

[inline]
fn cl_build_program(program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr) int {
	if cl_build_program_sym == ClBuildProgramType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clBuildProgram') or { return dl_sym_opt_issue }
		cl_build_program_sym = ClBuildProgramType(f)
	}
	return cl_build_program_sym(program, num_devices, device_list, options, pfn_notify,
		user_data)
}

type ClGetProgramBuildInfoType = fn (program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int

[inline]
fn cl_get_program_build_info(program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int {
	if cl_get_program_build_info_sym == ClGetProgramBuildInfoType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clGetProgramBuildInfo') or { return dl_sym_opt_issue }
		cl_get_program_build_info_sym = ClGetProgramBuildInfoType(f)
	}
	return cl_get_program_build_info_sym(program, device, param_name, param_value_size,
		param_value, param_value_size_ret)
}

type ClCreateKernelType = fn (program ClProgram, kernel_name &char, errcode_ret &int) ClKernel

[inline]
fn cl_create_kernel(program ClProgram, kernel_name &char, errcode_ret &int) ClKernel {
	if cl_create_kernel_sym == ClCreateKernelType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clCreateKernel') or {
			unsafe {
				*errcode_ret = dl_sym_opt_issue
			}
			return unsafe { ClKernel(nil) }
		}
		cl_create_kernel_sym = ClCreateKernelType(f)
	}
	return cl_create_kernel_sym(program, kernel_name, errcode_ret)
}

type ClReleaseKernelType = fn (kernel ClKernel) int

[inline]
fn cl_release_kernel(kernel ClKernel) int {
	if cl_release_kernel_sym == ClReleaseKernelType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clReleaseKernel') or { return dl_sym_opt_issue }
		cl_release_kernel_sym = ClReleaseKernelType(f)
	}
	return cl_release_kernel_sym(kernel)
}

type ClSetKernelArgType = fn (kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr) int

[inline]
fn cl_set_kernel_arg(kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr) int {
	if cl_set_kernel_arg_sym == ClSetKernelArgType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clSetKernelArg') or { return dl_sym_opt_issue }
		cl_set_kernel_arg_sym = ClSetKernelArgType(f)
	}
	return cl_set_kernel_arg_sym(kernel, arg_index, arg_size, arg_value)
}

type ClEnqueueNDRangeKernelType = fn (command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_nd_range_kernel(command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	if cl_enqueue_n_d_range_kernel_sym == ClEnqueueNDRangeKernelType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clEnqueueNDRangeKernel') or { return dl_sym_opt_issue }
		cl_enqueue_n_d_range_kernel_sym = ClEnqueueNDRangeKernelType(f)
	}
	return cl_enqueue_n_d_range_kernel_sym(command_queue, kernel, work_dim, global_work_offset,
		global_work_size, local_work_size, num_events_in_wait_list, event_wait_list, event)
}

type ClGetPlatformIDsType = fn (num_entries u32, platforms &ClPlatformId, num_platforms &u32) int

[inline]
fn cl_get_platform_i_ds(num_entries u32, platforms &ClPlatformId, num_platforms &u32) int {
	if cl_get_platform_i_ds_sym == ClGetPlatformIDsType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clGetPlatformIDs') or { return dl_sym_opt_issue }
		cl_get_platform_i_ds_sym = ClGetPlatformIDsType(f)
	}
	return cl_get_platform_i_ds_sym(num_entries, platforms, num_platforms)
}

type ClCreateContextType = fn (properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int) ClContext

[inline]
fn cl_create_context(properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int) ClContext {
	if cl_create_context_sym == ClCreateContextType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clCreateContext') or {
			unsafe {
				*errcode_ret = dl_sym_opt_issue
			}
			return unsafe { ClContext(nil) }
		}
		cl_create_context_sym = ClCreateContextType(f)
	}
	return cl_create_context_sym(properties, num_devices, devices, pfn_notify, user_data,
		errcode_ret)
}

type ClCreateImageType = fn (context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int) ClMem

[inline]
fn cl_create_image(context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int) ClMem {
	if cl_create_image_sym == ClCreateImageType(unsafe { nil }) {
		f := dl.sym_opt(handle, 'clCreateImage') or {
			unsafe {
				*errcode_ret = dl_sym_opt_issue
			}
			return unsafe { ClMem(nil) }
		}
		cl_create_image_sym = ClCreateImageType(f)
	}
	return cl_create_image_sym(context, flags, format, desc, data, errcode_ret)
}
