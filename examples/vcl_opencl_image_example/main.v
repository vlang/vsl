module main

import os
import vsl.vcl
import stbi

const (
	root       = os.dir(@FILE)
	output_dir = os.join_path(root, 'output')
)

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

const cube_size = 500

fn main() {
	// create output dir
	os.mkdir_all(output_dir)!

	width := cube_size
	height := cube_size

	// do not create platforms/devices/contexts/queues/...
	// just get the device
	mut device := vcl.get_default_device()?
	defer {
		device.release() or { panic(err) }
	}

	// Create image buffer (image2d_t) to read_only
	mut img := device.image_2d(.rgba, width: width, height: height)?
	defer {
		img.release() or { panic(err) }
	}

	// Create image buffer (image2d_t) to write_only
	mut inverted_img := device.image_2d(.rgba, width: width, height: height)?
	defer {
		img.release() or { panic(err) }
	}

	// add program source to device, get kernel
	device.add_program(invert_color_kernel)?
	k := device.kernel('invert')?
	// run kernel (global work size 16 and local work size 1)
	kernel_err := <-k.global(int(img.bounds.width), int(img.bounds.height))
		.local(1, 1).run(img, inverted_img)
	if kernel_err !is none {
		panic(kernel_err)
	}

	next_inverted_img := inverted_img.data_2d()?
	// save image
	stbi.stbi_write_png(os.join_path(output_dir, 'inverted.png'), width, height, 4, next_inverted_img.data,
		0)!
}
