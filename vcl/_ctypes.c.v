module vcl

type ClPlatformId = voidptr
type ClDeviceId = voidptr
type ClContext = voidptr
type ClContextProperties = voidptr
type ClCommandQueue = voidptr
type ClMem = voidptr
type ClProgram = voidptr
type ClKernel = voidptr
type ClEvent = voidptr
type ClSampler = voidptr

type ClMemFlags = u64
type ClDeviceType = u64
type ClDeviceInfo = u32
type ClProperties = u64
type ClQueueProperties = u64
type ClProgramBuildInfo = u32


// ImageChannelOrder represents available image types
pub enum ImageChannelOrder {
	intensity = C.CL_INTENSITY
	rgba = C.CL_RGBA
}

// ImageChannelDataType describes the size of the channel data type
pub enum ImageChannelDataType {
	unorm_int8 = C.CL_UNORM_INT8
}

type ClMemObjectType = int
type ClImageDesc = voidptr
type ClImageFormat = voidptr


// converted
fn dl_get_opened() !voidptr{
	parts := $if linux||gnu{[]}$else $if windows{[]}$else $if mac||macos{[]}$else $if android{[]}$else{[]}//fix me give locations
	for i := 0; i < paths.len; i++ {
		handle := dl.open_opt(paths[i]) or {continue}
		return handle}
	return error("dl_get_opened")
}
fn my_dl_close(library voidptr){dl.close(library)}
const(
	bug = not_found_shared// fix me
	bug2 = not_found_symbol// fix me
)
$if shared_library ? {
	type clCreateBuffer_type = fn (context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int)  ClMem
	fn clCreateBuffer(context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int)  ClMem {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateBuffer') or {return bug2}
		return (clCreateBuffer_type(f))(context, flags, size, host_ptr, errcode_ret)
	}

	type clReleaseMemObject_type = fn (memobj ClMem)  int
	fn clReleaseMemObject(memobj ClMem)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseMemObject') or {return bug2}
		return (clReleaseMemObject_type(f))(memobj)
	}

	type clEnqueueWriteBuffer_type = fn (command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)  int
	fn clEnqueueWriteBuffer(command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clEnqueueWriteBuffer') or {return bug2}
		return (clEnqueueWriteBuffer_type(f))(command_queue, buffer, blocking_write, offset, cb, ptr, num_events_in_wait_list, event_wait_list, event)
	}

	type clReleaseEvent_type = fn (event ClEvent)  int
	fn clReleaseEvent(event ClEvent)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseEvent') or {return bug2}
		return (clReleaseEvent_type(f))(event)
	}

	type clWaitForEvents_type = fn (num_events u32, event_list &ClEvent)  int
	fn clWaitForEvents(num_events u32, event_list &ClEvent)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clWaitForEvents') or {return bug2}
		return (clWaitForEvents_type(f))(num_events, event_list)
	}

	type clEnqueueReadBuffer_type = fn (command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)  int
	fn clEnqueueReadBuffer(command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clEnqueueReadBuffer') or {return bug2}
		return (clEnqueueReadBuffer_type(f))(command_queue, buffer, blocking_read, offset, cb, ptr, num_events_in_wait_list, event_wait_list, event)
	}

	type clReleaseProgram_type = fn (program ClProgram)  int
	fn clReleaseProgram(program ClProgram)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseProgram') or {return bug2}
		return (clReleaseProgram_type(f))(program)
	}

	type clReleaseCommandQueue_type = fn (command_queue ClCommandQueue)  int
	fn clReleaseCommandQueue(command_queue ClCommandQueue)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseCommandQueue') or {return bug2}
		return (clReleaseCommandQueue_type(f))(command_queue)
	}

	type clReleaseContext_type = fn (context ClContext)  int
	fn clReleaseContext(context ClContext)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseContext') or {return bug2}
		return (clReleaseContext_type(f))(context)
	}

	type clReleaseDevice_type = fn (device ClDeviceId)  int
	fn clReleaseDevice(device ClDeviceId)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseDevice') or {return bug2}
		return (clReleaseDevice_type(f))(device)
	}

	type clGetDeviceInfo_type = fn (device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize)  int
	fn clGetDeviceInfo(device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clGetDeviceInfo') or {return bug2}
		return (clGetDeviceInfo_type(f))(device, param_name, param_value_size, param_value, param_value_size_ret)
	}

	type clGetDeviceIDs_type = fn (platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32)  int
	fn clGetDeviceIDs(platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clGetDeviceIDs') or {return bug2}
		return (clGetDeviceIDs_type(f))(platform, device_type, num_entries, devices, num_devices)
	}

	type clCreateProgramWithSource_type = fn (context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int)  ClProgram
	fn clCreateProgramWithSource(context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int)  ClProgram {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateProgramWithSource') or {return bug2}
		return (clCreateProgramWithSource_type(f))(context, count, strings, lengths, errcode_ret)
	}

	type clCreateCommandQueueWithProperties_type = fn (context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int)  ClCommandQueue
	fn clCreateCommandQueueWithProperties(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int)  ClCommandQueue {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateCommandQueueWithProperties') or {return bug2}
		return (clCreateCommandQueueWithProperties_type(f))(context, device, properties, errcode_ret)
	}

	type clCreateCommandQueue_type = fn (context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int)  ClCommandQueue
	fn clCreateCommandQueue(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int)  ClCommandQueue {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateCommandQueue') or {return bug2}
		return (clCreateCommandQueue_type(f))(context, device, properties, errcode_ret)
	}

	type clBuildProgram_type = fn (program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr)  int
	fn clBuildProgram(program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clBuildProgram') or {return bug2}
		return (clBuildProgram_type(f))(program, num_devices, device_list, options, pfn_notify, user_data)
	}

	type clGetProgramBuildInfo_type = fn (program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize)  int
	fn clGetProgramBuildInfo(program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clGetProgramBuildInfo') or {return bug2}
		return (clGetProgramBuildInfo_type(f))(program, device, param_name, param_value_size, param_value, param_value_size_ret)
	}

	type clCreateKernel_type = fn (program ClProgram, kernel_name &char, errcode_ret &int)  ClKernel
	fn clCreateKernel(program ClProgram, kernel_name &char, errcode_ret &int)  ClKernel {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateKernel') or {return bug2}
		return (clCreateKernel_type(f))(program, kernel_name, errcode_ret)
	}

	type clReleaseKernel_type = fn (kernel ClKernel)  int
	fn clReleaseKernel(kernel ClKernel)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseKernel') or {return bug2}
		return (clReleaseKernel_type(f))(kernel)
	}

	type clSetKernelArg_type = fn (kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr)  int
	fn clSetKernelArg(kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clSetKernelArg') or {return bug2}
		return (clSetKernelArg_type(f))(kernel, arg_index, arg_size, arg_value)
	}

	type clEnqueueNDRangeKernel_type = fn (command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)  int
	fn clEnqueueNDRangeKernel(command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clEnqueueNDRangeKernel') or {return bug2}
		return (clEnqueueNDRangeKernel_type(f))(command_queue, kernel, work_dim, global_work_offset, global_work_size, local_work_size, num_events_in_wait_list, event_wait_list, event)
	}

	type clGetPlatformIDs_type = fn (num_entries u32, platforms &ClPlatformId, num_platforms &u32)  int
	fn clGetPlatformIDs(num_entries u32, platforms &ClPlatformId, num_platforms &u32)  int {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clGetPlatformIDs') or {return bug2}
		return (clGetPlatformIDs_type(f))(num_entries, platforms, num_platforms)
	}

	type clCreateContext_type = fn (properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int)  ClContext
	fn clCreateContext(properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int)  ClContext {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateContext') or {return bug2}
		return (clCreateContext_type(f))(properties, num_devices, devices, pfn_notify, user_data, errcode_ret)
	}

	type clCreateImage_type = fn (context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int)  ClMem
	fn clCreateImage(context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int)  ClMem {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateImage') or {return bug2}
		return (clCreateImage_type(f))(context, flags, format, desc, data, errcode_ret)
	}

	type create_image_desc_type = fn (image_type ClMemObjectType, image_width usize, image_height usize, image_depth usize, image_array_size usize, image_row_pitch usize, image_slice_pitch usize, num_mip_levels u32, num_samples u32, buffer ClMem)  &ClImageDesc
	fn create_image_desc(image_type ClMemObjectType, image_width usize, image_height usize, image_depth usize, image_array_size usize, image_row_pitch usize, image_slice_pitch usize, num_mip_levels u32, num_samples u32, buffer ClMem)  &ClImageDesc {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'create_image_desc') or {return bug2}
		return (create_image_desc_type(f))(image_type, image_width, image_height, image_depth, image_array_size, image_row_pitch, image_slice_pitch, num_mip_levels, num_samples, buffer)
	}

	type create_image_format_type = fn (image_channel_order usize, image_channel_data_type usize)  &ClImageFormat
	fn create_image_format(image_channel_order usize, image_channel_data_type usize)  &ClImageFormat {
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'create_image_format') or {return bug2}
		return (create_image_format_type(f))(image_channel_order, image_channel_data_type)
	}

}$else{
	fn C.clCreateBuffer(context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int) ClMem
	type clCreateBuffer = C.clCreateBuffer

	fn C.clReleaseMemObject(memobj ClMem) int
	type clReleaseMemObject = C.clReleaseMemObject

	fn C.clEnqueueWriteBuffer(command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int
	type clEnqueueWriteBuffer = C.clEnqueueWriteBuffer

	fn C.clReleaseEvent(event ClEvent) int
	type clReleaseEvent = C.clReleaseEvent

	fn C.clWaitForEvents(num_events u32, event_list &ClEvent) int
	type clWaitForEvents = C.clWaitForEvents

	fn C.clEnqueueReadBuffer(command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int
	type clEnqueueReadBuffer = C.clEnqueueReadBuffer

	fn C.clReleaseProgram(program ClProgram) int
	type clReleaseProgram = C.clReleaseProgram

	fn C.clReleaseCommandQueue(command_queue ClCommandQueue) int
	type clReleaseCommandQueue = C.clReleaseCommandQueue

	fn C.clReleaseContext(context ClContext) int
	type clReleaseContext = C.clReleaseContext

	fn C.clReleaseDevice(device ClDeviceId) int
	type clReleaseDevice = C.clReleaseDevice

	fn C.clGetDeviceInfo(device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int
	type clGetDeviceInfo = C.clGetDeviceInfo

	fn C.clGetDeviceIDs(platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32) int
	type clGetDeviceIDs = C.clGetDeviceIDs

	fn C.clCreateProgramWithSource(context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int) ClProgram
	type clCreateProgramWithSource = C.clCreateProgramWithSource

	fn C.clCreateCommandQueueWithProperties(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue
	type clCreateCommandQueueWithProperties = C.clCreateCommandQueueWithProperties

	fn C.clCreateCommandQueue(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue
	type clCreateCommandQueue = C.clCreateCommandQueue

	fn C.clBuildProgram(program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr) int
	type clBuildProgram = C.clBuildProgram

	fn C.clGetProgramBuildInfo(program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int
	type clGetProgramBuildInfo = C.clGetProgramBuildInfo

	fn C.clCreateKernel(program ClProgram, kernel_name &char, errcode_ret &int) ClKernel
	type clCreateKernel = C.clCreateKernel

	fn C.clReleaseKernel(kernel ClKernel) int
	type clReleaseKernel = C.clReleaseKernel

	fn C.clSetKernelArg(kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr) int
	type clSetKernelArg = C.clSetKernelArg

	fn C.clEnqueueNDRangeKernel(command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int
	type clEnqueueNDRangeKernel = C.clEnqueueNDRangeKernel

	fn C.clGetPlatformIDs(num_entries u32, platforms &ClPlatformId, num_platforms &u32) int
	type clGetPlatformIDs = C.clGetPlatformIDs

	fn C.clCreateContext(properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int) ClContext
	type clCreateContext = C.clCreateContext

	fn C.clCreateImage(context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int) ClMem
	type clCreateImage = C.clCreateImage

	fn C.create_image_desc(image_type ClMemObjectType, image_width usize, image_height usize, image_depth usize, image_array_size usize, image_row_pitch usize, image_slice_pitch usize, num_mip_levels u32, num_samples u32, buffer ClMem) &ClImageDesc
	type create_image_desc = C.create_image_desc

	fn C.create_image_format(image_channel_order usize, image_channel_data_type usize) &ClImageFormat
	type create_image_format = C.create_image_format

}
