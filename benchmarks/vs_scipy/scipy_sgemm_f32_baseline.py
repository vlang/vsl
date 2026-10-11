"""Matched SciPy low-level BLAS baseline for VSL's f32 SGEMM benchmark."""

import os
import statistics
import time

import numpy as np
import scipy
from scipy.linalg.blas import sgemm


def main() -> None:
    n = 512
    indexes = np.arange(n * n, dtype=np.int64)
    a = (((indexes * 17) % 101).astype(np.float32) / np.float32(101)).reshape(n, n)
    b = (((indexes * 13) % 97).astype(np.float32) / np.float32(97)).reshape(n, n)
    a_fortran = np.asfortranarray(a)
    b_fortran = np.asfortranarray(b)
    output = np.empty((n, n), dtype=np.float32, order="F")

    warmups = 3
    iterations = 31
    for _ in range(warmups):
        result = sgemm(1.0, a_fortran, b_fortran, beta=0.0, c=output, overwrite_c=1)
    if not np.shares_memory(result, output):
        raise RuntimeError("SciPy allocated a separate SGEMM output instead of reusing c")

    samples_ms: list[float] = []
    for _ in range(iterations):
        started = time.perf_counter_ns()
        result = sgemm(1.0, a_fortran, b_fortran, beta=0.0, c=output, overwrite_c=1)
        samples_ms.append((time.perf_counter_ns() - started) / 1_000_000.0)

    config = scipy.show_config(mode="dicts")
    blas_config = config["Build Dependencies"]["blas"]
    checksum = np.sum(result, dtype=np.float64)
    print(
        f"SciPy {scipy.__version__} low-level f32 SGEMM {n}x{n} "
        f"median={statistics.median(samples_ms):.3f} ms"
    )
    print(
        f"BLAS provider {blas_config['name']} {blas_config['version']} "
        f"| {blas_config['openblas configuration']} "
        f"| threads={os.environ.get('OPENBLAS_NUM_THREADS', 'default')}"
    )
    print(f"checksum={checksum:.6f}")


if __name__ == "__main__":
    main()
