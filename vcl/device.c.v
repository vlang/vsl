module vcl

pub enum DeviceType as i64 {
	// device types - bitfield
	cpu = (1 << 0)
	gpu = (1 << 1)
	accelerator = (1 << 2)
	default_device = (1 << 0)
	all = 0xFFFFFFFF
}

const (
	// cl_mem_flags and cl_svm_mem_flags - bitfield
	mem_read_write            = (1 << 0)
	mem_write_only            = (1 << 1)
	mem_read_only             = (1 << 2)
	mem_use_host_ptr          = (1 << 3)
	mem_alloc_host_ptr        = (1 << 4)
	mem_copy_host_ptr         = (1 << 5)
	// reserved (1 << 6)
	mem_host_write_only       = (1 << 7)
	mem_host_read_only        = (1 << 8)
	mem_host_no_access        = (1 << 9)
	mem_svm_fine_grain_buffer = (1 << 10)
	mem_svm_atomics           = (1 << 11)
	mem_kernel_read_and_write = (1 << 12)

	device_name               = 0x102B
	device_vendor             = 0x102C
	driver_version            = 0x102D
	device_profile            = 0x102E
	device_version            = 0x102F
	device_extensions         = 0x1030
	device_platform           = 0x1031
	device_opencl_c_version   = 0x103D
	program_build_log         = 0x1183
)

// Device the only needed entrence for the VCL
// represents the device on which memory can be allocated and kernels run
// it abstracts away all the complexity of contexts/platforms/queues
[heap]
pub struct Device {
mut:
	id       ClDeviceId
	ctx      ClContext
	queue    ClCommandQueue
	programs []ClProgram
}

// release releases the device
pub fn (mut d Device) release() ? {
	for p in d.programs {
		code := clReleaseProgram(p)
		if code != success {
			return vcl_error(code)
		}
	}
	mut code := clReleaseCommandQueue(d.queue)
	if code != success {
		return vcl_error(code)
	}
	code = clReleaseContext(d.ctx)
	if code != success {
		return vcl_error(code)
	}
	return vcl_error(clReleaseDevice(d.id))
}

fn (d &Device) get_info_str(param ClDeviceInfo, panic_on_error bool) ?string {
	mut info_bytes := [1024]u8{}
	mut info_bytes_size := usize(0)
	code := clGetDeviceInfo(d.id, param, 1024, &info_bytes[0], &info_bytes_size)
	if code != success {
		if panic_on_error {
			vcl_panic(code)
		}
		return vcl_error(code)
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
	return d.get_info_str(vcl.device_name, true)
}

// vendor device info - vendor
pub fn (d &Device) vendor() ?string {
	return d.get_info_str(vcl.device_vendor, true)
}

// extensions device info - extensions
pub fn (d &Device) extensions() ?string {
	return d.get_info_str(vcl.device_extensions, true)
}

// open_clc_version device info - OpenCL C version
pub fn (d &Device) open_clc_version() ?string {
	return d.get_info_str(vcl.device_opencl_c_version, true)
}

// profile device info - profile
pub fn (d &Device) profile() ?string {
	return d.get_info_str(vcl.device_profile, true)
}

// version device info - version
pub fn (d &Device) version() ?string {
	return d.get_info_str(vcl.device_version, true)
}

// driver_version device info - driver version
pub fn (d &Device) driver_version() ?string {
	return d.get_info_str(vcl.driver_version, true)
}

// add_program copiles program source
// if an error occurs in building the program the add_program will panic
pub fn (mut d Device) add_program(source string) ? {
	mut ret := 0
	source_ptr := &char(source.str)
	p := clCreateProgramWithSource(d.ctx, 1, &source_ptr, unsafe { nil }, &ret)
	if ret != success {
		return vcl_error(ret)
	}
	ret = clBuildProgram(p, 1, &d.id, &char(0), unsafe { nil }, unsafe { nil })
	if ret != success {
		if ret == build_program_failure {
			mut n := usize(0)
			clGetProgramBuildInfo(p, d.id, vcl.program_build_log, 0, unsafe { nil },
				&n)
			log := []u8{len: int(n)}
			clGetProgramBuildInfo(p, d.id, vcl.program_build_log, n, &log[0], unsafe { nil })
			return error(log.bytestr())
		}
		return vcl_error(ret)
	}
	d.programs << p
}
