module mpi

import os

fn test_mpi_initialization_smoke() ! {
	mpirun_path := os.find_abs_path_of_executable('mpirun') or { '' }
	if mpirun_path == '' {
		eprintln('skipping MPI smoke test: mpirun is not installed')
		return
	}

	initialize()!
	defer {
		finalize()
	}
	assert world_rank() == 0
	assert world_size() >= 1
	communicator := Communicator.new([])!
	assert communicator.rank() == 0
	assert communicator.size() == world_size()
}
