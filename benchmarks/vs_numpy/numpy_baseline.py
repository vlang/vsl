#!/usr/bin/env python3
"""NumPy timing baselines for VSL vs_numpy benchmarks."""

import sys
import time
import timeit

import numpy as np


def bench_matmul():
    for n in (128, 256, 512, 1024):
        i, j = np.indices((n, n), dtype=np.int64)
        a = ((i + j) % 7).astype(np.float64) * 0.01
        b = ((i * j) % 5).astype(np.float64) * 0.02
        def run():
            return a @ b
        for _ in range(2):
            result = run()
        samples_ms = []
        for _ in range(5):
            started = time.perf_counter_ns()
            result = run()
            samples_ms.append((time.perf_counter_ns() - started) / 1_000_000.0)
        average_ms = sum(samples_ms) / len(samples_ms)
        gflops = 2 * n**3 / (average_ms * 1_000_000.0)
        print(f"numpy gemm {n}x{n} | {average_ms:.2f} ms | {gflops:.3f} GFLOPS")


def bench_gemv():
    for n in (128, 256, 512, 1024):
        a = np.random.rand(n, n)
        x = np.random.rand(n)
        sec = timeit.timeit(lambda: a @ x, number=5) / 5.0
        gflops = 2 * n * n / sec / 1e9
        print(f"numpy gemv {n}x{n} | {sec * 1000:.2f} ms | {gflops:.3f} GFLOPS")


def bench_conv2d():
    input_values = np.arange(32 * 32, dtype=np.int64)
    x = ((input_values % 17).astype(np.float64) * 0.01).reshape(1, 1, 32, 32)
    kernel_values = np.arange(3 * 3, dtype=np.int64)
    weights = (((kernel_values % 5) + 1).astype(np.float64) * 0.1).reshape(1, 1, 3, 3)

    def run():
        windows = np.lib.stride_tricks.sliding_window_view(x, (3, 3), axis=(2, 3))
        return np.einsum("nchwkl,ockl->nohw", windows, weights, optimize=True)

    for _ in range(2):
        output = run()
    samples_ms = []
    for _ in range(5):
        started = time.perf_counter_ns()
        output = run()
        samples_ms.append((time.perf_counter_ns() - started) / 1_000_000.0)
    average_ms = sum(samples_ms) / len(samples_ms)
    checksum = float(np.sum(output, dtype=np.float64))
    print(f"numpy conv2d 1x1x32x32 | {average_ms:.6f} ms | checksum={checksum:.12f}")


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "matmul"
    if cmd == "matmul":
        bench_matmul()
    elif cmd == "gemv":
        bench_gemv()
    elif cmd == "conv2d":
        bench_conv2d()
    else:
        print(f"unknown: {cmd}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
