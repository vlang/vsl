#!/usr/bin/env bash
set -euo pipefail

shader_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
vulkan_dir=$(dirname "$shader_dir")
repo_dir=$(dirname "$vulkan_dir")
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

output="$vulkan_dir/spv_activations.v"
printf 'module vulkan\n\n' > "$output"

for activation in softplus selu hardswish; do
	glslangValidator -S comp -V "$shader_dir/$activation.glsl" -o "$tmp_dir/$activation.spv"
	python3 "$shader_dir/embed_spv.py" "$tmp_dir/$activation.spv" >> "$output"
done

printf 'Generated %s\n' "$output"
