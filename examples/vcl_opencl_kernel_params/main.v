module main

import vsl.vcl

// a kernel with parameters
const kernel_source = '
__kernel void param_sizes(__global int* data, char size0, uchar size1, short size2, ushort size3, int size4, uint size5, long size6, ulong size7, float size8, double size9) {

    data[0] = sizeof(size0);
	data[1] = sizeof(size1);
	data[2] = sizeof(size2);
	data[3] = sizeof(size3);
	data[4] = sizeof(size4);
	data[5] = sizeof(size5);
	data[6] = sizeof(size6);
	data[7] = sizeof(size7);
	data[8] = sizeof(size8);
	data[9] = sizeof(size9);

}'

fn main() {
	// get all devices if you want
	devices := vcl.get_devices(vcl.DeviceType.cpu)!
	println('Devices: ${devices}')

	// do not create platforms/devices/contexts/queues/...
	// just get the device
	mut device := vcl.get_default_device()!
	defer {
		device.release() or { panic(err) }
	}

	// allocate buffer on the device (6 elems of u32).
	mut v := device.vector[int](10)!
	defer {
		v.release() or { panic(err) }
	}

	// load data to the vector (it's async)
	data := [int(0), 0, 0, 0, 0, 0, 0, 0, 0, 0]
	err := <-v.load(data)
	if err !is none {
		panic(err)
	}
	println('\n\nCreated empty vector: ${v}')
	vector_data := v.data()!
	println('\n\nVector data: ${vector_data}')

	// add program source to device, get kernel
	device.add_program(kernel_source)!
	k := device.kernel('param_sizes')!
	// run kernel (global work size 16 and local work size 1)
	kernel_err := <-k.global(1).local(1).run(v, i8(1), u8(1), i16(1), u16(1), i32(1),
		u32(1), i64(1), u64(1), f32(1.0), f64(1.0))
	if kernel_err !is none {
		panic(kernel_err)
	}

	// get data from vector
	next_data := v.data()!
	// prints out size of each parameter
	println('\n\nUpdated vector data: ${next_data}')

	assert next_data == [1, 1, 2, 2, 4, 4, 8, 8, 4, 8]
}
