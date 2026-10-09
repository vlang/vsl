"""Render the checked-in local GEMM comparison as SVG and PNG."""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import FuncFormatter, LogLocator


OUTPUT_DIR = Path(__file__).resolve().parent
SIZES = ("512×512", "1024×1024")
BENCHMARKS = {
    "VSL pure V": (7.82, 61.12),
    "VSL generic CBLAS": (36.17, 279.74),
    "NumPy · 2 OpenBLAS threads": (2.74, 18.96),
}
COLORS = {
    "VSL pure V": "#3478b8",
    "VSL generic CBLAS": "#e07a32",
    "NumPy · 2 OpenBLAS threads": "#2a9d75",
}


def main() -> None:
    plt.rcParams.update(
        {
            "font.family": "DejaVu Sans",
            "font.size": 10,
            "axes.titleweight": "bold",
            "axes.edgecolor": "#b8c2cc",
            "axes.labelcolor": "#344054",
            "text.color": "#172b4d",
            "xtick.color": "#475467",
            "ytick.color": "#475467",
            "svg.fonttype": "none",
        }
    )

    fig, ax = plt.subplots(figsize=(10.5, 5.8), layout="constrained")
    fig.set_facecolor("#ffffff")
    ax.set_facecolor("#ffffff")

    x = np.arange(len(SIZES), dtype=float)
    width = 0.22
    offsets = (-width, 0.0, width)
    for (label, timings), offset in zip(BENCHMARKS.items(), offsets):
        bars = ax.bar(
            x + offset,
            timings,
            width,
            color=COLORS[label],
            label=label,
            edgecolor="white",
            linewidth=0.8,
            zorder=3,
        )
        for bar, timing in zip(bars, timings):
            ax.annotate(
                f"{timing:g} ms",
                (bar.get_x() + bar.get_width() / 2, timing),
                xytext=(0, 5),
                textcoords="offset points",
                ha="center",
                va="bottom",
                fontsize=8.5,
                color="#344054",
                clip_on=False,
            )

    ax.set_yscale("log")
    ax.set_ylim(1, 650)
    ax.set_xticks(x, SIZES)
    ax.set_ylabel("Average execution time (ms, logarithmic scale)")
    ax.set_xlabel("Square matrix multiplication size")
    ax.set_title("VSL GEMM versus NumPy", loc="left", fontsize=17, pad=19)
    ax.text(
        0,
        1.015,
        "Single local run · Ryzen 9 5900X · V 0.5.2 · 2026-10-09",
        transform=ax.transAxes,
        fontsize=9.5,
        color="#667085",
        va="bottom",
    )
    ax.text(
        0,
        -0.2,
        "Pure V: -prod -O3 -march=native. System CBLAS: -prod -d vsl_blas_generic_cblas.\n"
        "NumPy 2.5.3 · two OpenBLAS threads. System CBLAS is distinct from VSL OpenBLAS.",
        transform=ax.transAxes,
        fontsize=8.5,
        color="#667085",
        va="top",
    )
    ax.yaxis.set_major_locator(LogLocator(base=10, numticks=5))
    ax.yaxis.set_major_formatter(FuncFormatter(lambda value, _: f"{value:g}"))
    ax.yaxis.set_minor_locator(LogLocator(base=10, subs=(2, 5), numticks=12))
    ax.grid(axis="y", which="major", color="#dfe5ec", linewidth=0.9, zorder=0)
    ax.grid(axis="y", which="minor", color="#eef1f5", linewidth=0.6, zorder=0)
    ax.spines[["top", "right"]].set_visible(False)
    ax.legend(
        loc="upper center",
        bbox_to_anchor=(0.5, 1.16),
        ncol=3,
        frameon=False,
        fontsize=9,
    )

    svg_path = OUTPUT_DIR / "gemm-comparison-2026-10-09.svg"
    fig.savefig(svg_path, facecolor="white")
    svg_lines = svg_path.read_text(encoding="utf-8").splitlines()
    svg_path.write_text("\n".join(line.rstrip() for line in svg_lines) + "\n", encoding="utf-8")
    fig.savefig(
        OUTPUT_DIR / "gemm-comparison-2026-10-09.png",
        dpi=220,
        facecolor="white",
    )


if __name__ == "__main__":
    main()
