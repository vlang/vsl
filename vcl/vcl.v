module vcl

// get_devices returns all devices of all platforms with specified type
pub fn get_devices(device_type DeviceType) ?[]&Device {
	platform_ids := get_platforms() ?
	mut devices := []&Device{}

	for p in platform_ids {
		mut n := u32(0)
		mut ret := C.clGetDeviceIDs(p, C.cl_device_type(deviceType), 0, voidptr(0), &n)
		if ret != C.CL_SUCCESS {
			return vcl_error(ret)
		}
		mut device_ids := []C.cl_device_id{len: int(n)}
		ret = C.clGetDeviceIDs(p, C.cl_device_type(deviceType), n, &device_ids[0], voidptr(0))
		if ret != C.CL_SUCCESS {
			return vcl_error(ret)
		}
		for d in device_ids {
			device := new_device(d) ?
			devices << device
		}
	}

	return devices
}

// get_default_device ...
pub fn get_default_device() ?&Device {
	mut id := C.cl_device_id{}
	ret := C.clGetDeviceIDs(voidptr(0), C.cl_device_type(DeviceTypeDefault), 1, &id, voidptr(0))
	if ret != C.CL_SUCCESS {
		return vcl_error(ret)
	}
	return new_device(id)
}

fn get_platforms() ?[]C.cl_platform_id {
	mut id := u32(0)
	mut ret := C.clGetPlatformIDs(0, voidptr(0), &n)
	if ret != C.CL_SUCCESS {
		return vcl_error(ret)
	}
	platform_ids := []C.cl_platform_id{len: int(n)}
	ret = C.clGetPlatformIDs(n, &platformIds[0], voidptr(0))
	if ret != C.CL_SUCCESS {
		return vcl_error(ret)
	}
	return platform_ids
}

fn new_device(id C.cl_device_id) ?&Device {
	mut d := &Device{
		id: id
	}
	mut ret := 0
	d.ctx = C.clCreateContext(voidptr(0), 1, &id, voidptr(0), voidptr(0), &ret)
	if ret != C.CL_SUCCESS {
		return vcl_error(ret)
	}
	if isnil(d.ctx) {
		return err_unknown
	}
	if C.blackclOCLVersion == 2 {
		d.queue = C.clCreateCommandQueueWithProperties(d.ctx, d.id, voidptr(0), &ret)
	} else {
		d.queue = C.clCreateCommandQueue(d.ctx, d.id, 0, &ret)
	}
	if ret != C.CL_SUCCESS {
		return vcl_error(ret)
	}
	return d
}
