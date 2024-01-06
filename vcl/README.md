# V Computing Language

VCL is a high level way of writing programs with OpenCL using V.
These are highly opinionated OpenCL bindings for V. It tries to make GPU computing easy,
with some sugar abstraction, V's concurrency and channels.

|                                      |                                |                |                       |
| :----------------------------------: | :----------------------------: | :------------: | :-------------------: |
|       ![][sierpinski_triangle]       | ![][mandelbrot_blue_red_black] |   ![][julia]   | ![][mandelbrot_basic] |
| ![][mandelbrot_pseudo_random_colors] |   ![][sierpinski_triangle2]    | ![][julia_set] |   ![][julia_basic]    |

## Using custom OpenCL headers

> IMPORTANT: Using a different OpenCL header version than the one used by the OpenCL library
> can cause problems. If you are using a custom OpenCL header, make sure that it is
> compatible with the OpenCL library you are using.
>
> NOTE: Darwin systems will look for the header file at `<OpenCL/opencl.h>` while any other
> systems will look for the header file at `<CL/cl.h>`.

By default VCL uses the OpenCL headers from the system path and all the known
locations for OpenCL headers (like `/usr/include` and `/usr/local/include`) and load the first
header it finds. If you want to use a specific OpenCL header,
you can add the `-I` flag into your V program with the path to the headers directory.

```v
#flag -I/custom/path/to/opencl/headers
```

or at compile time:

```sh
v -I/custom/path/to/opencl/headers my_program.v
```

You can also link or move the headers directory into VCL's source directory. For example:

```sh
# for darwin systems
ln -s /custom/path/to/opencl/headers ~/.vmodules/vcl/OpenCL

# or for any other system you can do
ln -s /custom/path/to/opencl/headers ~/.vmodules/vcl/CL
```

or, you can copy the headers directory into VCL's source directory.
For example you can clone the OpenCL-Headers repository and copy the headers as follows:

```sh
git clone https://github.com/KhronosGroup/OpenCL-Headers /tmp/OpenCL-Headers

# for darwin systems
cp -r /tmp/OpenCL-Headers/CL ~/.vmodules/vcl/OpenCL

# or for any other system you can do
cp -r /tmp/OpenCL-Headers/CL ~/.vmodules/vcl/CL
```

## Loading OpenCL dynamically

By default VCL uses OpenCL loading the library statically. If you want to use OpenCL
dynamically, you can use the `-d vsl_vcl_dlopencl` flag.

By default it will look for the OpenCL library in the system path and all the known
locations for OpenCL libraries (like `/usr/lib` and `/usr/local/lib`) and load the first
library it finds. If you want to use a specific OpenCL library,
you can declare the environment variable `VCL_LIBOPENCL_PATH` with
the path to the library. Multiple paths can be separated by `:`.

For example, if you want to use the OpenCL library from the NVIDIA CUDA Toolkit, you can
do the following:

```sh
export VCL_LIBOPENCL_PATH=/usr/local/cuda/lib64/libOpenCL.so
```

<!-- Images -->

[sierpinski_triangle]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/sierpinski_triangle.png
[mandelbrot_blue_red_black]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/mandelbrot_blue_red_black.png
[julia]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/julia.png
[mandelbrot_basic]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/mandelbrot_basic.png
[mandelbrot_pseudo_random_colors]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/mandelbrot_pseudo_random_colors.png
[sierpinski_triangle2]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/sierpinski_triangle2.png
[julia_set]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/julia_set.png
[julia_basic]: https://raw.githubusercontent.com/vlang/vsl/main/vcl/static/julia_basic.png
