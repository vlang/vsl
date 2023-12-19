module vcl

// get_devices returns all devices of all platforms with specified type
pub fn get_devices(device_type DeviceType) ![]&Device {
	platform_ids := get_platforms()!
	mut devices := []&Device{}

	for p in platform_ids {
		mut n := u32(0)
		mut ret := cl_get_device_i_ds(p, ClDeviceType(device_type), 0, unsafe { nil },
			&n)
		if ret != success {
			return error_from_code(ret)
		}
		mut device_ids := unsafe { []ClDeviceId{len: int(n)} }
		ret = cl_get_device_i_ds(p, ClDeviceType(device_type), n, unsafe { &device_ids[0] },
			unsafe { nil })
		if ret != success {
			return error_from_code(ret)
		}
		for d in device_ids {
			device := Device.new(d)!
			devices << device
		}
	}

	return devices
}

// get_default_device ...
pub fn get_default_device() !&Device {
	mut id := ClDeviceId(0)
	platform_ids := get_platforms()!
	ret := cl_get_device_i_ds(unsafe { &platform_ids[0] }, ClDeviceType(DeviceType.cpu),
		1, &id, unsafe { nil })
	if ret != success {
		return error_from_code(ret)
	}
	return Device.new(id)
}

fn get_platforms() ![]ClPlatformId {
	mut n := u32(0)
	mut ret := cl_get_platform_i_ds(0, unsafe { nil }, &n)
	if ret != success {
		return error_from_code(ret)
	}
	mut platform_ids := []ClPlatformId{len: int(n)}
	ret = cl_get_platform_i_ds(n, unsafe { &platform_ids[0] }, unsafe { nil })
	return error_or_default(ret, platform_ids)
}

fn Device.new(id ClDeviceId) !&Device {
	mut d := &Device{
		id: id
	}
	mut ret := 0
	d.ctx = cl_create_context(unsafe { nil }, 1, &id, unsafe { nil }, unsafe { nil },
		&ret)
	if ret != success {
		return error_from_code(ret)
	}
	if isnil(d.ctx) {
		return err_unknown
	}
	if C.CL_VERSION_2_0_EXISTS == 1 {
		d.queue = cl_create_command_queue_with_properties(d.ctx, d.id, unsafe { nil },
			&ret)
	} else {
		d.queue = cl_create_command_queue(d.ctx, d.id, usize(0), &ret)
	}
	return error_or_default(ret, d)
}
