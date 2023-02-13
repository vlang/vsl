module main

import vsl.vcl
import os

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
	name := names[7] // name of file and kernel
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

	// get and save binary result
	next_img := img.data_2d()?
	mut f := os.create('outputs/${name}V.bin')!
	w := f.write(next_img)!
	if w != next_img.len {
		panic('uncomplete writes')
	}
}
