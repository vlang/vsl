#!/usr/bin/env python3
"""Embed SPIR-V binaries as V u32 arrays. Usage: embed_spv.py NAME.spv > fragment.v"""
import struct
import sys

def main() -> None:
    if len(sys.argv) != 2:
        print("usage: embed_spv.py file.spv", file=sys.stderr)
        sys.exit(1)
    data = open(sys.argv[1], "rb").read()
    if len(data) % 4 != 0:
        print("SPIR-V size must be multiple of 4", file=sys.stderr)
        sys.exit(1)
    words = struct.unpack(f"<{len(data) // 4}I", data)
    name = sys.argv[1].replace(".spv", "").split("/")[-1]
    const = name.replace("-", "_") + "_spv"
    print(f"// {name}.spv — {len(data)} bytes, {len(words)} u32 words")
    print(f"pub const {const} = [")
    for i in range(0, len(words), 4):
        chunk = words[i : i + 4]
        line = ", ".join(f"u32(0x{w:08x})" for w in chunk)
        print(f"\t{line},")
    print("]")

if __name__ == "__main__":
    main()
