# Message Passing Interface (MPI) Example 🌐

This example demonstrates parallel computing using VSL's MPI wrapper for distributed computScale your computations with parallel processing! � Explore more parallel computing examples
in the [examples directory](../).ng
across multiple processes. Learn the fundamentals of parallel programming with MPI.

## 🎯 What You'll Learn

- MPI initialization and finalization
- Process identification and communication
- Distributed computing concepts
- Parallel programming with VSL
- Multi-process coordination

## 📋 Prerequisites

- V compiler installed ([download here](https://vlang.io))
- VSL library installed ([installation guide](https://github.com/vlang/vsl#-installation--quick-start))
- **OpenMPI library** installed on your system
- Basic understanding of parallel computing concepts

### Installing OpenMPI

**Ubuntu/Debian:**
```sh
sudo apt-get install libopenmpi-dev openmpi-bin
```

**macOS (with Homebrew):**
```sh
brew install open-mpi
```

**Windows:**
Download from [Microsoft MPI](https://docs.microsoft.com/en-us/message-passing-interface/microsoft-mpi)

## 🚀 Running the Example

### Single Process (Testing)

```sh
# Navigate to this directory
cd examples/mpi_basic_example

# Compile with MPI support
v -cflags -lmpi run main.v
```

### Multiple Processes (True Parallel)

```sh
# Run with 4 parallel processes
mpirun -np 4 v -cflags -lmpi run main.v

# Run with different number of processes
mpirun -np 2 v -cflags -lmpi run main.v
```

## 📊 Expected Output

When running with 4 processes, you should see output similar to:

```text
Hello from process 0 of 4
Hello from process 1 of 4
Hello from process 2 of 4
Hello from process 3 of 4
```

**Note**: The order may vary as processes execute independently.

## 🔍 MPI Concepts Explained

### Process Identification
- **Rank**: Unique identifier for each process (0, 1, 2, ...)
- **Size**: Total number of processes in the communicator
- **Communicator**: Group of processes that can communicate

### SPMD Model
- **Single Program, Multiple Data**: Same code runs on all processes
- Each process works on different data or different parts of the problem
- Coordination through message passing

## 🎨 Experiment Ideas

Try modifying the example to:

- **Add data exchange** between processes
- **Implement simple algorithms** (parallel sum, matrix multiplication)
- **Explore different communication patterns** (broadcast, gather, scatter)
- **Measure performance** with different numbers of processes

## 📚 Related Examples

- `mpi_bcast_example` - Broadcast communication patterns
- `data_analysis_example` - Data processing that could benefit from parallelization
- `ml_*` examples - Machine learning algorithms suitable for parallel execution

## 🔬 Technical Details

**VSL MPI Integration:**
- Wraps OpenMPI C library
- Provides V-friendly interface
- Handles memory management
- Supports common communication patterns

**Performance Considerations:**
- Communication overhead vs. computation time
- Load balancing between processes
- Memory distribution strategies

## 🐛 Troubleshooting

**MPI not found**: Ensure OpenMPI development packages are installed

**Permission denied**: Check that `mpirun` is in your system PATH

**Process hanging**: Verify all processes call MPI_Finalize

**Communication errors**: Check network configuration for multi-node runs

## 🔗 Advanced MPI Concepts

After mastering this example, explore:

- **Point-to-point communication**: Send/receive between specific processes
- **Collective operations**: Broadcast, reduce, gather operations
- **Non-blocking communication**: Asynchronous message passing
- **Custom data types**: Sending complex structures

## 📖 Additional Resources

- [MPI Tutorial](https://mpitutorial.com/)
- [OpenMPI Documentation](https://www.open-mpi.org/doc/)
- [VSL MPI Module Reference](https://vlang.github.io/vsl/mpi/)

---

Scale your computations with parallel processing! � Explore more parallel computing examples in the [examples directory](../).
