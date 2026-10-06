# MPI Parallel Computing

This guide builds and runs the VSL MPI wrapper with two local processes. MPI
uses a single-program, multiple-data (SPMD) model: every process runs the same
program, and its rank determines the work it performs.

## Requirements

- V and the VSL checkout available in `~/.vmodules`.
- OpenMPI development files and launcher (`mpirun`). On Arch Linux, install
  `openmpi`; on Debian or Ubuntu, install `libopenmpi-dev openmpi-bin`; on
  macOS, install `open-mpi` with Homebrew.
- Run commands below from `~/.vmodules`, outside the VSL directory.

## Run the two-process example

The round-trip example sends an integer vector from rank 0 to rank 1, checks the
received values, and synchronizes before finalizing MPI.

```sh
cd ~/.vmodules
VJOBS=2 v -d vsl_mpi -cc gcc -o /tmp/vsl-mpi-roundtrip ./vsl/mpi/examples/roundtrip/main.v
mpirun --oversubscribe -n 2 /tmp/vsl-mpi-roundtrip
```

Expected behavior: both processes exit successfully; rank 1 verifies that it
received `[13, 21, 34]`. The program is intentionally quiet on success. The
`vsl_mpi` build flag enables the MPI-specific VSL configuration, and `-cc gcc`
selects the C compiler used for the native MPI bindings.

## MPI lifecycle and communication

Initialize MPI once per process and finalize it on every exit path. A deferred
finalizer keeps cleanup paired with initialization:

```v ignore
import vsl.mpi

fn main() {
	mpi.initialize() or { panic(err) }
	defer {
		mpi.finalize()
	}
	comm := mpi.Communicator.new([]) or { panic(err) }
	println('rank ${comm.rank()} of ${comm.size()}')
	comm.barrier()
}
```

Use matching send and receive calls: the sender's destination rank must match
the receiver's source rank, and both sides must agree on the element type and
message length. The wrapper supports i32, u32, i64, u64, f32, and f64 arrays,
single values, broadcasts, reductions, and barriers. All ranks in a collective
operation must call it in the same order. A mismatched communication pattern
can leave a process waiting indefinitely.

## Test the wrapper

From `~/.vmodules`, run the focused MPI tests with the same compile-time flag:

```sh
cd ~/.vmodules
VJOBS=2 v -d vsl_mpi -cc gcc test ./vsl/mpi
```

The package currently targets Linux and BSD. This wrapper uses native MPI
headers and libraries, so cross-platform support depends on the paths and
libraries configured in `vsl/mpi/_cflags.c.v`.

## Further reading

- [MPI module reference](../../mpi/README.md)
- [Basic MPI example](../../examples/mpi_basic_example/README.md)
- [MPI standard resources](https://www.open-mpi.org/doc/)
