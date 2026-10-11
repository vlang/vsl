#!/usr/bin/env python3
"""Matched SciPy BLAS daxpy baseline for VSL's f64 AXPY."""

from __future__ import annotations

import statistics
import time

import numpy as np
import scipy
from scipy.linalg import blas


VECTOR_SIZE = 1_048_576
WARMUPS = 3
ITERATIONS = 31
ALPHA = 1.5


def inputs() -> tuple[np.ndarray, np.ndarray]:
    indices = np.arange(VECTOR_SIZE, dtype=np.int64)
    x = ((indices % 127 - 63).astype(np.float64)) / 256.0
    initial_y = ((indices % 97 - 48).astype(np.float64)) / 128.0
    return x, initial_y


def main() -> None:
    x, initial_y = inputs()
    config = scipy.show_config(mode="dicts")
    blas_config = config["Build Dependencies"]["blas"]
    for _ in range(WARMUPS):
        output = initial_y.copy()
        blas.daxpy(x, output, a=ALPHA)

    samples_ms = []
    output = initial_y.copy()
    for _ in range(ITERATIONS):
        output = initial_y.copy()
        started = time.perf_counter_ns()
        output = blas.daxpy(x, output, a=ALPHA)
        samples_ms.append((time.perf_counter_ns() - started) / 1_000_000.0)

    expected = ALPHA * x + initial_y
    print(
        f"SciPy BLAS AXPY | SciPy {scipy.__version__} | NumPy {np.__version__} "
        f"| f64 | n={VECTOR_SIZE} | median {statistics.median(samples_ms):.3f} ms"
    )
    print(
        f"BLAS provider {blas_config['name']} {blas_config['version']} "
        f"| {blas_config['openblas configuration']} | threads=1"
    )
    print(
        f"checksum {np.sum(output, dtype=np.float64):.12f} "
        f"| max absolute error {np.max(np.abs(output - expected)):.3e}"
    )


if __name__ == "__main__":
    main()
