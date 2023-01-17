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
	} $else $if android || termux{
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

type ClCreateBufferType = fn (context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int) ClMem

[inline]
fn cl_create_buffer(context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int) ClMem {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clCreateBuffer') or { return vcl.dl_sym_opt_issue }
	sfn := ClCreateBufferType(f)
	return sfn(context, flags, size, host_ptr, errcode_ret)
}

type ClReleaseMemObjectType = fn (memobj ClMem) int

[inline]
fn cl_release_mem_object(memobj ClMem) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clReleaseMemObject') or { return vcl.dl_sym_opt_issue }
	sfn := ClReleaseMemObjectType(f)
	return sfn(memobj)
}

type ClEnqueueWriteBufferType = fn (command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_write_buffer(command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clEnqueueWriteBuffer') or { return vcl.dl_sym_opt_issue }
	sfn := ClEnqueueWriteBufferType(f)
	return sfn(command_queue, buffer, blocking_write, offset, cb, ptr, num_events_in_wait_list,
		event_wait_list, event)
}

type ClReleaseEventType = fn (event ClEvent) int

[inline]
fn cl_release_event(event ClEvent) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clReleaseEvent') or { return vcl.dl_sym_opt_issue }
	sfn := ClReleaseEventType(f)
	return sfn(event)
}

type ClWaitForEventsType = fn (num_events u32, event_list &ClEvent) int

[inline]
fn cl_wait_for_events(num_events u32, event_list &ClEvent) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clWaitForEvents') or { return vcl.dl_sym_opt_issue }
	sfn := ClWaitForEventsType(f)
	return sfn(num_events, event_list)
}

type ClEnqueueReadBufferType = fn (command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_read_buffer(command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clEnqueueReadBuffer') or { return vcl.dl_sym_opt_issue }
	sfn := ClEnqueueReadBufferType(f)
	return sfn(command_queue, buffer, blocking_read, offset, cb, ptr, num_events_in_wait_list,
		event_wait_list, event)
}

type ClReleaseProgramType = fn (program ClProgram) int

[inline]
fn cl_release_program(program ClProgram) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clReleaseProgram') or { return vcl.dl_sym_opt_issue }
	sfn := ClReleaseProgramType(f)
	return sfn(program)
}

type ClReleaseCommandQueueType = fn (command_queue ClCommandQueue) int

[inline]
fn cl_release_command_queue(command_queue ClCommandQueue) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clReleaseCommandQueue') or { return vcl.dl_sym_opt_issue }
	sfn := ClReleaseCommandQueueType(f)
	return sfn(command_queue)
}

type ClReleaseContextType = fn (context ClContext) int

[inline]
fn cl_release_context(context ClContext) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clReleaseContext') or { return vcl.dl_sym_opt_issue }
	sfn := ClReleaseContextType(f)
	return sfn(context)
}

type ClReleaseDeviceType = fn (device ClDeviceId) int

[inline]
fn cl_release_device(device ClDeviceId) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clReleaseDevice') or { return vcl.dl_sym_opt_issue }
	sfn := ClReleaseDeviceType(f)
	return sfn(device)
}

