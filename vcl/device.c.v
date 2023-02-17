module vcl

import vsl.vcl.native

// Device the only needed entrence for the VCL
// represents the device on which memory can be allocated and kernels run
// it abstracts away all the complexity of contexts/platforms/queues
[heap]
pub struct Device {
mut:
	id       native.ClDeviceId
	ctx      native.ClContext
	queue    native.ClCommandQueue
	programs []native.ClProgram
}

// release releases the device
pub fn (mut d Device) release() ? {
	for p in d.programs {
		code := native.cl_release_program(p)
		if code != native.success {
			return native.vcl_error(code)
		}
	}
	mut code := native.cl_release_command_queue(d.queue)
	if code != native.success {
		return native.vcl_error(code)
	}
	code = native.cl_release_context(d.ctx)
	if code != native.success {
		return native.vcl_error(code)
	}
	return native.vcl_error(native.cl_release_device(d.id))
}

fn (d &Device) get_info_str(param native.ClDeviceInfo, panic_on_error bool) ?string {
	mut info_bytes := [1024]u8{}
	mut info_bytes_size := usize(0)
	code := native.cl_get_device_info(d.id, param, 1024, &info_bytes[0], &info_bytes_size)
	if code != native.success {
		return native.vcl_error(code)
	}

	res := info_bytes[..int(info_bytes_size)].bytestr()
	return res
}

pub fn (d &Device) str() string {
	name := d.name() or { '' }
	vendor := d.vendor() or { '' }
	return '${name} ${vendor}'
}

// name device info - name
pub fn (d &Device) name() ?string {
	return d.get_info_str(native.device_name, true)
}

// vendor device info - vendor
pub fn (d &Device) vendor() ?string {
	return d.get_info_str(native.device_vendor, true)
}

// extensions device info - extensions
pub fn (d &Device) extensions() ?string {
	return d.get_info_str(native.device_extensions, true)
}

// open_clc_version device info - OpenCL C version
pub fn (d &Device) open_clc_version() ?string {
	return d.get_info_str(native.device_opencl_c_version, true)
}

// profile device info - profile
pub fn (d &Device) profile() ?string {
	return d.get_info_str(native.device_profile, true)
}

// version device info - version
pub fn (d &Device) version() ?string {
	return d.get_info_str(native.device_version, true)
}

// driver_version device info - driver version
pub fn (d &Device) driver_version() ?string {
	return d.get_info_str(native.driver_version, true)
}

// add_program copiles program source
// if an error occurs in building the program the add_program will panic
pub fn (mut d Device) add_program(source string) ? {
	mut ret := 0
	source_ptr := &char(source.str)
	p := native.cl_create_program_with_source(d.ctx, 1, &source_ptr, unsafe { nil }, &ret)
	if ret != native.success {
		return native.vcl_error(ret)
	}
	ret = native.cl_build_program(p, 1, &d.id, &char(0), unsafe { nil }, unsafe { nil })
	if ret != native.success {
		if ret == native.build_program_failure {
			mut n := usize(0)
			native.cl_get_program_build_info(p, d.id, native.program_build_log, 0, unsafe { nil },
				&n)
			log := []u8{len: int(n)}
			native.cl_get_program_build_info(p, d.id, native.program_build_log, n, &log[0],
				unsafe { nil })
			return error(log.bytestr())
		}
		return native.vcl_error(ret)
	}
	d.programs << p
}
