module la

// gemm_vulkan is available when compiling with `-d vulkan`.
pub fn gemm_vulkan(_ voidptr, _ &Matrix[f64], _ &Matrix[f64]) !&Matrix[f64] {
	return error('la.gemm_vulkan: vulkan backend not enabled')
}
