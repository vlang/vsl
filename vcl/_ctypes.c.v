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
type ClImageFormat = voidptr
type ClImageDesc = voidptr

type ClMemFlags = u64
type ClDeviceType = u64
type ClDeviceInfo = u32
type ClProperties = u64
type ClQueueProperties = u64
type ClProgramBuildInfo = u32

fn C.clCreateBuffer(context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int) ClMem
fn C.clReleaseMemObject(memobj ClMem) int
fn C.clEnqueueWriteBuffer(command_queue ClCommandQueue, buffer ClMem, blocking_write bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int
fn C.clReleaseEvent(event ClEvent) int
fn C.clWaitForEvents(num_events u32, event_list &ClEvent) int
fn C.clEnqueueReadBuffer(command_queue ClCommandQueue, buffer ClMem, blocking_read bool, offset usize, cb usize, ptr voidptr, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int
fn C.clReleaseProgram(program ClProgram) int
fn C.clReleaseCommandQueue(command_queue ClCommandQueue) int
fn C.clReleaseContext(context ClContext) int
fn C.clReleaseDevice(device ClDeviceId) int
fn C.clGetDeviceInfo(device ClDeviceId, param_name ClDeviceInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int
fn C.clGetDeviceIDs(platform ClPlatformId, device_type ClDeviceType, num_entries u32, devices &ClDeviceId, num_devices &u32) int
fn C.clCreateProgramWithSource(context ClContext, count u32, strings &&char, lengths &usize, errcode_ret &int) ClProgram
fn C.clCreateCommandQueueWithProperties(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue
fn C.clCreateCommandQueue(context ClContext, device ClDeviceId, properties &ClQueueProperties, errcode_ret &int) ClCommandQueue
fn C.clBuildProgram(program ClProgram, num_devices u32, device_list &ClDeviceId, options &char, pfn_notify voidptr, user_data voidptr) int
fn C.clGetProgramBuildInfo(program ClProgram, device ClDeviceId, param_name ClProgramBuildInfo, param_value_size usize, param_value voidptr, param_value_size_ret &usize) int
fn C.clCreateKernel(program ClProgram, kernel_name &char, errcode_ret &int) ClKernel
fn C.clReleaseKernel(kernel ClKernel) int
fn C.clSetKernelArg(kernel ClKernel, arg_index u32, arg_size usize, arg_value voidptr) int
fn C.clEnqueueNDRangeKernel(command_queue ClCommandQueue, kernel ClKernel, work_dim u32, global_work_offset &usize, global_work_size &usize, local_work_size &usize, num_events_in_wait_list u32, event_wait_list &ClEvent, event &ClEvent) int
fn C.clGetPlatformIDs(num_entries u32, platforms &ClPlatformId, num_platforms &u32) int
fn C.clCreateContext(properties &ClContextProperties, num_devices u32, devices &ClDeviceId, pfn_notify voidptr, user_data voidptr, errcode_ret &int) ClContext
