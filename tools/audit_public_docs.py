#!/usr/bin/env python3
"""Audit public V declarations for immediate `//` documentation comments."""

from __future__ import annotations

import argparse
import subprocess
from dataclasses import dataclass
from pathlib import Path


PUBLIC_KINDS = ("fn", "struct", "interface", "enum", "type", "const")
DEFAULT_EXCLUDES = (
    "examples/**",
    "benchmarks/**",
    "**/*_test.v",
    "**/spv*.v",
    "**/_cfun*.v",
    "**/_ctypes*.v",
    "**/*.c.v",
)


@dataclass
class MissingDoc:
    path: str
    line: int
    kind: str
    declaration: str


def git_files(root: Path) -> list[str]:
    out = subprocess.check_output(["git", "ls-files", "*.v"], cwd=root, text=True)
    return [line for line in out.splitlines() if line]


def is_excluded(path: str, patterns: tuple[str, ...]) -> bool:
    p = Path(path)
    return any(p.match(pattern) for pattern in patterns)


def declaration_kind(line: str) -> str | None:
    stripped = line.lstrip()
    if not stripped.startswith("pub "):
        return None
    rest = stripped[4:].lstrip()
    for kind in PUBLIC_KINDS:
        if rest == kind or rest.startswith(kind + " "):
            return kind
    return None


def audit(root: Path, include: list[str], excludes: tuple[str, ...]) -> list[MissingDoc]:
    missing: list[MissingDoc] = []
    for rel in git_files(root):
        if include and not any(Path(rel).match(pattern) for pattern in include):
            continue
        if is_excluded(rel, excludes):
            continue
        lines = (root / rel).read_text(errors="replace").splitlines()
        for idx, line in enumerate(lines):
            kind = declaration_kind(line)
            if kind is None:
                continue
            prev_idx = idx - 1
            while prev_idx >= 0 and lines[prev_idx].lstrip().startswith("@["):
                prev_idx -= 1
            prev = lines[prev_idx].lstrip() if prev_idx >= 0 else ""
            if prev.startswith("//"):
                continue
            missing.append(MissingDoc(rel, idx + 1, kind, line.strip()))
    return missing


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=".", help="repository root")
    parser.add_argument(
        "--include",
        action="append",
        default=[],
        help="glob of files to include; may be repeated",
    )
    parser.add_argument(
        "--exclude",
        action="append",
        default=[],
        help="additional glob of files to exclude; may be repeated",
    )
    parser.add_argument("--summary", action="store_true", help="print only summary")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    excludes = DEFAULT_EXCLUDES + tuple(args.exclude)
    missing = audit(root, args.include, excludes)

    if args.summary:
        print(f"missing_public_docs={len(missing)}")
    else:
        for item in missing:
            print(f"{item.path}:{item.line}: {item.kind}: {item.declaration}")
        print(f"\nMissing public docs: {len(missing)}")
    return 1 if missing else 0


if __name__ == "__main__":
    raise SystemExit(main())
