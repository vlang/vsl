module vcl

fn test_opencl_build_failure_code_is_signed() {
	code := ClInt(u32(0xfffffff5))
	assert code == build_program_failure
	assert ErrVCL(code).err().msg() == err_build_program_failure
}