type ClGetDeviceInfoType = fn (device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int

[inline]
fn cl_get_device_info(device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clGetDeviceInfo') or { return vcl.dl_sym_opt_issue }
	sfn := ClGetDeviceInfoType(f)
	return sfn(device, param_name, param_value_size, param_value, param_value_size_ret)
}

type ClGetDeviceIDsType = fn (platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32) int

[inline]
fn cl_get_device_i_ds(platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clGetDeviceIDs') or { return vcl.dl_sym_opt_issue }
	sfn := ClGetDeviceIDsType(f)
	return sfn(platform, device_type, num_entries, devices, num_devices)
}

type ClCreateProgramWithSourceType = fn (context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int) ClProgram

[inline]
fn cl_create_program_with_source(context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int) ClProgram {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clCreateProgramWithSource') or { return vcl.dl_sym_opt_issue }
	sfn := ClCreateProgramWithSourceType(f)
	return sfn(context, count, strings, lengths, errcode_ret)
}

type ClCreateCommandQueueWithPropertiesType = fn (context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue

[inline]
fn cl_create_command_queue_with_properties(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clCreateCommandQueueWithProperties') or { return vcl.dl_sym_opt_issue }
	sfn := ClCreateCommandQueueWithPropertiesType(f)
	return sfn(context, device, properties, errcode_ret)
}

type ClCreateCommandQueueType = fn (context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue

[inline]
fn cl_create_command_queue(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clCreateCommandQueue') or { return vcl.dl_sym_opt_issue }
	sfn := ClCreateCommandQueueType(f)
	return sfn(context, device, properties, errcode_ret)
}

type ClBuildProgramType = fn (program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr) int

[inline]
fn cl_build_program(program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clBuildProgram') or { return vcl.dl_sym_opt_issue }
	sfn := ClBuildProgramType(f)
	return sfn(program, num_devices, device_list, options, pfn_notify, user_data)
}

type ClGetProgramBuildInfoType = fn (program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int

[inline]
fn cl_get_program_build_info(program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clGetProgramBuildInfo') or { return vcl.dl_sym_opt_issue }
	sfn := ClGetProgramBuildInfoType(f)
	return sfn(program, device, param_name, param_value_size, param_value, param_value_size_ret)
}

type ClCreateKernelType = fn (program ClProgram, kernel_name &char, errcode_ret &int) ClKernel

[inline]
fn cl_create_kernel(program ClProgram, kernel_name &char, errcode_ret &int) ClKernel {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clCreateKernel') or { return vcl.dl_sym_opt_issue }
	sfn := ClCreateKernelType(f)
	return sfn(program, kernel_name, errcode_ret)
}

type ClReleaseKernelType = fn (kernel ClKernel) int

[inline]
fn cl_release_kernel(kernel ClKernel) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clReleaseKernel') or { return vcl.dl_sym_opt_issue }
	sfn := ClReleaseKernelType(f)
	return sfn(kernel)
}

type ClSetKernelArgType = fn (kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr) int

[inline]
fn cl_set_kernel_arg(kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clSetKernelArg') or { return vcl.dl_sym_opt_issue }
	sfn := ClSetKernelArgType(f)
	return sfn(kernel, arg_index, arg_size, arg_value)
}

type ClEnqueueNDRangeKernelType = fn (command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int

[inline]
fn cl_enqueue_nd_range_kernel(command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clEnqueueNDRangeKernel') or { return vcl.dl_sym_opt_issue }
	sfn := ClEnqueueNDRangeKernelType(f)
	return sfn(command_queue, kernel, work_dim, global_work_offset, global_work_size,
		local_work_size, num_events_in_wait_list, event_wait_list, event)
}

type ClGetPlatformIDsType = fn (num_entries u32, platforms &ClPlatformId, num_platforms &u32) int

[inline]
fn cl_get_platform_i_ds(num_entries u32, platforms &ClPlatformId, num_platforms &u32) int {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clGetPlatformIDs') or { return vcl.dl_sym_opt_issue }
	sfn := ClGetPlatformIDsType(f)
	return sfn(num_entries, platforms, num_platforms)
}

type ClCreateContextType = fn (properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int) ClContext

[inline]
fn cl_create_context(properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int) ClContext {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clCreateContext') or { return vcl.dl_sym_opt_issue }
	sfn := ClCreateContextType(f)
	return sfn(properties, num_devices, devices, pfn_notify, user_data, errcode_ret)
}

type ClCreateImageType = fn (context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int) ClMem

[inline]
fn cl_create_image(context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int) ClMem {
	handle := dl_open() or { return vcl.dl_open_issue }
	defer {
		dl_close(handle)
	}
	f := dl.sym_opt(handle, 'clCreateImage') or { return vcl.dl_sym_opt_issue }
	sfn := ClCreateImageType(f)
	return sfn(context, flags, format, desc, data, errcode_ret)
}

fn C.create_image_desc(image_type ClMemObjectType, image_width usize, image_height usize, image_depth usize, image_array_size usize, image_row_pitch usize, image_slice_pitch usize, num_mip_levels u32, num_samples u32, buffer ClMem) &ClImageDesc
[inline]
fn create_image_desc(image_type ClMemObjectType, image_width usize, image_height usize, image_depth usize, image_array_size usize, image_row_pitch usize, image_slice_pitch usize, num_mip_levels u32, num_samples u32, buffer ClMem) &ClImageDesc {
	return C.create_image_desc(image_type, image_width, image_height, image_depth, image_array_size,
		image_row_pitch, image_slice_pitch, num_mip_levels, num_samples, buffer)
}

fn C.create_image_format(image_channel_order usize, image_channel_data_type usize) &ClImageFormat
[inline]
fn create_image_format(image_channel_order usize, image_channel_data_type usize) &ClImageFormat {
	return C.create_image_format(image_channel_order, image_channel_data_type)
}
