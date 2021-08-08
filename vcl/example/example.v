module main

import vsl.vcl

fn main() {
	devices := vcl.get_devices(vcl.device_cpu) or { panic(err) }
	println(devices)
}
