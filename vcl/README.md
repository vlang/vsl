# V Computing Language (VCL) 🖥️

VCL is a high-level, V-native interface for GPU computing with OpenCL. It
provides an opinionated, simplified approach to GPU programming that emphasizes
ease of use while maintaining high performance for scientific computing
applications.

## 🚀 Features

- **Device Abstraction**: Simplified device management hiding OpenCL complexity
- **Memory Management**: Automatic buffer creation and data transfer
- **Kernel Compilation**: Dynamic OpenCL C compilation with detailed error reporting
- **Cross-Platform**: Supports NVIDIA, AMD, Intel GPUs and multi-core CPUs
- **V Integration**: Native V syntax with error handling and memory safety

## 🎯 Quick Start Example

```v ignore
import vsl.vcl

// Initialize VCL and get the first available device
mut device := vcl.get_default_device()!

// OpenCL kernel source code
kernel_source := '
__kernel void vector_add(__global float* a, __global float* b, __global float* c, int n) {
    int id = get_global_id(0);
    if (id < n) {
        c[id] = a[id] + b[id];
    }
}'

// Compile the kernel
device.add_program(kernel_source)!

// Create and use buffers for computation
// (See examples directory for complete implementations)
```

## 📊 Visual Gallery

VCL enables creation of stunning GPU-accelerated visualizations:

|                                      |                                |                |                       |
| :----------------------------------: | :----------------------------: | :------------: | :-------------------: |
|       ![][sierpinski_triangle]       | ![][mandelbrot_blue_red_black] |   ![][julia]   | ![][mandelbrot_basic] |
| ![][mandelbrot_pseudo_random_colors] |   ![][sierpinski_triangle2]    | ![][julia_set] |   ![][julia_basic]    |

## 🔧 Installation & Configuration

### Prerequisites

1. **OpenCL Runtime**: Install GPU vendor's OpenCL runtime
   - **NVIDIA**: CUDA Toolkit or GPU drivers
   - **AMD**: AMD APP SDK or Radeon drivers  
   - **Intel**: Intel OpenCL Runtime or integrated graphics drivers

2. **OpenCL Headers**: Development headers for compilation

### Platform-Specific Installation

**Ubuntu/Debian:**

```sh
# NVIDIA GPUs
sudo apt-get install nvidia-opencl-dev

# AMD GPUs
sudo apt-get install amd-opencl-dev

# Intel integrated graphics
sudo apt-get install intel-opencl-icd
```

**macOS:**
OpenCL is built into the system (no additional installation required)

**Windows:**
Install your GPU vendor's SDK (NVIDIA CUDA, AMD APP, Intel OpenCL)

### Verification

Test your OpenCL installation:

```sh
# Check available platforms and devices
clinfo  # If available on your system

# Or run a VCL example
cd examples/vcl_opencl_basic
v run main.v
```

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

## 🎓 Learning Path

### Beginner: Start Here
1. **Basic Device Setup**: `vcl_opencl_basic` - Device detection and simple kernels
2. **Memory Management**: Learn buffer creation and data transfer patterns
3. **Simple Algorithms**: Vector addition, element-wise operations

### Intermediate: Explore More
1. **Image Processing**: `vcl_opencl_image_example` - 2D data manipulation
2. **Mathematical Algorithms**: Matrix operations, FFT implementations
3. **Performance Optimization**: Memory access patterns, work-group sizing

### Advanced: Push Limits
1. **Fractal Generation**: `vcl_opencl_fractals_one_argument` - Complex mathematical visualization
2. **Multi-Device Programming**: Utilizing multiple GPUs simultaneously
3. **Custom Memory Patterns**: Local memory optimization, async operations

## 🔧 Custom OpenCL Headers (Advanced)

> **IMPORTANT**: Header version compatibility is crucial. Mismatched OpenCL
> headers can cause runtime failures.

By default, VCL uses system OpenCL headers. For custom installations:

### Method 1: Compiler Flags

```v
#flag -I/custom/path/to/opencl/headers
```

Or at compile time:

```sh
v -I/custom/path/to/opencl/headers my_program.v
```

### Method 2: Symbolic Links

```sh
# macOS systems (Darwin)
ln -s /custom/path/to/opencl/headers ~/.vmodules/vcl/OpenCL

# Linux/Windows systems  
ln -s /custom/path/to/opencl/headers ~/.vmodules/vcl/CL
```

### Method 3: Direct Copy

```sh
# Clone official headers
git clone https://github.com/KhronosGroup/OpenCL-Headers /tmp/OpenCL-Headers

# Copy to VCL directory
# For macOS:
cp -r /tmp/OpenCL-Headers/CL ~/.vmodules/vcl/OpenCL

# For Linux/Windows:
cp -r /tmp/OpenCL-Headers/CL ~/.vmodules/vcl/CL
```

## ⚡ Dynamic OpenCL Loading

For runtime flexibility, use dynamic loading:

```sh
# Enable dynamic loading
v -d vsl_vcl_dlopencl my_program.v
```

### Custom Library Paths

Set environment variable for specific OpenCL libraries:

```sh
# Single path
export VCL_LIBOPENCL_PATH=/usr/local/cuda/lib64/libOpenCL.so

# Multiple paths (colon-separated)
export VCL_LIBOPENCL_PATH=/usr/lib/libOpenCL.so:/opt/intel/opencl/lib64/libOpenCL.so
```

## 🐛 Troubleshooting

### Common Issues

**No OpenCL platforms found**
- Install GPU drivers and OpenCL runtime
- Check `clinfo` output for available platforms
- Verify OpenCL library is in system path

**Kernel compilation errors**
- Check OpenCL C syntax (different from standard C)
- Verify data type compatibility (float vs double support)
- Use VCL's detailed error reporting for debugging

**Performance issues**
- Profile memory transfer vs computation time
- Optimize work-group sizes for your hardware
- Consider local memory usage patterns

**Build failures**
- Ensure OpenCL development headers are installed
- Check compiler flag compatibility
- Verify V compiler version compatibility

### Platform-Specific Notes

**NVIDIA GPUs:**
- Best performance with latest CUDA toolkit
- Double precision requires compute capability 1.3+
- Use `nvidia-smi` to check GPU utilization

**AMD GPUs:**
- Strong OpenCL support across all generations
- Consider ROCm for professional workloads
- Use `rocm-smi` for monitoring

**Intel Graphics:**
- Good for development and light workloads
- Limited by memory bandwidth
- Excellent for heterogeneous CPU+GPU computing

## 📚 Examples

Explore VCL capabilities through examples:

- `vcl_opencl_basic` - Device setup and simple kernels
- `vcl_opencl_image_example` - Image processing operations  
- `vcl_opencl_fractals_one_argument` - Mathematical visualization
- `vcl_opencl_kernel_params` - Parameter passing techniques

## 🔗 Resources

- [OpenCL Programming Guide](https://www.khronos.org/opencl/)
- [VSL Documentation](https://vlang.github.io/vsl)
- [V Language Documentation](https://vlang.io)
- [GPU Architecture Guides](https://developer.nvidia.com/cuda-zone)

---

Accelerate your scientific computing with VCL! 🚀
