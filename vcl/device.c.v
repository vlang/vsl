module vcl

pub enum DeviceType as i64 {
	// device types - bitfield
	default     = (1 << 0)
	cpu         = (1 << 1)
	gpu         = (1 << 2)
	accelerator = (1 << 3)
	custom      = (1 << 4)
	all         = 0xFFFFFFFF
}

// cl_mem_flags and cl_svm_mem_flags - bitfield
const mem_read_write = (1 << 0)
const mem_write_only = (1 << 1)
const mem_read_only = (1 << 2)
const mem_use_host_ptr = (1 << 3)
const mem_alloc_host_ptr = (1 << 4)
const mem_copy_host_ptr = (1 << 5)
// reserved (1 << 6)
const mem_host_write_only = (1 << 7)
const mem_host_read_only = (1 << 8)
const mem_host_no_access = (1 << 9)
const mem_svm_fine_grain_buffer = (1 << 10)
const mem_svm_atomics = (1 << 11)
const mem_kernel_read_and_write = (1 << 12)

const device_name = 0x102B
const device_vendor = 0x102C
const driver_version = 0x102D
const device_profile = 0x102E
const device_version = 0x102F
const device_extensions = 0x1030
const device_platform = 0x1031
const device_opencl_c_version = 0x103D
const program_build_log = 0x1183

// Device the only needed entrence for the VCL
// represents the device on which memory can be allocated and kernels run
// it abstracts away all the complexity of contexts/platforms/queues
@[heap]
pub struct Device {
mut:
	id       ClDeviceId
	ctx      ClContext
	queue    ClCommandQueue
	programs []ClProgram
}

// release releases the device
pub fn (mut d Device) release() ! {
	for p in d.programs {
		code := cl_release_program(p)
		if code != success {
			return vcl_error(code)
		}
	}
	mut code := cl_release_command_queue(d.queue)
	if code != success {
		return vcl_error(code)
	}
	code = cl_release_context(d.ctx)
	if code != success {
		return vcl_error(code)
	}
	return vcl_error(cl_release_device(d.id))
}

fn (d &Device) get_info_str(param ClDeviceInfo, should_panic_on_error bool) !string {
	mut info_bytes := [1024]u8{}
	mut info_bytes_size := usize(0)
	code := cl_get_device_info(d.id, param, 1024, &info_bytes[0], &info_bytes_size)
	if code != success {
		if should_panic_on_error {
			panic_on_error(code)
		}
		return error_or_default(code, '')
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
pub fn (d &Device) name() !string {
	return d.get_info_str(device_name, true)
}

// vendor device info - vendor
pub fn (d &Device) vendor() !string {
	return d.get_info_str(device_vendor, true)
}

// extensions device info - extensions
pub fn (d &Device) extensions() !string {
	return d.get_info_str(device_extensions, true)
}

// open_clc_version device info - OpenCL C version
pub fn (d &Device) open_clc_version() !string {
	return d.get_info_str(device_opencl_c_version, true)
}

// profile device info - profile
pub fn (d &Device) profile() !string {
	return d.get_info_str(device_profile, true)
}

// version device info - version
pub fn (d &Device) version() !string {
	return d.get_info_str(device_version, true)
}

// driver_version device info - driver version
pub fn (d &Device) driver_version() !string {
	return d.get_info_str(driver_version, true)
}

// add_program compiles program source from OpenCL C code
// This method takes OpenCL C source code, compiles it, and stores the resulting program
// for later kernel creation and execution.
//
// Parameters:
//   source: OpenCL C source code as a string
//
// Returns:
//   Error if compilation fails, including detailed build log for debugging
//
// Example:
//   kernel_source := '
//   __kernel void vector_add(__global float* a, __global float* b, __global float* c) {
//       int id = get_global_id(0);
//       c[id] = a[id] + b[id];
//   }'
//   device.add_program(kernel_source)!
//
// Note: If compilation fails, the error will include the complete build log
// with line numbers and specific error messages from the OpenCL compiler.
pub fn (mut d Device) add_program(source string) ! {
	mut ret := 0
	source_ptr := &char(source.str)

	// Create program object from source code
	p := cl_create_program_with_source(d.ctx, 1, &source_ptr, unsafe { nil }, &ret)
	if ret != success {
		return vcl_error(ret)
	}

	// Build (compile) the program for this device
	ret = cl_build_program(p, 1, &d.id, unsafe { &char(0) }, unsafe { nil }, unsafe { nil })
	if ret != success {
		if ret == build_program_failure {
			// Get detailed build log for debugging
			mut n := usize(0)
			cl_get_program_build_info(p, d.id, program_build_log, 0, unsafe { nil }, &n)
			log := []u8{len: int(n)}
			cl_get_program_build_info(p, d.id, program_build_log, n, &log[0], unsafe { nil })
			// Return the build log as error message for debugging
			return error('OpenCL program compilation failed:\n${log.bytestr()}')
		}
		return vcl_error(ret)
	}

	// Store the compiled program for later kernel creation
	d.programs << p
}
