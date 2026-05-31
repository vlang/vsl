#!/usr/bin/env python3
"""NumPy timing baselines for VSL vs_numpy benchmarks."""

import sys
import timeit

import numpy as np


def bench_matmul():
    for n in (128, 256, 512, 1024):
        a = np.random.rand(n, n)
        b = np.random.rand(n, n)
        sec = timeit.timeit(lambda: a @ b, number=5) / 5.0
        gflops = 2 * n * n * n / sec / 1e9
        print(f"numpy gemm {n}x{n} | {sec * 1000:.2f} ms | {gflops:.3f} GFLOPS")


def bench_gemv():
    for n in (128, 256, 512, 1024):
        a = np.random.rand(n, n)
        x = np.random.rand(n)
        sec = timeit.timeit(lambda: a @ x, number=5) / 5.0
        gflops = 2 * n * n / sec / 1e9
        print(f"numpy gemv {n}x{n} | {sec * 1000:.2f} ms | {gflops:.3f} GFLOPS")


def bench_conv2d():
    x = np.random.rand(1, 1, 32, 32)
    w = np.random.rand(1, 1, 3, 3)

    def run():
        # correlation-style conv (matches VSL bench layout)
        out_h = 32 - 3 + 1
        out_w = 32 - 3 + 1
        y = np.zeros((1, 1, out_h, out_w))
        for oh in range(out_h):
            for ow in range(out_w):
                y[0, 0, oh, ow] = (x[0, 0, oh : oh + 3, ow : ow + 3] * w[0, 0]).sum()
        return y

    sec = timeit.timeit(run, number=5) / 5.0
    print(f"numpy conv2d 1x1x32x32 | {sec * 1000:.2f} ms | -")


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
