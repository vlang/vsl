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
	bug = // fix me
	bug2 = // fix me
)
type clCreateBuffer_type = fn (context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int)
fn clCreateBuffer(context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int)  ClMem {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateBuffer') or {return bug2}
		return (clCreateBuffer_type(f))(context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int)
}
}$else {return C.clCreateBuffer(context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int)}

type clReleaseMemObject_type = fn (memobj ClMem)
fn clReleaseMemObject(memobj ClMem)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseMemObject') or {return bug2}
		return (clReleaseMemObject_type(f))(memobj ClMem)
}
}$else {return C.clReleaseMemObject(memobj ClMem)}

type clEnqueueWriteBuffer_type = fn (command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)
fn clEnqueueWriteBuffer(command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clEnqueueWriteBuffer') or {return bug2}
		return (clEnqueueWriteBuffer_type(f))(command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)
}
}$else {return C.clEnqueueWriteBuffer(command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)}

type clReleaseEvent_type = fn (event ClEvent)
fn clReleaseEvent(event ClEvent)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseEvent') or {return bug2}
		return (clReleaseEvent_type(f))(event ClEvent)
}
}$else {return C.clReleaseEvent(event ClEvent)}

type clWaitForEvents_type = fn (num_events u32, event_list &ClEvent)
fn clWaitForEvents(num_events u32, event_list &ClEvent)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clWaitForEvents') or {return bug2}
		return (clWaitForEvents_type(f))(num_events u32, event_list &ClEvent)
}
}$else {return C.clWaitForEvents(num_events u32, event_list &ClEvent)}

type clEnqueueReadBuffer_type = fn (command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)
fn clEnqueueReadBuffer(command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clEnqueueReadBuffer') or {return bug2}
		return (clEnqueueReadBuffer_type(f))(command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)
}
}$else {return C.clEnqueueReadBuffer(command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)}

type clReleaseProgram_type = fn (program ClProgram)
fn clReleaseProgram(program ClProgram)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseProgram') or {return bug2}
		return (clReleaseProgram_type(f))(program ClProgram)
}
}$else {return C.clReleaseProgram(program ClProgram)}

type clReleaseCommandQueue_type = fn (command_queue ClCommandQueue)
fn clReleaseCommandQueue(command_queue ClCommandQueue)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseCommandQueue') or {return bug2}
		return (clReleaseCommandQueue_type(f))(command_queue ClCommandQueue)
}
}$else {return C.clReleaseCommandQueue(command_queue ClCommandQueue)}

type clReleaseContext_type = fn (context ClContext)
fn clReleaseContext(context ClContext)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseContext') or {return bug2}
		return (clReleaseContext_type(f))(context ClContext)
}
}$else {return C.clReleaseContext(context ClContext)}

type clReleaseDevice_type = fn (device ClDeviceId)
fn clReleaseDevice(device ClDeviceId)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseDevice') or {return bug2}
		return (clReleaseDevice_type(f))(device ClDeviceId)
}
}$else {return C.clReleaseDevice(device ClDeviceId)}

type clGetDeviceInfo_type = fn (device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize)
fn clGetDeviceInfo(device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clGetDeviceInfo') or {return bug2}
		return (clGetDeviceInfo_type(f))(device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize)
}
}$else {return C.clGetDeviceInfo(device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize)}

type clGetDeviceIDs_type = fn (platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32)
fn clGetDeviceIDs(platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clGetDeviceIDs') or {return bug2}
		return (clGetDeviceIDs_type(f))(platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32)
}
}$else {return C.clGetDeviceIDs(platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32)}

type clCreateProgramWithSource_type = fn (context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int)
fn clCreateProgramWithSource(context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int)  ClProgram {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateProgramWithSource') or {return bug2}
		return (clCreateProgramWithSource_type(f))(context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int)
}
}$else {return C.clCreateProgramWithSource(context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int)}

type clCreateCommandQueueWithProperties_type = fn (context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int)
fn clCreateCommandQueueWithProperties(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int)  ClCommandQueue {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateCommandQueueWithProperties') or {return bug2}
		return (clCreateCommandQueueWithProperties_type(f))(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int)
}
}$else {return C.clCreateCommandQueueWithProperties(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int)}

type clCreateCommandQueue_type = fn (context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int)
fn clCreateCommandQueue(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int)  ClCommandQueue {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateCommandQueue') or {return bug2}
		return (clCreateCommandQueue_type(f))(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int)
}
}$else {return C.clCreateCommandQueue(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int)}

