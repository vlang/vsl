#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(std430, binding = 0) readonly buffer ABuffer {
	float values[];
} A;

layout(std430, binding = 1) readonly buffer BBuffer {
	float values[];
} B;

layout(std430, binding = 2) buffer CBuffer {
	float values[];
} C;

layout(std430, binding = 3) readonly buffer ParamsBuffer {
	uint values[];
} params;

shared float tile_a[32][32];
shared float tile_b[32][32];

void main() {
	uint row0 = gl_WorkGroupID.y * 32 + gl_LocalInvocationID.y;
	uint row1 = row0 + 16;
	uint col0 = gl_WorkGroupID.x * 32 + gl_LocalInvocationID.x;
	uint col1 = col0 + 16;
	uint local_row = gl_LocalInvocationID.y;
	uint local_col = gl_LocalInvocationID.x;
	uint m = params.values[0];
	uint n = params.values[1];
	uint k = params.values[2];
	float sum00 = 0.0;
	float sum01 = 0.0;
	float sum10 = 0.0;
	float sum11 = 0.0;

	for (uint tile_start = 0; tile_start < k; tile_start += 32) {
		uint a_col0 = tile_start + local_col;
		uint a_col1 = a_col0 + 16;
		uint b_row0 = tile_start + local_row;
		uint b_row1 = b_row0 + 16;
		tile_a[local_row][local_col] = row0 < m && a_col0 < k ? A.values[row0 * k + a_col0] : 0.0;
		tile_a[local_row + 16][local_col] = row1 < m && a_col0 < k ? A.values[row1 * k + a_col0] : 0.0;
		tile_a[local_row][local_col + 16] = row0 < m && a_col1 < k ? A.values[row0 * k + a_col1] : 0.0;
		tile_a[local_row + 16][local_col + 16] = row1 < m && a_col1 < k ? A.values[row1 * k + a_col1] : 0.0;
		tile_b[local_row][local_col] = b_row0 < k && col0 < n ? B.values[b_row0 * n + col0] : 0.0;
		tile_b[local_row][local_col + 16] = b_row0 < k && col1 < n ? B.values[b_row0 * n + col1] : 0.0;
		tile_b[local_row + 16][local_col] = b_row1 < k && col0 < n ? B.values[b_row1 * n + col0] : 0.0;
		tile_b[local_row + 16][local_col + 16] = b_row1 < k && col1 < n ? B.values[b_row1 * n + col1] : 0.0;
		barrier();
		for (uint inner = 0; inner < 32; inner++) {
			float a0 = tile_a[local_row][inner];
			float a1 = tile_a[local_row + 16][inner];
			float b0 = tile_b[inner][local_col];
			float b1 = tile_b[inner][local_col + 16];
			sum00 += a0 * b0;
			sum01 += a0 * b1;
			sum10 += a1 * b0;
			sum11 += a1 * b1;
		}
		barrier();
	}

	if (row0 < m && col0 < n) {
		C.values[row0 * n + col0] = sum00;
	}
	if (row0 < m && col1 < n) {
		C.values[row0 * n + col1] = sum01;
	}
	if (row1 < m && col0 < n) {
		C.values[row1 * n + col0] = sum10;
	}
	if (row1 < m && col1 < n) {
		C.values[row1 * n + col1] = sum11;
	}
}
