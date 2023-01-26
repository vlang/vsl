# V Computing Language

VCL is a high level way of writting programs with OpenCL using V.
These are highly opinionated OpenCL bindings for V. It tries to make GPU computing easy,
with some sugar abstraction, V's concurency and channels.

## Loading OpenCL dynamically

By default VCL uses OpenCL loading the library statically. If you want to use OpenCL
dynamically, you can use the `-d dlopencl` flag.

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

## Termux instalation

<details><summary>expand</summary>
<p>
On termux you have to go with dynamic option, but before that you could execute theese command (add headers into source):
	```bash
	cd
	git clone https://github.com/KhronosGroup/OpenCL-Headers
	cp -r OpenCL-Headers/CL .vmodules/vsl/vcl/
	```
When your code do not run you can find on onternet path to opencl for your specific device and export `VCL_LIBOPENCL_PATH`
</p>
</details>
