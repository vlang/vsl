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
