#version 450

layout(local_size_x = 256, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0) readonly buffer BufSrc {
	float src[];
};
layout(set = 0, binding = 1) writeonly buffer BufDst {
	float dst[];
};

const float alpha = 1.6732632423543772;
const float scale = 1.0507009873554805;

void main() {
	uint i = gl_GlobalInvocationID.x;
	float x = src[i];
	dst[i] = scale * (x > 0.0 ? x : alpha * (exp(x) - 1.0));
}
