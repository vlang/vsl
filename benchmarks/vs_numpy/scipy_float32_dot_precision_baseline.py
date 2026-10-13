#!/usr/bin/env python3
"""SciPy BLAS f32 dot baseline for VSL widened-accumulation benchmark."""

import platform
import time
import math

import numpy as np
import scipy
from scipy.linalg.blas import sdot


ELEMENTS = 1_048_576
WARMUPS = 3
ITERATIONS = 9
indices = np.arange(ELEMENTS, dtype=np.int64)
x = ((indices % 997) - 498).astype(np.float32) * np.float32(1.0 / 512.0)
y = ((indices % 991) - 495).astype(np.float32) * np.float32(1.0 / 1024.0)
products = (x * y).astype(np.float64)
reference = math.fsum(float(product) for product in products)
reference_f32 = np.float32(reference)

for _ in range(WARMUPS):
    sdot(x, y)

samples = []
for _ in range(ITERATIONS):
    start = time.perf_counter_ns()
    checksum = sdot(x, y)
    samples.append((time.perf_counter_ns() - start) / 1_000_000.0)

samples.sort()
print(
    f"SciPy {scipy.__version__} BLAS sdot | NumPy {np.__version__} | "
    f"CPU={platform.processor() or platform.machine()} | elements={ELEMENTS} "
    f"median_ms={samples[len(samples) // 2]:.3f} sdot={float(checksum):.9f} "
    f"numpy_dot={float(np.dot(x, y)):.9f} f64_reference={reference:.12f} "
    f"rounded_f32_reference={float(reference_f32):.9f}"
)
