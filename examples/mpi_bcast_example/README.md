# MPI with VSL in V Tutorial

## Introduction

Message Passing Interface (MPI) is a standard for parallel programming in distributed
computing environments. This tutorial will guide you through using `vsl.mpi`, a V package
that provides bindings to MPI for parallel computing.

### Prerequisites

Before you begin, make sure you have the following installed:

- [V Programming Language](https://vlang.io/)
- OpenMPI library:

  - **Ubuntu:**

    ```bash
    sudo apt install libopenmpi-dev
    ```

  - **Arch Linux:**

    ```bash
    sudo pacman -S openmpi
    ```

  - **macOS:**

    ```bash
    brew install openmpi
    ```

  - **Windows:**

    ```bash
    choco install openmpi
    ```

  - **FreeBSD:**

    ```bash
    pkg install openmpi
    ```

## Setting up Your Environment

### Install VSL

```bash
v install vsl
```

you can check out the [official documentation of vsl](https://vlang.github.io/vsl) for more information.

### Compile the Example

Compile the MPI example with:

```bash
v -o mpi_example -prod -cc mpirun main.v
```

### Run the Example

Run the example with:

```bash
mpirun -np 2 -H localhost:8 ./mpi_example
```

You should see output from both ranks indicating successful MPI communication.

## Understanding the MPI Example

Now, let's dive into the example code to understand how MPI is used with `vsl.mpi`.

### main.v

```v ignore
import vsl.float.float64
import vsl.mpi

mpi.initialize()!

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

// ... (MPI functions)

```

### Explanation

- `mpi.initialize()!`: Initialize MPI. The `!` asserts that the initialization is successful.
- `mpi.finalize()`: Cleanup and finalize MPI at the end of the program.
- `mpi.world_rank()`: Get the rank of the current process.
- `mpi.world_size()`: Get the total number of processes.
- `mpi.Communicator.new([])`: Create a new communicator.

Now, let's dive into the MPI functions used in the example.

## MPI Functions

### Communicator Functions

#### `comm.barrier()`

Synchronize all processes:

```v ignore
comm := mpi.Communicator.new([])!
comm.barrier()
```

#### `comm.bcast_from_root_<type>(vals []<type>)`

Broadcast values from the root process to all processes:

```v ignore
comm.bcast_from_root_f64(vals)
```

#### `comm.reduce_sum_<type>(mut dest []<type>, orig []<type>)`

Sum array elements on rank 0 and store the result in `dest`:

```v ignore
comm.reduce_sum_f64(mut dest, orig)
```

#### `comm.all_reduce_sum_<type>(mut dest []<type>, orig []<type>)`

Sum array elements across all processes and store the result in `dest`:

```v ignore
comm.all_reduce_sum_f64(mut dest, orig)
```

### Running the Example

Compile and run the example as described earlier. You should see output from both ranks,
indicating successful MPI communication.

---

Congratulations! You've completed the MPI with `vsl.mpi` tutorial. This introduction
should help you get started with parallel programming in V using MPI. For more detailed
information, refer to the [official documentation of vsl.mpi](https://vlang.github.io/vsl/mpi.html).

Feel free to explore additional MPI functions and experiment with different
parallel algorithms to harness the full power of MPI in your V programs.

Happy parallel programming!
