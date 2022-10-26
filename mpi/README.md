# Message Passing Interface for parallel computing

The `mpi` package is a simplified wrapper to the [OpenMPI](https://www.open-mpi.org) C library designed
to support algorithms for parallel computing.

This library allows a program to support parallel computations over the network.
This is otherwise known as a single-program multiple-data (SPMD) architecture.

The mpi routines supported include:

- `start()` [deprecated] 
- `initialize()`
- `finalize()`
- `stop()` [deprecated]
- `world_rank() int`
- `world_size() int`
- `is_on() bool`
- `new_communicator(ranks []int) ?&Communicator`

The methods for the Communicator support i32, u32, i64, u64, f32 and f64
data types.  These allow exchange of arrays of data between processors
or broadcast from the first processor (the root node with rank == 0).

A program must issue a send (on one rank) and matching receive on another
rank or all ranks, depending on the nature of the method.  Use `barrier()`
to ensure all ranks are synchronized at that point.

Support is provided for Linux and the BSDs.

Once you have created a Communicator, you can use these methods,
where the `<type>` is one of the above i32, u32, i64, u64, f32 or f64:

| Method | Result |
|--------|--------|
| `comm.rank()` | Rank of the processor within the World or group |
| `comm.size()` | Size of the list of processors |
| `comm.abort()` | Abort the MPI program |
| `comm.barrier()` | Resynchronize all processors to this point |
| `comm.send_i32( vals []i32, to_rank int)` | Send an array to one rank |
| `comm.recv_i32( vals []i32, from_rank int)` | Receive array from one rank |
| `comm.send_u32( ... )` | As above for unsigned 32-bit integers |
| `comm.send_i64( ... )` | As above for signed 64-bit integers |
| `comm.send_u64( ... )` | As above for unsigned 64-bit integers |
| `comm.send_f32( ... )` | As above for 32-bit floats |
| `comm.send_f64( ... )` | As above for 64-bit floats |
| `comm.send_one_<type>( val <type>, to_rank int)` | Send one value to one rank |
| `comm.recv_one_<type>( from_rank int) <type>` | Returns one value from one rank |
| `comm.bcast_from_root_<type>(vals []<type>)` | Copy the values to all processors |
| `comm.reduce_sum_<type>(mut dest []<type>, orig []<type>)` | Sum orig array elements to dest on rank 0 |
| `comm.all_reduce_sum_<type>(mut dest []<type>, orig []<type>)` | Sum orig array elements to dest on all ranks|
| `comm.reduce_min_<type>(mut dest []<type>, orig []<type>)` | Minimize orig array elements to dest on rank 0|
| `comm.all_reduce_min_<type>(mut dest []<type>, orig []<type>)` | Minimize orig array elements to dest on all ranks|
| `comm.reduce_max_<type>(mut dest []<type>, orig []<type>)` | Maximize orig array elements to dest on rank 0|
| `comm.all_reduce_max_<type>(mut dest []<type>, orig []<type>)` | Maximize orig array elements to dest on all ranks|

As an example

```v
/// compute some simple array results using OpenMPI
import vsl.mpi

mut shortd := [1.0, 3.0, 5.0] // all ranks have this array
mpi.initialize()?

println('Hello from rank $mpi.world_rank() of  $mpi.world_size() processes')

// communicator

comm := mpi.new_communicator([])?
println('Communicator rank $comm.rank() of $comm.size() processors ')

// barrier

comm.barrier()

// broadcast and verify

if mpi.world_rank() > 0 {
	shortd[2] = 77.0 // only non-root (rank not 0) has this value
}
comm.bcast_from_root_f64(shortd) // send original to all
if shortd == [1.0, 3.0, 5.0] {
	println('  $comm.rank() bcast_from_root success')
}
comm.barrier()

// reduce and verify

mut reduced := []f64{len: 3}
ansr := shortd.map(it * comm.size())
comm.reduce_sum_f64(mut reduced, shortd)
if reduced == ansr { // only true on rank 0
	println('  $comm.rank() reduce_sum success')
}
comm.barrier()

// allreduce and verify

ansar := [0.0, 2.0, 3.0].map(it * f64(mpi.world_size()))
shortd = [0.0, 2.0, 3.0].map(it * f64(1 + mpi.world_rank()))
comm.all_reduce_max_f64(mut reduced, shortd)
if reduced == ansar { // true on all ranks
	println('  $comm.rank() allreduce_max succes')
}

mpi.finalize()
```


The results should look like this for two processors:

```
$ mpirun -np 2 -H localhost:8 ./t
Hello from rank 0 of  2 processes
Hello from rank 1 of  2 processes
Communicator rank 1 of 2 processors
Communicator rank 0 of 2 processors
  1 bcast_from_root success
  0 bcast_from_root success
  0 reduce_sum success
  1 allreduce_max success
  0 allreduce_max success
```
