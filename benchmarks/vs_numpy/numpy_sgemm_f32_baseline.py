"""Matched NumPy baseline for the pure-V VSL f32 SGEMM benchmark."""

import time

import numpy as np


def main() -> None:
    n = 512
    indexes = np.arange(n * n, dtype=np.int64)
    a = (((indexes * 17) % 101).astype(np.float32) / np.float32(101)).reshape(n, n)
    b = (((indexes * 13) % 97).astype(np.float32) / np.float32(97)).reshape(n, n)
    output = np.empty((n, n), dtype=np.float32)

    for _ in range(3):
        np.matmul(a, b, out=output)

    samples: list[float] = []
    for _ in range(7):
        started = time.perf_counter_ns()
        np.matmul(a, b, out=output)
        samples.append((time.perf_counter_ns() - started) / 1_000_000.0)

    print(
        f"NumPy {np.__version__} f32 SGEMM {n}x{n} "
        f"mean={sum(samples) / len(samples):.3f} ms "
        f"checksum={output.ravel()[n * n // 2]:.6f}"
    )


if __name__ == "__main__":
    main()
