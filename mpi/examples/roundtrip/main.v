module main

import vsl.mpi

fn main() {
	mpi.initialize() or { panic(err) }
	defer {
		mpi.finalize()
	}
	communicator := mpi.Communicator.new([]) or { panic(err) }
	if communicator.rank() == 0 {
		communicator.send_i32([]i32{}, 1)
		communicator.send_u32([]u32{}, 1)
		communicator.send_i64([]i64{}, 1)
		communicator.send_u64([]u64{}, 1)
		communicator.send_f32([]f32{}, 1)
		communicator.send_f64([]f64{}, 1)
		communicator.send_i32([i32(13), 21, 34], 1)
	} else if communicator.rank() == 1 {
		communicator.recv_i32([]i32{}, 0)
		communicator.recv_u32([]u32{}, 0)
		communicator.recv_i64([]i64{}, 0)
		communicator.recv_u64([]u64{}, 0)
		communicator.recv_f32([]f32{}, 0)
		communicator.recv_f64([]f64{}, 0)
		mut received := [i32(0), 0, 0]
		communicator.recv_i32(received, 0)
		assert received == [i32(13), 21, 34]
	}
	communicator.barrier()
}
