# XOR Training Example — CUDA GPU Neural Network

This example demonstrates training a small Multi-Layer Perceptron (MLP) to solve
the XOR problem using VSL's CUDA GPU backend with cuBLAS and cuDNN.

## 🎯 What This Example Does

Trains a 2→8→8→1 neural network to learn the XOR function:

| Input A | Input B | XOR Output |
|---------|---------|------------|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

The network learns to classify correctly after ~1000 epochs of training.

## 🚀 How to Run

### Prerequisites

1. **NVIDIA GPU** with CUDA support (compute capability ≥ 5.0)
2. **CUDA Toolkit** installed (tested with 13.2)
3. **cuDNN** installed (tested with 9.2)

Verify your setup:

```bash
nvidia-smi           # Should display your GPU
nvcc --version       # Should show CUDA version
```

### Run with CUDA GPU

```bash
# Navigate to VSL root
cd /path/to/vsl

# Set library path (adjust for your CUDA installation)
export LD_LIBRARY_PATH=/opt/cuda/lib64:/usr/lib:$LD_LIBRARY_PATH

# Run with CUDA backend
v -d cuda run examples/ml_nn_xor/
```

### Expected Output

```
=== XOR Training on CUDA GPU (cuBLAS + cuDNN) ===
Backend: cuda

Training...
Epoch     0 | Loss: 0.293409
Epoch   200 | Loss: 0.000000
Epoch   400 | Loss: 0.000000
Epoch   600 | Loss: 0.000000
Epoch   800 | Loss: 0.000000
Epoch  1000 | Loss: 0.000000
Epoch  1200 | Loss: 0.000000
Epoch  1400 | Loss: 0.000000
Epoch  1600 | Loss: 0.000000
Epoch  1800 | Loss: 0.000000

=== Final Evaluation ===
Predictions after training:
  Input: (0.0, 0.0) | Pred: 0 | Expected: 0.0
  Input: (0.0, 1.0) | Pred: 1 | Expected: 1.0
  Input: (1.0, 0.0) | Pred: 1 | Expected: 1.0
  Input: (1.0, 1.0) | Pred: 0 | Expected: 0.0

[X] XOR learned successfully on CUDA GPU!
```

## 🔧 Key Implementation Details

### Backend Selection

```v
mut ctx := compute.new_context(.cuda)
```

The `.cuda` backend:
- Uses **cuBLAS** for GEMM operations (matrix multiplication)
- Uses **cuDNN** for activation functions (ReLU, Sigmoid, Tanh)
- Falls back to **CPU** automatically if GPU is unavailable

### Forward Pass with GPU

```v
// Dense layers use GEMM for matrix multiplication
h1 := dense1.forward(x_tensor, mut ctx)
h1_act := nn.relu(h1, mut ctx)
h2 := dense2.forward(h1_act, mut ctx)
h2_act := nn.relu(h2, mut ctx)
h3 := dense3.forward(h2_act, mut ctx)

// Sigmoid for output layer
y_pred := nn.sigmoid(h3, mut ctx)
```

**Important:** All compute functions require `mut ctx` because the context
caches the GPU device handle to avoid repeated cuBLAS/cuDNN handle creation.

### Device Caching

The `ComputeContext` stores a reference to the `CudaDevice` after the first
operation. This prevents the `CUBLAS_STATUS_ALLOC_FAILED` error that occurs
when trying to create multiple cuBLAS handles.

## 📁 Files

- `main.v` — Complete XOR training implementation
- `README.md` — This file

## 🔗 References

- [VSL CUDA Backend](../cuda/README.md) — Full CUDA documentation
- [ML Neural Network](../ml/nn/README.md) — Dense layers, activations, optimizers
- [Compute Dispatch](../compute/dispatch.v) — Backend-agnostic compute API

## 📚 Learning Resources

- [Understanding XOR with Neural Networks](https://en.wikipedia.org/wiki/XOR_problem)
- [cuBLAS GEMM](https://docs.nvidia.com/cublas/)
- [cuDNN Activation](https://docs.nvidia.com/cudnn/)