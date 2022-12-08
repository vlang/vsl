# MPI Basic example

This example shows how to use the basic MPI functions in VSL.

## Requirements

- On ubuntu, you can install the OpenMPI library with:

```bash
sudo apt install libopenmpi-dev
```

- On Arch Linux, you can install the OpenMPI library with:

```bash
sudo pacman -S openmpi
```

- On macOS, you can install the OpenMPI library with:

```bash
brew install openmpi
```

- On Windows, you can install the OpenMPI library with:

```bash
choco install openmpi
```

- On FreeBSD, you can install the OpenMPI library with:

```bash
pkg install openmpi
```

## Running the example

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
