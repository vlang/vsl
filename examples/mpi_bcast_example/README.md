# MPI Broadcast example

This example shows how to use the basic MPI functions in VSL.

## Quickstart

- Compile the example with:

```bash
v -o mpi_bcast_example -prod -cc mpirun main.v
```

- Run the example with:

```bash
$ mpirun -np 2 -H localhost:8 ./mpi_bcast_example
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
