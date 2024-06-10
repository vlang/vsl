module main

import vsl.vcl
import os
import stbi

const cube_size = 500
const width = cube_size
const height = cube_size

const root = os.dir(@FILE)
const kernels_dir = os.join_path(root, 'kernels')
const output_dir = os.join_path(root, 'output')

const kernels = [
	'mandelbrot_basic',
	'mandelbrot_blue_red_black',
	'mandelbrot_pseudo_random_colors',
	'julia',
	'julia_set',
	'julia_basic',
	'sierpinski_triangle',
	'sierpinski_triangle2',
]

fn run_kernel(kernel_name string) ! {
	// load kernel
	kernel_mondelbrot := os.read_file(os.join_path(kernels_dir, '${kernel_name}.cl')) or {
		return err
	}

	mut device := vcl.get_default_device()!
	defer {
		device.release() or { panic(err) }
	}

	// Create image buffer (image2d_t) to kernel
	mut img := device.image(.rgba, width: width, height: height)!
	defer {
		img.release() or { panic(err) }
	}

	// add program source to device, get kernel
	device.add_program(kernel_mondelbrot)!
	k := device.kernel('${kernel_name}')!

	// run kernel (global work size 16 and local work size 1)
	kernel_err := <-k.global(int(img.bounds.width), int(img.bounds.height))
		.local(1, 1).run(img)
	if kernel_err !is none {
		panic(kernel_err)
	}

	// get image data from buffer and save it
	iimg := img.data()!
	stbi.stbi_write_bmp(os.join_path(output_dir, '${kernel_name}.bmp'), width, height,
		4, iimg.data) or { return err }
	stbi.stbi_write_png(os.join_path(output_dir, '${kernel_name}.png'), width, height,
		4, iimg.data, 0) or { return err }
}

fn main() {
	os.mkdir_all(output_dir)!

	for kernel in kernels {
		run_kernel(kernel)!
	}
}
