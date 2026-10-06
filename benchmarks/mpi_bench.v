module main

import time
import vsl.mpi

const scalar_iterations = 1000
const large_iterations = 100
const large_message_size = 1024

fn main() {
	mpi.initialize() or {
		eprintln('MPI initialization failed: ${err}')
		exit(1)
	}
	defer {
		mpi.finalize()
	}
	comm := mpi.Communicator.new([]) or {
		eprintln('MPI communicator creation failed: ${err}')
		exit(1)
	}
	if comm.size() < 2 {
		eprintln('Run this benchmark with at least two MPI processes')
		exit(1)
	}

	if comm.rank() == 0 {
		println('MPI latency benchmark on ${comm.size()} ranks')
		println('operation,elements,iterations,mean_us')
	}
	benchmark_ping_pong(comm, 1, scalar_iterations)
	benchmark_ping_pong(comm, large_message_size, large_iterations)
	benchmark_broadcast(comm, 1, scalar_iterations)
	benchmark_broadcast(comm, large_message_size, large_iterations)
	benchmark_reduce(comm, 1, scalar_iterations)
	benchmark_reduce(comm, large_message_size, large_iterations)
	comm.barrier()
}

fn benchmark_ping_pong(comm &mpi.Communicator, size int, iterations int) {
	mut payload := []i64{len: size, init: i64(comm.rank())}
	comm.barrier()
	mut elapsed_ns := u64(0)
	if comm.rank() == 0 {
		start := time.sys_mono_now()
		for _ in 0 .. iterations {
			comm.send_i64(payload, 1)
			comm.recv_i64(payload, 1)
		}
		elapsed_ns = time.sys_mono_now() - start
		if payload[0] != 0 {
			panic('send/receive round-trip changed the payload')
		}
	} else if comm.rank() == 1 {
		for _ in 0 .. iterations {
			comm.recv_i64(payload, 0)
			comm.send_i64(payload, 0)
		}
	}
	comm.barrier()
	if comm.rank() == 0 {
		print_result('send_recv_roundtrip', size, iterations, elapsed_ns)
	}
}

fn benchmark_broadcast(comm &mpi.Communicator, size int, iterations int) {
	mut values := []i64{len: size, init: if comm.rank() == 0 { i64(7) } else { i64(-1) }}
	comm.barrier()
	mut elapsed_ns := u64(0)
	start := time.sys_mono_now()
	for _ in 0 .. iterations {
		comm.bcast_from_root_i64(values)
	}
	if comm.rank() == 0 {
		elapsed_ns = time.sys_mono_now() - start
	}
	if values[0] != 7 {
		panic('broadcast did not copy the root payload')
	}
	comm.barrier()
	if comm.rank() == 0 {
		print_result('broadcast', size, iterations, elapsed_ns)
	}
}

fn benchmark_reduce(comm &mpi.Communicator, size int, iterations int) {
	original := []i64{len: size, init: i64(comm.rank() + 1)}
	mut destination := []i64{len: size}
	comm.barrier()
	mut elapsed_ns := u64(0)
	start := time.sys_mono_now()
	for _ in 0 .. iterations {
		comm.reduce_sum_i64(mut destination, original)
	}
	if comm.rank() == 0 {
		elapsed_ns = time.sys_mono_now() - start
		expected := i64(comm.size() * (comm.size() + 1) / 2)
		for value in destination {
			if value != expected {
				panic('reduction result mismatch: got ${value}, expected ${expected}')
			}
		}
	}
	comm.barrier()
	if comm.rank() == 0 {
		print_result('reduce_sum', size, iterations, elapsed_ns)
	}
}

fn print_result(operation string, size int, iterations int, elapsed_ns u64) {
	mean_us := f64(elapsed_ns) / f64(iterations) / 1000.0
	println('${operation},${size},${iterations},${mean_us:.3f}')
}
