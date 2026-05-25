# ML Roadmap — Neural Network Module

## 📁 Current State

### Core Components (✅ Implemented)

| File | Description |
|------|-------------|
| `ml/nn/tensor.v` | Tensor with autograd (Grad, GradFn structs) |
| `ml/nn/dense.v` | Dense (linear) layer: `y = x @ W^T + b` |
| `ml/nn/activations.v` | ReLU, Sigmoid, Tanh, Softmax, add_scalar, mul_scalar, add, mul, matmul |
| `ml/nn/loss.v` | MSE, Cross-Entropy, BCE loss functions |
| `ml/nn/optimizer.v` | SGD and Adam optimizers |

### Working Example

- `examples/ml_nn_xor/` — XOR training on CUDA GPU ✅

---

## 🎯 Phase 1: Core Infrastructure (High Priority)

### 1.1 Autograd Engine

**Missing:**
- `backward()` method on Tensor — traverses `grad_fn` chain and computes gradients
- Automatic gradient computation for all operations (currently manual in XOR example)
- `detach()` method to stop gradient tracking
- `clone()` with gradient support

**Implementation approach:**

```v
// Tensor.backward() — compute gradients via backpropagation
pub fn (t &Tensor) backward() {
    if !t.requires_grad {
        return
    }
    if isnil(t.grad) {
        // Start with dL/dy = 1 for root node
        t.grad = &Grad{data: []f64{len: t.data.len, init: 1.0}}
    }
    // Traverse grad_fn chain
    if fn := t.grad_fn {
        fn.backward(t.grad)
    }
}
```

**Priority:** 🔴 High — Without autograd, every model requires manual backprop.

---

### 1.2 Batch Training Support

**Missing:**
- Mini-batch training loop
- DataLoader concept
- Batching in Dense.forward()

**Current:** Only works with batch_size=4 (full dataset)

**Needs:**
```v
// DataLoader struct
pub struct DataLoader {
    data    []f64
    batch_size int
    shuffle bool
}

pub fn (d &DataLoader) next_batch() (&Tensor, &Tensor)
```

---

## 🎯 Phase 2: Layer Types (Medium Priority)

### 2.1 Dropout Layer

```v
pub fn dropout(x &Tensor, rate f64, mut ctx compute.ComputeContext, train bool) &Tensor
```

### 2.2 BatchNorm Layer

```v
pub struct BatchNorm {
    gamma &Tensor  // scale
    beta  &Tensor  // shift
    mu    &Tensor  // running mean
    var   &Tensor  // running variance
}
```

### 2.3 Conv2d Layer

Already in `compute` module via cuDNN, but need VSL wrapper:
```v
pub struct Conv2d {
    in_channels  int
    out_channels int
    kernel_size   [2]int
    stride        [2]int
    padding       [2]int
}
```

### 2.4 MaxPool / AvgPool

```v
pub fn max_pool2d(x &Tensor, k_h int, k_w int, stride int, mut ctx) &Tensor
```

---

## 🎯 Phase 3: Loss Functions (Medium Priority)

### 3.1 Add to `ml/nn/loss.v`

| Loss | Status | Notes |
|------|--------|-------|
| MSE | ✅ Done | |
| Cross-Entropy | ✅ Done | |
| BCE | ✅ Done | |
| **MAE (L1)** | ❌ | `sum(abs(y_pred - y_true)) / n` |
| ** Huber** | ❌ | Smooth L1, combines MSE + MAE |
| **KL Divergence** | ❌ | For distribution matching |
| **Focal Loss** | ❌ | For imbalanced classification |

---

## 🎯 Phase 4: Optimizers (Low Priority)

Already have SGD and Adam. Could add:

| Optimizer | Priority | Notes |
|-----------|----------|-------|
| SGD with momentum | ✅ Done | |
| Adam | ✅ Done | |
| AdamW | ⚠️ Partial | Adam has weight_decay but not correct AdamW |
| RMSprop | ❌ | |
| Adagrad | ❌ | |
| Learning Rate Scheduler | ❌ | StepLR, CosineAnnealing, ReduceLROnPlateau |

