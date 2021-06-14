module vcl

// DeviceType is an enum of device types
pub enum DeviceType {
	cpu = C.CL_DEVICE_TYPE_CPU
	gpu = C.CL_DEVICE_TYPE_GPU
	accelerator = C.CL_DEVICE_TYPE_ACCELERATOR
	default_device = C.CL_DEVICE_TYPE_DEFAULT
	all = C.CL_DEVICE_TYPE_ALL
}

// Device the only needed entrence for the VCL
// represents the device on which memory can be allocated and kernels run
// it abstracts away all the complexity of contexts/platforms/queues
pub struct Device {
pub:
	id       C.cl_device_id
	ctx      C.cl_context
	queue    C.cl_command_queue
	programs []C.cl_program
}

// release releases the device
pub fn (mut d Device) release() ? {
	for p in d.programs {
		code := C.clReleaseProgram(p)
		if code != 0 {
			return vcl_error(code)
		}
	}
	mut code := C.clReleaseCommandQueue(d.queue)
	if code != 0 {
		return vcl_error(code)
	}
	code = C.clReleaseContext(d.ctx)
	if code != 0 {
		return vcl_error(code)
	}
	return vcl_error(C.clReleaseDevice(d.id))
}

fn (d Device) get_info_str(param C.cl_device_info, panic_on_error bool) ?string {
	mut info_bytes := [1024]byte{}
	mut info_bytes_size := u64(0)
	code := C.clGetDeviceInfo(d.id, param, 1024, &info_bytes[0], &info_bytes_size)
	if code != 0 {
		if panic_on_error {
			vcl_panic(code)
		}
		return vcl_error(code)
	}

	res := info_bytes[..info_bytes_size].bytestr()
	return res
}

pub fn (d Device) str() string {
	return d.name() + ' ' + d.vendor()
}

// name device info - name
pub fn (d Device) name() string {
	return d.get_info_str(C.CL_DEVICE_NAME, true) ?
}

// vendor device info - vendor
pub fn (d Device) vendor() string {
	return d.get_info_str(C.CL_DEVICE_VENDOR, true) ?
}

// extensions device info - extensions
pub fn (d Device) extensions() string {
	return d.get_info_str(C.CL_DEVICE_EXTENSIONS, true) ?
}

// open_clc_version device info - OpenCL C version
pub fn (d Device) open_clc_version() string {
	return d.get_info_str(C.CL_DEVICE_OPENCL_C_VERSION, true) ?
}

// profile device info - profile
pub fn (d Device) profile() string {
	return d.get_info_str(C.CL_DEVICE_PROFILE, true) ?
}

// version device info - version
pub fn (d Device) version() string {
	return d.get_info_str(C.CL_DEVICE_VERSION, true) ?
}

// driver_version device info - driver version
pub fn (d Device) driver_version() string {
	return d.get_info_str(C.CL_DRIVER_VERSION, true) ?
}

// add_program copiles program source
// if an error occurs in building the program the add_program will panic
pub fn (mut d Device) add_program(source string) {
	// todo
}
