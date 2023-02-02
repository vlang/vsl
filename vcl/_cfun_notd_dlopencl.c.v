module vcl

fn C.clCreateBuffer(context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int) ClMem
[inline]
fn cl_create_buffer(context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int) ClMem {
	return C.clCreateBuffer(context, flags, size, host_ptr, errcode_ret)
}

fn C.clReleaseMemObject(memobj ClMem) int
[inline]
fn cl_release_mem_object(memobj ClMem) int {
	return C.clReleaseMemObject(memobj)
}

fn C.clEnqueueWriteBuffer(command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int
[inline]
fn cl_enqueue_write_buffer(command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	return C.clEnqueueWriteBuffer(command_queue, buffer, blocking_write, offset, cb, ptr,
		num_events_in_wait_list, event_wait_list, event)
}

fn C.clReleaseEvent(event ClEvent) int
[inline]
fn cl_release_event(event ClEvent) int {
	return C.clReleaseEvent(event)
}

fn C.clWaitForEvents(num_events u32, event_list &ClEvent) int
[inline]
fn cl_wait_for_events(num_events u32, event_list &ClEvent) int {
	return C.clWaitForEvents(num_events, event_list)
}

fn C.clEnqueueReadBuffer(command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int
[inline]
fn cl_enqueue_read_buffer(command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	return C.clEnqueueReadBuffer(command_queue, buffer, blocking_read, offset, cb, ptr,
		num_events_in_wait_list, event_wait_list, event)
}

fn C.clReleaseProgram(program ClProgram) int
[inline]
fn cl_release_program(program ClProgram) int {
	return C.clReleaseProgram(program)
}

fn C.clReleaseCommandQueue(command_queue ClCommandQueue) int
[inline]
fn cl_release_command_queue(command_queue ClCommandQueue) int {
	return C.clReleaseCommandQueue(command_queue)
}

fn C.clReleaseContext(context ClContext) int
[inline]
fn cl_release_context(context ClContext) int {
	return C.clReleaseContext(context)
}

fn C.clReleaseDevice(device ClDeviceId) int
[inline]
fn cl_release_device(device ClDeviceId) int {
	return C.clReleaseDevice(device)
}

fn C.clGetDeviceInfo(device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int
[inline]
fn cl_get_device_info(device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int {
	return C.clGetDeviceInfo(device, param_name, param_value_size, param_value, param_value_size_ret)
}

fn C.clGetDeviceIDs(platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32) int
[inline]
fn cl_get_device_i_ds(platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32) int {
	return C.clGetDeviceIDs(platform, device_type, num_entries, devices, num_devices)
}

fn C.clCreateProgramWithSource(context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int) ClProgram
[inline]
fn cl_create_program_with_source(context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int) ClProgram {
	return C.clCreateProgramWithSource(context, count, strings, lengths, errcode_ret)
}

fn C.clCreateCommandQueueWithProperties(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue
[inline]
fn cl_create_command_queue_with_properties(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue {
	return C.clCreateCommandQueueWithProperties(context, device, properties, errcode_ret)
}

fn C.clCreateCommandQueue(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue
[inline]
fn cl_create_command_queue(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue {
	return C.clCreateCommandQueue(context, device, properties, errcode_ret)
}

fn C.clBuildProgram(program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr) int
[inline]
fn cl_build_program(program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr) int {
	return C.clBuildProgram(program, num_devices, device_list, options, pfn_notify, user_data)
}

fn C.clGetProgramBuildInfo(program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int
[inline]
fn cl_get_program_build_info(program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int {
	return C.clGetProgramBuildInfo(program, device, param_name, param_value_size, param_value,
		param_value_size_ret)
}

fn C.clCreateKernel(program ClProgram, kernel_name &char, errcode_ret &int) ClKernel
[inline]
fn cl_create_kernel(program ClProgram, kernel_name &char, errcode_ret &int) ClKernel {
	return C.clCreateKernel(program, kernel_name, errcode_ret)
}

fn C.clReleaseKernel(kernel ClKernel) int
[inline]
fn cl_release_kernel(kernel ClKernel) int {
	return C.clReleaseKernel(kernel)
}

fn C.clSetKernelArg(kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr) int
[inline]
fn cl_set_kernel_arg(kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr) int {
	return C.clSetKernelArg(kernel, arg_index, arg_size, arg_value)
}

fn C.clEnqueueNDRangeKernel(command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int
[inline]
fn cl_enqueue_nd_range_kernel(command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	return C.clEnqueueNDRangeKernel(command_queue, kernel, work_dim, global_work_offset,
		global_work_size, local_work_size, num_events_in_wait_list, event_wait_list, event)
}

fn C.clGetPlatformIDs(num_entries u32, platforms &ClPlatformId, num_platforms &u32) int
[inline]
fn cl_get_platform_i_ds(num_entries u32, platforms &ClPlatformId, num_platforms &u32) int {
	return C.clGetPlatformIDs(num_entries, platforms, num_platforms)
}

fn C.clCreateContext(properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int) ClContext
[inline]
fn cl_create_context(properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int) ClContext {
	return C.clCreateContext(properties, num_devices, devices, pfn_notify, user_data,
		errcode_ret)
}

fn C.clCreateImage2D(context ClContext, flags ClMemFlags, format &ClImageFormat, width usize, height usize, row_pitch usize, data voidptr, errcode_ret &int) ClMem
[inline]
fn cl_create_image2d(context ClContext, flags ClMemFlags, format &ClImageFormat, width usize, height usize, row_pitch usize, data voidptr, errcode_ret &int) ClMem {
	return C.clCreateImage2D(context, flags, format, width, height, row_pitch, data, errcode_ret)
}

fn C.clEnqueueReadImage(command_queue ClCommandQueue, image ClMem, blocking_read bool, origin3 [3]usize, region3 [3]usize, row_pitch usize, slice_pitch usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int
[inline]
fn cl_enqueue_read_image(command_queue ClCommandQueue, image ClMem, blocking_read bool, origin3 [3]usize, region3 [3]usize, row_pitch usize, slice_pitch usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	return C.clEnqueueReadImage(command_queue, image, blocking_read, origin3, region3,
		row_pitch, slice_pitch, ptr, num_events_in_wait_list, event_wait_list, event)
}

fn C.clEnqueueWriteImage(command_queue ClCommandQueue, image ClMem, blocking_write bool, origin3 [3]usize, region3 [3]usize, row_pitch usize, slice_pitch usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int
[inline]
fn cl_enqueue_write_image(command_queue ClCommandQueue, image ClMem, blocking_write bool, origin3 [3]usize, region3 [3]usize, row_pitch usize, slice_pitch usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int {
	return C.clEnqueueWriteImage(command_queue, image, blocking_write, origin3, region3,
		row_pitch, slice_pitch, ptr, num_events_in_wait_list, event_wait_list, event)
}
