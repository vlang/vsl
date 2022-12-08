# MPI Basic example

This example shows how to use the basic MPI functions in VSL.

## Quickstart

- Compile the example with:

```bash
v -o mpi_basic_example -prod -cc mpirun main_not_ci.v
```

- Run the example with:

```bash
$ mpirun -np 2 -H localhost:8 ./mpi_basic_example
Test MPI 01
Hello from rank 0
The world has 2 processes
Hello from rank 1
The world has 2 processes
ID: 0 - Assertion: true
ID: 0 - Assertion: true
ID: 1 - Assertion: true
ID: 1 - Assertion: true
```
