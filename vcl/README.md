# V Computing Language

VCL is a high level way of writting programs with OpenCL using V.
These are highly opinionated OpenCL bindings for V. It tries to make GPU computing easy,
with some sugar abstraction, V's concurency and channels.

## Loading OpenCL dynamicly

By default VCL uses OpenCL loading the library statically. If you want to use OpenCL
dynamicly, you can use the `-d dlopencl` flag.



By default it will look for the OpenCL library in the system path and all the known
locations for OpenCL libraries (like `/usr/lib` and `/usr/local/lib`) and load the first
library it finds. If you want to use a specific OpenCL library,
you can declare the environment variable `VCL_LIBOPENCL_PATH` with
the path to the library. Multiple paths can be separated by `:`.

For example, if you want to use the OpenCL library from the NVIDIA CUDA Toolkit, you can
do the following:

```bash
export VCL_LIBOPENCL_PATH=/usr/local/cuda/lib64/libOpenCL.so
```
## termux
If you are in termux you use `-d dlopencl` flag automatic, but before that you will need:
```
git clone https://github.com/KhronosGroup/OpenCL-Headers
cd OpenCL-Headers
cp -r CL ~/.vmodules/vsl/vcl/
cd
```
you can also use `VCL_LIBOPENCL_PATH` but it need path for specific hardware for example in my 
samsung galaxy tab s6: `/system/vendor/lib/libOpenCL.so`


## Example

```v ignore
module main

import vsl.vcl

// an complicated kernel
const kernel_source = '
__kernel void addOne(__global float* data) {
    const int i = get_global_id(0);
    data[i] += 1;
}'

// get all devices if you want
devices := vcl.get_devices(vcl.DeviceType.cpu)?
println('Devices: $devices')

// do not create platforms/devices/contexts/queues/...
// just get the device
mut device := vcl.get_default_device()?
defer {
	device.release() or { panic(err) }
}

// VCL has several kinds of device memory object: Bytes, Vector, Image (Soon)
// allocate buffer on the device (16 elems of f32).
mut v := device.vector<f32>(16)?
defer {
	v.release() or { panic(err) }
}

// load data to the vector (it's async)
data := [f32(0.0), 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
err := <-v.load(data)
if err !is none {
	panic(err)
}
println('\n\nCreated vector: $v')
println(v.data()?)

// add program source to device, get kernel
device.add_program(kernel_source)?
k := device.kernel('addOne')?
// run kernel (global work size 16 and local work size 1)
kernel_err := <-k.global(16).local(1).run(v)
if kernel_err !is none {
	panic(kernel_err)
}

// get data from vector
next_data := v.data()?
// prints out [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]
println('\n\nUpdated vector data: $next_data')
```
