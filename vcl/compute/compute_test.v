module compute

import vsl.vcl

fn test_add_scalar_vcl() {
	devices := vcl.get_devices(.all) or { panic(err) }
	if devices.len == 0 {
		println('SKIP: no OpenCL devices are available')
		return
	}
	defer {
		for device in devices {
			device.release() or { panic(err) }
		}
	}

	mut device := devices[0]
	actual := add_scalar_vcl(mut device, [1.0, 2.0, 3.0], 2.0)!
	assert actual == [3.0, 4.0, 5.0]
}

fn test_gemm_vcl_f32() {
	devices := vcl.get_devices(.all) or { panic(err) }
	if devices.len == 0 {
		println('SKIP: no OpenCL devices are available')
		return
	}
	defer {
		for device in devices {
			device.release() or { panic(err) }
		}
	}

	mut device := devices[0]
	device.vector_f32(0) or {
		assert err.msg() == 'vector length must be greater than zero'
		return
	}
	assert false, 'zero-length vector should be rejected'
	actual := gemm_vcl_f32(mut device, [f32(1), 3, 2, 4], [f32(5), 7, 6, 8], 2, 2, 2)!
	assert actual == [f32(19), 43, 22, 50]
}
