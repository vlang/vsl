"""Comparable NumPy real FFT timings for benchmarks/fft_bench.v."""

from time import perf_counter_ns

import numpy as np


SIZES = (256, 1024, 4096, 16384)
ITERATIONS = {256: 100, 1024: 50, 4096: 20, 16384: 10}
WARMUP_RUNS = 3


def signal(size: int) -> np.ndarray:
    x = np.arange(size, dtype=np.float64) / size
    return np.sin(2.0 * np.pi * 7.0 * x) + 0.25 * np.cos(2.0 * np.pi * 31.0 * x)


def main() -> None:
    print("NumPy real f64 rfft forward transform")
    print("size,iterations,mean_us")
    for size in SIZES:
        source = signal(size)
        for _ in range(WARMUP_RUNS):
            np.fft.rfft(source)
        elapsed_ns = 0
        iterations = ITERATIONS[size]
        for _ in range(iterations):
            start = perf_counter_ns()
            np.fft.rfft(source)
            elapsed_ns += perf_counter_ns() - start
        mean_us = elapsed_ns / iterations / 1000.0
        print(f"{size},{iterations},{mean_us:.3f}")

    print("NumPy real f32-input rfft forward transform (complex128 output)")
    print("size,iterations,mean_us")
    for size in SIZES:
        source = signal(size).astype(np.float32)
        for _ in range(WARMUP_RUNS):
            np.fft.rfft(source)
        elapsed_ns = 0
        iterations = ITERATIONS[size]
        for _ in range(iterations):
            start = perf_counter_ns()
            np.fft.rfft(source)
            elapsed_ns += perf_counter_ns() - start
        mean_us = elapsed_ns / iterations / 1000.0
        print(f"{size},{iterations},{mean_us:.3f}")


if __name__ == "__main__":
    main()
