#version 450

layout(local_size_x = 256, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0) readonly buffer BufSrc {
	float src[];
};
layout(set = 0, binding = 1) writeonly buffer BufDst {
	float dst[];
};

void main() {
	uint i = gl_GlobalInvocationID.x;
	dst[i] = sqrt(src[i]);
}
