module native

pub enum DeviceType as i64 {
	// device types - bitfield
	cpu = (1 << 0)
	gpu = (1 << 1)
	accelerator = (1 << 2)
	default_device = (1 << 0)
	all = 0xFFFFFFFF
}

pub const (
	// cl_mem_flags and cl_svm_mem_flags - bitfield
	mem_read_write            = (1 << 0)
	mem_write_only            = (1 << 1)
	mem_read_only             = (1 << 2)
	mem_use_host_ptr          = (1 << 3)
	mem_alloc_host_ptr        = (1 << 4)
	mem_copy_host_ptr         = (1 << 5)
	// reserved (1 << 6)
	mem_host_write_only       = (1 << 7)
	mem_host_read_only        = (1 << 8)
	mem_host_no_access        = (1 << 9)
	mem_svm_fine_grain_buffer = (1 << 10)
	mem_svm_atomics           = (1 << 11)
	mem_kernel_read_and_write = (1 << 12)

	device_name               = 0x102B
	device_vendor             = 0x102C
	driver_version            = 0x102D
	device_profile            = 0x102E
	device_version            = 0x102F
	device_extensions         = 0x1030
	device_platform           = 0x1031
	device_opencl_c_version   = 0x103D
	program_build_log         = 0x1183
)

pub const (
	exist_2_0_version      = C.CL_VERSION_2_0_EXISTS
	cl_mem_object_image2_d = C.CL_MEM_OBJECT_IMAGE2D
)