---

## 🎯 Phase 5: Serialization (Important)

### 5.1 Model Save/Load

```v
// Save model to file
pub fn (m &Sequential) save(path string) !

// Load model from file
pub fn Sequential.load(path string) !&Sequential
```

Format options:
- **JSON** — simple, human-readable (weights as base64 or hex)
- **Binary** — more compact, faster

### 5.2 Checkpointing

```v
pub fn (m &Sequential) save_checkpoint(path string, epoch int, loss f64) !
pub fn (m &Sequential) load_checkpoint(path string) !(int, f64)
```

---

## 🎯 Phase 6: Neural Network Abstractions

### 6.1 Sequential Container

```v
// Sequential — chain layers sequentially
pub struct Sequential {
    layers []Layer
}

pub fn Sequential.new() &Sequential
pub fn (s &Sequential) add(layer Layer) &
pub fn (s &Sequential) forward(x &Tensor, mut ctx compute.ComputeContext) &Tensor
pub fn (s &Sequential) parameters() []&Tensor
```

**Usage:**
```v
mut model := nn.Sequential.new()
model.add(nn.Dense.new(784, 256, mut ctx))
model.add(nn.relu)
model.add(nn.Dense.new(256, 10, mut ctx))

output := model.forward(input, mut ctx)
```

### 6.2 Layer Interface

```v
pub interface Layer {
    forward(x &Tensor, mut ctx compute.ComputeContext) &Tensor
    parameters() []&Tensor
}
```

---

## 🎯 Phase 7: Example Models

| Model | File | Priority |
|-------|------|----------|
| XOR | ✅ Done | Reference |
| MNIST Digit Classification | `examples/ml_mnist/` | 🔴 High |
| CIFAR-10 Image Classification | `examples/ml_cifar/` | 🟡 Medium |
| Text Classification (Sentiment) | `examples/ml_sentiment/` | 🟡 Medium |
| Autoencoder | `examples/ml_autoencoder/` | 🟢 Low |

### MNIST Example (High Priority)

```v
// Architecture: 784 -> 256 -> 10
// Dataset: MNIST handwritten digits
// Task: Classify digit 0-9
```

---

## 🎯 Phase 8: Training Utilities

### 8.1 Training Loop

```v
pub fn train(model &Sequential, train_data DataLoader, val_data DataLoader, epochs int) ! {
    mut opt := nn.Adam.new(0.001)
    for epoch := 0; epoch < epochs; epoch++ {
        for batch in train_data {
            // Forward
            pred := model.forward(batch.x, mut ctx)
            // Loss
            loss := nn.mse_loss(pred, batch.y)
            // Backward (with autograd)
            pred.backward()
            // Update
            opt.step(model.parameters())
            opt.zero_grad(model.parameters())
        }
    }
}
```

### 8.2 Metrics

```v
pub fn accuracy(pred &Tensor, labels []int) f64
pub fn precision(pred &Tensor, labels []int) f64
pub fn recall(pred &Tensor, labels []int) f64
pub fn f1_score(pred &Tensor, labels []int) f64
```

---

## 📋 Priority Order

```
🔴 High Priority (blocking future work)
├── Autograd Engine (backward, detach, clone)
├── Sequential Container
├── MNIST Example

🟡 Medium Priority (enhances usability)
├── DataLoader / Batch Training
├── Conv2d wrapper
├── Model Save/Load
├── More loss functions (MAE, Huber)

🟢 Low Priority (nice to have)
├── More optimizers (RMSprop, Adagrad)
├── LR Schedulers
├── BatchNorm
├── Dropout
└── More example models
```

---

## 🔗 References

- [VSL CUDA Backend](../cuda/README.md) — GPU compute infrastructure
- [Examples](../examples/ml_nn_xor/) — Working XOR example
- [PyTorch Autograd](https://pytorch.org/docs/stable/autograd.html) — Reference design