module main

import gg
import vsl.vcl

const invert_color_kernel = '
__constant sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;

__kernel void invert(__read_only image2d_t src, __write_only image2d_t dest) {
	const int2 pos = {get_global_id(0), get_global_id(1)};
	float4 pixel = read_imagef(src, sampler, pos);
	pixel.x = 1 - pixel.x;
	pixel.y = 1 - pixel.y;
	pixel.z = 1 - pixel.z;
	write_imagef(dest, pos, pixel);
}'

// get all devices if you want
devices := vcl.get_devices(vcl.DeviceType.cpu)?
println('Devices: ${devices}')

// do not create platforms/devices/contexts/queues/...
// just get the device
mut device := vcl.get_default_device()?
defer {
	device.release() or { panic(err) }
}

// Create image buffer
mut img := device.image(.rgba, width: 500, height: 500)?
defer {
	img.release() or { panic(err) }
}
