module main

import vsl.mpi

fn main() {
	mpi.initialize() or { panic(err) }
	defer {
		mpi.finalize()
	}
	communicator := mpi.Communicator.new([]) or { panic(err) }
	if communicator.rank() == 0 {
		communicator.send_i32([i32(13), 21, 34], 1)
	} else if communicator.rank() == 1 {
		mut received := [i32(0), 0, 0]
		communicator.recv_i32(received, 0)
		assert received == [i32(13), 21, 34]
	}
	communicator.barrier()
}
