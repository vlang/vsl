module compute

// constants.v — shared workgroup size constants for all VCL compute kernels.

// local_size_1d is the work-group size for 1D kernels (must evenly divide global size or use guard).
pub const local_size_1d = 64

// local_size_2d is the work-group size per dimension for 2D kernels (16x16 = 256 threads).
pub const local_size_2d = 16
