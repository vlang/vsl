# OpenCL GPU Computing Example ⚡️

This example demonstrates GPU-accelerated computing using VSL's VCL (V Computing Language)  
module with OpenCL. Learn how to leverage GPU parallel processing for scientific computations.

## 🎯 What You'll Learn

- OpenCL initialization and device detection
- GPU memory management and data transfer
- Kernel programming for parallel execution
- Performance comparison: CPU vs GPU
- VSL's VCL module integration

## 📋 Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- **OpenCL development libraries** installed
- GPU or CPU with OpenCL support

### Installing OpenCL

**Ubuntu/Debian:**

```sh
# For NVIDIA GPUs
sudo apt-get install nvidia-opencl-dev

# For AMD GPUs
sudo apt-get install amd-opencl-dev

# For Intel integrated graphics
sudo apt-get install intel-opencl-icd
```

**macOS:**
OpenCL is built-in (no additional installation needed)

**Windows:**
Install GPU vendor's SDK (NVIDIA CUDA, AMD APP, Intel OpenCL)

## 🚀 Running the Example

```sh
# Navigate to this directory
cd examples/vcl_opencl_basic

# Compile with OpenCL support
v -cflags -lOpenCL run main.v

# Alternative for some systems
v -cflags "-framework OpenCL" run main.v  # macOS
```

## 📊 Expected Output

The example will display:

```text
Available OpenCL platforms: [number]
Platform 0: [Platform Name]
Available devices: [number]
Device 0: [Device Name] (Type: GPU/CPU)

Running OpenCL kernel...
Input data: [1.0, 2.0, 3.0, 4.0, ...]
Output data: [2.0, 4.0, 6.0, 8.0, ...]
Execution time: [X.XX] ms

GPU acceleration successful! ✅
```

## 🔍 OpenCL Concepts Explained

### Platform and Device Model

- **Platform**: OpenCL implementation (NVIDIA, AMD, Intel)
- **Device**: Compute unit (GPU, CPU, FPGA)
- **Context**: Environment for kernels and memory objects
- **Command Queue**: Manages kernel execution order

### Memory Hierarchy

- **Global Memory**: Large, accessible by all work-items
- **Local Memory**: Fast, shared within work-groups
- **Private Memory**: Fastest, per work-item storage

### Execution Model

- **Work-item**: Single execution thread
- **Work-group**: Collection of work-items
- **NDRange**: Complete problem space

## 🎨 Experiment Ideas

Try modifying the example to:

- **Change data sizes** to test performance scaling
- **Implement different algorithms** (matrix multiplication, image processing)
- **Compare GPU vs CPU performance** for various workloads
- **Use local memory** for optimization
- **Add multiple kernels** for complex computations

## 📚 Related Examples

- `vcl_opencl_image_example` - Image processing with OpenCL
- `vcl_opencl_fractals_one_argument` - Fractal generation on GPU
- `noise_fractal_2d` - CPU-based noise generation for comparison

## 🔬 Technical Details

**VCL Integration:**

- Automatic platform/device detection
- Memory management abstraction
- Kernel compilation and caching
- Error handling and debugging

**Performance Optimization:**

- Memory coalescing for efficiency
- Work-group size optimization
- Kernel occupancy maximization
- Data transfer minimization

## 🚀 GPU Programming Best Practices

### Memory Management

- Minimize CPU-GPU data transfers
- Use appropriate memory types
- Consider memory access patterns

### Kernel Optimization

- Maximize thread utilization
- Avoid divergent branches
- Use local memory effectively

### Algorithm Design

- Decompose problems for parallelism
- Balance computation vs. communication
- Consider GPU architecture constraints

## 🐛 Troubleshooting

**OpenCL not found**: Install GPU vendor's OpenCL runtime

**No devices detected**: Check GPU drivers are installed and up-to-date

**Kernel compilation errors**: Verify OpenCL C syntax in kernel code

**Performance slower than CPU**: Check data transfer overhead and kernel efficiency

**Memory allocation failures**: Reduce data size or use streaming

## 🔧 Platform-Specific Notes

### NVIDIA GPUs

- Best performance with CUDA toolkit installed
- Supports double precision on newer cards
- Excellent for compute-intensive workloads

### AMD GPUs

- Strong OpenCL support across all generations
- Good for both compute and graphics workloads
- ROCm platform for professional computing

### Intel Integrated Graphics

- Good for learning and development
- Limited by memory bandwidth
- Useful for CPU+GPU heterogeneous computing

## 🔗 Advanced Topics

After mastering this example, explore:

- **Multi-device programming**: Using multiple GPUs
- **Asynchronous execution**: Non-blocking operations
- **Image processing**: 2D/3D data manipulation
- **FFT on GPU**: Signal processing acceleration

## 📖 Additional Resources

- [OpenCL Programming Guide](https://www.khronos.org/opencl/)
- [VSL VCL Documentation](https://vlang.github.io/vsl/vcl/)
- [GPU Architecture Guides](https://developer.nvidia.com/cuda-zone)

---

Accelerate your computations with GPU power! 🚀 Explore more examples in the
[examples directory](../).
