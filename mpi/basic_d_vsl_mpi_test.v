// vtest build: vsl_mpi?

module mpi

fn test_mpi_initialization_and_world_communicator() ! {
	initialize()!
	defer {
		finalize()
	}
	assert world_rank() == 0
	assert world_size() == 1
	communicator := Communicator.new([])!
	assert communicator.rank() == 0
	assert communicator.size() == 1
}
