module main

import os
import vsl.vcl
import stbi

const (
	root       = os.dir(@FILE)
	output_dir = os.join_path(root, 'output')
)

fn main() {
	// create output dir
	os.mkdir_all(output_dir)!
	invert_color_kernel := os.read_file(os.join_path(root, 'kernel.cl'))!

	// do not create platforms/devices/contexts/queues/...
	// just get the device
	mut device := vcl.get_default_device()?
	defer {
		device.release() or { panic(err) }
	}
	stbi_img := stbi.load(os.join_path(root, 'julia.png')) or { panic(err) }

	// Create image buffer (image2d_t) to read_only
	mut img := device.from_image_2d(stbi_img) or { panic(err) }
	defer {
		img.release() or { panic(err) }
	}

	// Create image buffer (image2d_t) to write_only
	mut inverted_img := device.image_2d(.rgba, width: img.bounds.width, height: img.bounds.height)?
	defer {
		inverted_img.release() or { panic(err) }
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
	stbi.stbi_write_png(os.join_path(output_dir, 'inverted.png'), int(inverted_img.bounds.width),
		int(inverted_img.bounds.height), 4, next_inverted_img.data, 0)!
}
