module la

fn test_sparse_config_default_is_available_without_mpi() {
	mut config := SparseConfig.new()
	assert !config.verbose
	assert config.mumps_increase_of_working_space_pct == 100
	assert config.mumps_max_memory_per_processor == 2000
	config.set_umfpack_symmetry()
	config.set_mumps_ordering('amd')
	config.set_mumps_scaling('diag')
}
