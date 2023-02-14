module main

import vsl.vcl
import os
#include "to_bmt.c"
fn C.bmp_generator(filename &u8,width int, height int, data &u8) int
const cube_size = 500

const width = cube_size

const height = cube_size

const names = [
	'mandelbrot_basic',
	'mandelbrot_blue_red_black',
	'mandelbrot_pseudo_random_colors',
	'julia',
	'julia_set',
	'julia_basic',
	'sierpinski_triangle',
	'sierpinski_triangle2',
]

fn main() {
	name := names[3] // name of file and kernel
	os.mkdir('outputs') or { // create outputs
		if !err.msg().contains_any_substr(['File exists']) {
			panic(err)
		}
	}
	// load kernel
	kernel_mondelbrot := os.read_file('kernels/${name}.cl')!

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

	// get and save bmp result
	buffer := img.data_2d()?
	C.bmp_generator('./outputs/${name}.bmp'.str, width, height, unsafe { &buffer[0]})
	// bmp_generator('./outputs/${name}.bmp', width, height, new_buffer)

	// get and save binary result
	mut f := os.create('outputs/${name}V.bin')!
	w := f.write(buffer)!
	if w != buffer.len {
		panic('uncomplete writes')
	}
}
