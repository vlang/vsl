# HDF5 Scientific Data I/O

VSL's `vsl.inout.h5` module reads and writes numeric datasets and their
attributes in HDF5 files. This walkthrough creates a dataset, stores summary
metadata beside it, and inspects the result with the HDF5 command-line tools.

## Requirements and supported data

- V and the VSL checkout available in `~/.vmodules`.
- HDF5 development headers and libraries. On Arch Linux install `hdf5`; on
  Debian or Ubuntu install `libhdf5-dev`; on macOS install `hdf5` with Homebrew.
- Optional: `h5dump` to inspect the generated file.
- Run V commands from `~/.vmodules`, outside the VSL directory.

The module supports one-, two-, and three-dimensional numeric datasets and
scalar or vector attributes. Groups other than `/`, string arrays, compound
types, compression, and parallel HDF5 I/O are not currently supported.

## Write a dataset

The existing dataset example generates values, writes them to `/randdata`, and
stores the mean as a dataset attribute:

```v ignore
import vsl.inout.h5
import math.stats
import rand

fn main() {
	linedata := []f64{len: 21, init: rand.f64()}
	meanv := stats.mean(linedata)
	f := h5.Hdf5File.new('dataset.h5')!
	f.write_dataset1d('/randdata', linedata)!
	f.write_attribute('/randdata', 'mean', meanv)!
	f.close()
}
```

Run the checked-in example from the module directory. It creates
`hdffile.h5` in the current working directory (`~/.vmodules`):

```sh
cd ~/.vmodules
VJOBS=2 v run ./vsl/examples/io_h5_dataset/main.v
```

Inspect the dataset and its metadata if `h5dump` is installed:

```sh
h5dump -H ~/.vmodules/hdffile.h5
```

The `Hdf5File` should be closed after the writes complete so native HDF5
resources are released. If a write operation returns an error, propagate it
with `!` as in the example rather than continuing with a partial file.

## Read an existing file

Open the file with `h5.Hdf5File.open(...)`, then use the matching typed
`read_dataset1d`, `read_dataset2d`, or `read_dataset3d` method and close the
file when finished. The file's stored numeric type and dimensions must match
the reader you choose. Dataset attributes can be retrieved with the
corresponding `read_attribute` methods.

For a longer numerical workflow that writes convergence metadata, see
[`io_h5_relax`](../../examples/io_h5_relax/main.v). The HDF5 module overview
lists supported types and current limitations in detail.

## Further reading

- [HDF5 module reference](../../inout/h5/README.md)
- [HDF5 dataset example](../../examples/io_h5_dataset/README.md)
- [HDF5 project documentation](https://www.hdfgroup.org/solutions/hdf5/)
