#!/usr/bin/env python3
"""Matched SciPy LAPACK baselines for VSL's double-precision routines."""

from __future__ import annotations

import statistics
import time

import numpy as np
import scipy
from scipy.linalg import lapack


SIZES = (64, 128)
WARMUPS = 2
ITERATIONS = 5


def general_matrix(n: int) -> np.ndarray:
    rows = np.arange(n, dtype=np.int64)[:, None]
    cols = np.arange(n, dtype=np.int64)[None, :]
    values = ((rows * 13 + cols * 17 + 3) % 29 - 14).astype(np.float64) / (4 * n)
    values[np.diag_indices(n)] += n + 2.0
    return np.asfortranarray(values)


def symmetric_matrix(n: int) -> np.ndarray:
    rows = np.arange(n, dtype=np.int64)[:, None]
    cols = np.arange(n, dtype=np.int64)[None, :]
    low = np.minimum(rows, cols)
    high = np.maximum(rows, cols)
    values = ((low * 13 + high * 17 + 3) % 29 - 14).astype(np.float64) / (4 * n)
    values[np.diag_indices(n)] = n + 2.0 + np.arange(n, dtype=np.float64) * 0.25
    return np.asfortranarray(values)


def rhs_vector(n: int) -> np.ndarray:
    return np.asfortranarray(((np.arange(n, dtype=np.int64) % 17 - 8).astype(np.float64) / 8.0).reshape(n, 1))


def execute(operation: str, n: int, general: np.ndarray, symmetric: np.ndarray, rhs: np.ndarray) -> float:
    source = symmetric if operation == "dpotrf" else general
    order = "F" if operation == "dgeqrf" else "C"
    a = np.array(source, order=order, copy=True)
    if operation == "dgesv":
        b = rhs.copy(order="F")
        _, _, solution, info = lapack.dgesv(a, b, overwrite_a=1, overwrite_b=1)
        if info != 0:
            raise RuntimeError(f"dgesv returned {info}")
        return float(np.sum(solution, dtype=np.float64))
    if operation == "dgetrf":
        factors, _, info = lapack.dgetrf(a, overwrite_a=1)
        if info != 0:
            raise RuntimeError(f"dgetrf returned {info}")
        return float(np.trace(factors))
    if operation == "dpotrf":
        factor, info = lapack.dpotrf(a, lower=1, clean=0, overwrite_a=1)
        if info != 0:
            raise RuntimeError(f"dpotrf returned {info}")
        return float(np.trace(factor))
    if operation == "dgeqrf":
        factors, tau, _, info = lapack.dgeqrf(a, overwrite_a=1)
        if info != 0:
            raise RuntimeError(f"dgeqrf returned {info}")
        return float(np.trace(factors) + np.sum(tau, dtype=np.float64))
    raise ValueError(f"unsupported LAPACK operation {operation}")


def benchmark(operation: str, n: int) -> None:
    general = general_matrix(n)
    symmetric = symmetric_matrix(n)
    rhs = rhs_vector(n)
    checksum = 0.0
    for _ in range(WARMUPS):
        checksum = execute(operation, n, general, symmetric, rhs)
    samples_ms = []
    for _ in range(ITERATIONS):
        started = time.perf_counter_ns()
        checksum = execute(operation, n, general, symmetric, rhs)
        samples_ms.append((time.perf_counter_ns() - started) / 1_000_000.0)
    print(f"{operation} {n}x{n} | median {statistics.median(samples_ms):.3f} ms | checksum {checksum:.12f}")


def main() -> None:
    print(f"SciPy LAPACK comparison | SciPy {scipy.__version__} | f64 | median of {ITERATIONS}")
    for n in SIZES:
        for operation in ("dgesv", "dgetrf", "dpotrf", "dgeqrf"):
            benchmark(operation, n)


if __name__ == "__main__":
    main()
