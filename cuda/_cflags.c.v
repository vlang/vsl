// Copyright (c) 2024-2026 VSL Contributors
// SPDX-License-Identifier: MIT
module cuda

// #flag directives for linking cuBLAS and cuDNN libraries.
// These are activate when `-d cuda` is passed at compile time.

// Link against CUDA driver (cuInit), runtime, cuBLAS and cuDNN shared libraries.
#flag linux -L/opt/cuda/lib64 -lcuda -lcudart -lcublas -lcudnn
#flag darwin -L/usr/local/cuda/lib -lcuda -lcudart -lcublas -lcudnn

// Include CUDA headers path.
#flag linux -I/opt/cuda/include
#flag darwin -I/usr/local/cuda/include

// On Arch Linux, cuDNN is in /usr/lib, not /opt/cuda.
// Also ensure we pick up the right library paths at runtime.
#flag linux -Wl,-rpath,/opt/cuda/lib64
#flag linux -Wl,-rpath,/usr/lib