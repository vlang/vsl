module vcl

// get_devices returns all devices of all platforms with specified type
pub fn get_devices(device_type DeviceType) ?[]&Device {
	platform_ids := get_platforms()?
	mut devices := []&Device{}

	for p in platform_ids {
		mut n := u32(0)
		mut ret := clGetDeviceIDs(p, ClDeviceType(device_type), 0, unsafe { nil }, &n)
		if ret != success {
			return vcl_error(ret)
		}
		mut device_ids := []ClDeviceId{len: int(n)}
		ret = clGetDeviceIDs(p, ClDeviceType(device_type), n, unsafe { &device_ids[0] },
			unsafe { nil })
		if ret != success {
			return vcl_error(ret)
		}
		for d in device_ids {
			device := new_device(d)?
			devices << device
		}
	}

	return devices
}

// get_default_device ...
pub fn get_default_device() ?&Device {
	mut id := ClDeviceId(0)
	platform_ids := get_platforms()?
	ret := clGetDeviceIDs(unsafe { &platform_ids[0] }, ClDeviceType(DeviceType.default_device),
		1, &id, unsafe { nil })
	if ret != success {
		return vcl_error(ret)
	}
	return new_device(id)
}

fn get_platforms() ?[]ClPlatformId {
	mut n := u32(0)
	mut ret := clGetPlatformIDs(0, unsafe { nil }, &n)
	if ret != success {
		return vcl_error(ret)
	}
	mut platform_ids := []ClPlatformId{len: int(n)}
	ret = clGetPlatformIDs(n, unsafe { &platform_ids[0] }, unsafe { nil })
	if ret != success {
		return vcl_error(ret)
	}
	return platform_ids
}

fn new_device(id ClDeviceId) ?&Device {
	mut d := &Device{
		id: id
	}
	mut ret := 0
	d.ctx = clCreateContext(unsafe { nil }, 1, &id, unsafe { nil }, unsafe { nil },
		&ret)
	if ret != success {
		return vcl_error(ret)
	}
	if isnil(d.ctx) {
		return err_unknown
	}
	if C.CL_VERSION_2_0_EXISTS == 1 {
		d.queue = clCreateCommandQueueWithProperties(d.ctx, d.id, unsafe { nil }, &ret)
	} else {
		d.queue = clCreateCommandQueue(d.ctx, d.id, 0, &ret)
	}
	if ret != success {
		return vcl_error(ret)
	}
	return d
}
