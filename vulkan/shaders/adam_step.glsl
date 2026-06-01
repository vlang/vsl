#version 450

layout(local_size_x = 256, local_size_y = 1, local_size_z = 1) in;

// p[0]=beta1, p[1]=beta2, p[2]=lr_t, p[3]=epsilon
layout(set = 0, binding = 0) readonly buffer BufGrad {
	float grad[];
};
layout(set = 0, binding = 1) buffer BufTheta {
	float theta[];
};
layout(set = 0, binding = 2) buffer BufM {
	float m[];
};
layout(set = 0, binding = 3) buffer BufV {
	float v[];
};
layout(set = 0, binding = 4) readonly buffer BufParams {
	float p[];
};

void main() {
	uint i = gl_GlobalInvocationID.x;
	float g = grad[i];
	float beta1 = p[0];
	float beta2 = p[1];
	float lr = p[2];
	float eps = p[3];
	float mi = beta1 * m[i] + (1.0 - beta1) * g;
	float vi = beta2 * v[i] + (1.0 - beta2) * g * g;
	m[i] = mi;
	v[i] = vi;
	theta[i] -= lr * mi / (sqrt(vi) + eps);
}