type clBuildProgram_type = fn (program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr)
fn clBuildProgram(program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clBuildProgram') or {return bug2}
		return (clBuildProgram_type(f))(program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr)
}
}$else {return C.clBuildProgram(program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr)}

type clGetProgramBuildInfo_type = fn (program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize)
fn clGetProgramBuildInfo(program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clGetProgramBuildInfo') or {return bug2}
		return (clGetProgramBuildInfo_type(f))(program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize)
}
}$else {return C.clGetProgramBuildInfo(program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize)}

type clCreateKernel_type = fn (program ClProgram, kernel_name &char, errcode_ret &int)
fn clCreateKernel(program ClProgram, kernel_name &char, errcode_ret &int)  ClKernel {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateKernel') or {return bug2}
		return (clCreateKernel_type(f))(program ClProgram, kernel_name &char, errcode_ret &int)
}
}$else {return C.clCreateKernel(program ClProgram, kernel_name &char, errcode_ret &int)}

type clReleaseKernel_type = fn (kernel ClKernel)
fn clReleaseKernel(kernel ClKernel)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clReleaseKernel') or {return bug2}
		return (clReleaseKernel_type(f))(kernel ClKernel)
}
}$else {return C.clReleaseKernel(kernel ClKernel)}

type clSetKernelArg_type = fn (kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr)
fn clSetKernelArg(kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clSetKernelArg') or {return bug2}
		return (clSetKernelArg_type(f))(kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr)
}
}$else {return C.clSetKernelArg(kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr)}

type clEnqueueNDRangeKernel_type = fn (command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)
fn clEnqueueNDRangeKernel(command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clEnqueueNDRangeKernel') or {return bug2}
		return (clEnqueueNDRangeKernel_type(f))(command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)
}
}$else {return C.clEnqueueNDRangeKernel(command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent)}

type clGetPlatformIDs_type = fn (num_entries u32, platforms &ClPlatformId, num_platforms &u32)
fn clGetPlatformIDs(num_entries u32, platforms &ClPlatformId, num_platforms &u32)  int {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clGetPlatformIDs') or {return bug2}
		return (clGetPlatformIDs_type(f))(num_entries u32, platforms &ClPlatformId, num_platforms &u32)
}
}$else {return C.clGetPlatformIDs(num_entries u32, platforms &ClPlatformId, num_platforms &u32)}

type clCreateContext_type = fn (properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int)
fn clCreateContext(properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int)  ClContext {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateContext') or {return bug2}
		return (clCreateContext_type(f))(properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int)
}
}$else {return C.clCreateContext(properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int)}

type clCreateImage_type = fn (context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int)
fn clCreateImage(context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int)  ClMem {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateImage') or {return bug2}
		return (clCreateImage_type(f))(context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int)
}
}$else {return C.clCreateImage(context ClContext, flags ClMemFlags, format &ClImageFormat, desc ClImageDesc, data voidptr, errcode_ret &int)}

type create_image_desc_type = fn (image_type ClMemObjectType, image_width usize, image_height usize, image_depth usize, image_array_size usize, image_row_pitch usize, image_slice_pitch usize, num_mip_levels u32, num_samples u32, buffer ClMem)
fn create_image_desc(image_type ClMemObjectType, image_width usize, image_height usize, image_depth usize, image_array_size usize, image_row_pitch usize, image_slice_pitch usize, num_mip_levels u32, num_samples u32, buffer ClMem)  &ClImageDesc {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'create_image_desc') or {return bug2}
		return (create_image_desc_type(f))(image_type ClMemObjectType, image_width usize, image_height usize, image_depth usize, image_array_size usize, image_row_pitch usize, image_slice_pitch usize, num_mip_levels u32, num_samples u32, buffer ClMem)
}
}$else {return C.create_image_desc(image_type ClMemObjectType, image_width usize, image_height usize, image_depth usize, image_array_size usize, image_row_pitch usize, image_slice_pitch usize, num_mip_levels u32, num_samples u32, buffer ClMem)}

type create_image_format_type = fn (image_channel_order usize, image_channel_data_type usize)
fn create_image_format(image_channel_order usize, image_channel_data_type usize)  &ClImageFormat {
	$if shared_mode?{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'create_image_format') or {return bug2}
		return (create_image_format_type(f))(image_channel_order usize, image_channel_data_type usize)
}
}$else {return C.create_image_format(image_channel_order usize, image_channel_data_type usize)}

