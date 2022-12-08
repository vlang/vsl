module main

import vsl.float.float64
import vsl.mpi

mpi.initialize()?

defer {
	mpi.finalize()
}

if mpi.world_rank() == 0 {
	println('Test MPI 01')
}

println('Hello from rank ${mpi.world_rank()}')
println('The world has ${mpi.world_size()} processes')

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
comm.reduce_sum_f64(mut r, x)
if id == 0 {
	assertion := float64.arrays_tolerance(r, []f64{len: n, init: it}, 1e-17)
	println('ID: ${id} - Assertion: ${assertion}')
} else {
	assertion := float64.arrays_tolerance(r, []f64{len: n}, 1e-17)
	println('ID: ${id} - Assertion: ${assertion}')
}

r[0] = 123.0
comm.bcast_from_root_f64(r)
assertion := float64.arrays_tolerance(r, [123.0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 1e-17)
println('ID: ${id} - Assertion: ${assertion}')
