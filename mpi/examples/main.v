module main

import vsl.mpi

fn example() ? {
	mpi.start()?

	defer {
		mpi.stop()
	}

	if mpi.world_rank() == 0 {
		println('Test MPI 01')
	}

	if mpi.world_size() != 3 {
		println('this test needs 3 processes')
	}

	n := 11
	mut x := []f64{len: n}
	id, sz := mpi.world_rank(), mpi.world_size()
	start, endp1 := (id * n) / sz, ((id + 1) * n) / sz
	for i := start; i < endp1; i++ {
		x[i] = f64(i)
	}

	// Communicator
	comm := mpi.new_communicator([])?

	// Barrier
	comm.barrier()

	// sum to root
	mut r := []f64{len: n}
	comm.reduce_sum(mut r, x)
	if id == 0 {
	}
}

fn main() {
	example() or { panic(err) }
}
