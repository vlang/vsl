module vcl

import vsl.vcl.native
// get_devices returns all devices of all platforms with specified type

pub fn get_devices(device_type native.DeviceType) ?[]&Device {
	platform_ids := get_platforms()?
	mut devices := []&Device{}

	for p in platform_ids {
		mut n := u32(0)
		mut ret := native.cl_get_device_i_ds(p, native.ClDeviceType(device_type), 0, unsafe { nil },
			&n)
		if ret != native.success {
			return native.vcl_error(ret)
		}
		mut device_ids := []native.ClDeviceId{len: int(n)}
		ret = native.cl_get_device_i_ds(p, native.ClDeviceType(device_type), n, unsafe { &device_ids[0] },
			unsafe { nil })
		if ret != native.success {
			return native.vcl_error(ret)
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
	mut id := native.ClDeviceId(0)
	platform_ids := get_platforms()?
	ret := native.cl_get_device_i_ds(unsafe { &platform_ids[0] }, native.ClDeviceType(native.DeviceType.default_device),
		1, &id, unsafe { nil })
	if ret != native.success {
		return native.vcl_error(ret)
	}
	return new_device(id)
}

fn get_platforms() ?[]native.ClPlatformId {
	mut n := u32(0)
	mut ret := native.cl_get_platform_i_ds(0, unsafe { nil }, &n)
	if ret != native.success {
		return native.vcl_error(ret)
	}
	mut platform_ids := []native.ClPlatformId{len: int(n)}
	ret = native.cl_get_platform_i_ds(n, unsafe { &platform_ids[0] }, unsafe { nil })
	if ret != native.success {
		return native.vcl_error(ret)
	}
	return platform_ids
}

fn new_device(id native.ClDeviceId) ?&Device {
	mut d := &Device{
		id: id
	}
	mut ret := 0
	d.ctx = native.cl_create_context(unsafe { nil }, 1, &id, unsafe { nil }, unsafe { nil },
		&ret)
	if ret != native.success {
		return native.vcl_error(ret)
	}
	if isnil(d.ctx) {
		return native.err_unknown
	}
	if native.exist_2_0_version == 1 {
		d.queue = native.cl_create_command_queue_with_properties(d.ctx, d.id, unsafe { nil },
			&ret)
	} else {
		d.queue = native.cl_create_command_queue(d.ctx, d.id, usize(0), &ret)
	}
	if ret != native.success {
		return native.vcl_error(ret)
	}
	return d
}
