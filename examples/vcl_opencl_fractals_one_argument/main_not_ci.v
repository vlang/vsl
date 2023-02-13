module main

import vsl.vcl
import os

const cube_size = 500

const width = cube_size

const height = cube_size

fn main() {
	// name of file and kernel
	name := 'mandelbrot_basic'
	// embed of file - maybe it could be or open and read ...
	mut kernel_file := $embed_file('kernels/mandelbrot.cl')
	kernel_mondelbrot := kernel_file.to_string()
	// println(kernel_mondelbrot)

	mut device := vcl.get_default_device()?
	defer {
		device.release() or { panic(err) }
	}

	// Create image buffer (image2d_t) to kernel
	mut img := device.image_2d(.rgba, width: width, height: height)?
	defer {
		img.release() or { panic(err) }
	}

	// add program source to device, get kernel
	device.add_program(kernel_mondelbrot)?
	k := device.kernel('${name}')?
	// run kernel (global work size 16 and local work size 1)
	kernel_err := <-k.global(int(img.bounds.width), int(img.bounds.height))
		.local(1, 1).run(img)
	if kernel_err !is none {
		panic(kernel_err)
	}

	// get and save binary result
	next_img := img.data_2d()?
	mut f := os.create('outputs/${name}V.bin')!
	w := f.write(next_img)!
	if w != next_img.len {
		panic('uncomplete writes')
	}
}
