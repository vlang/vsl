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

shared float tile_a[64][32];
shared float tile_b[32][64];

void main() {
	uint local_index = gl_LocalInvocationID.y * 16 + gl_LocalInvocationID.x;
	uint m = params.values[0];
	uint n = params.values[1];
	uint k = params.values[2];
	uint row_base = gl_WorkGroupID.y * 64;
	uint col_base = gl_WorkGroupID.x * 64;
	float accum[4][4];
	for (uint r = 0; r < 4; r++) {
		for (uint c = 0; c < 4; c++) {
			accum[r][c] = 0.0;
		}
	}

	for (uint tile_start = 0; tile_start < k; tile_start += 32) {
		for (uint chunk = 0; chunk < 8; chunk++) {
			uint index = local_index + chunk * 256;
			uint a_row = index / 32;
			uint a_col = index % 32;
			uint global_a_row = row_base + a_row;
			uint global_a_col = tile_start + a_col;
			tile_a[a_row][a_col] = global_a_row < m && global_a_col < k
				? A.values[global_a_row * k + global_a_col] : 0.0;

			uint b_row = index / 64;
			uint b_col = index % 64;
			uint global_b_row = tile_start + b_row;
			uint global_b_col = col_base + b_col;
			tile_b[b_row][b_col] = global_b_row < k && global_b_col < n
				? B.values[global_b_row * n + global_b_col] : 0.0;
		}
		barrier();
		for (uint inner = 0; inner < 32; inner++) {
			float a[4];
			float b[4];
			for (uint r = 0; r < 4; r++) {
				a[r] = tile_a[gl_LocalInvocationID.y + r * 16][inner];
			}
			for (uint c = 0; c < 4; c++) {
				b[c] = tile_b[inner][gl_LocalInvocationID.x + c * 16];
			}
			for (uint r = 0; r < 4; r++) {
				for (uint c = 0; c < 4; c++) {
					accum[r][c] += a[r] * b[c];
				}
			}
		}
		barrier();
	}

	for (uint r = 0; r < 4; r++) {
		uint row = row_base + gl_LocalInvocationID.y + r * 16;
		for (uint c = 0; c < 4; c++) {
			uint col = col_base + gl_LocalInvocationID.x + c * 16;
			if (row < m && col < n) {
				C.values[row * n + col] = accum[r][c];
			}
		}
	}
}
