# MPI typed array round trip

Send empty arrays of each supported scalar type followed by a populated `i32` array from rank 0 to rank 1, then synchronize all ranks with a barrier.

## Run

From `~/.vmodules` with an MPI implementation installed:

```sh
mpirun -n 2 v run ./vsl/mpi/examples/roundtrip/main.v
```

## Notes

The example requires at least two MPI ranks. Rank 1 asserts that the received integer values match the sent values.
