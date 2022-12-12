# HDF5

The functions described in this chapter will read or write data to
a file in the [HDF5](https://hdfgroup.org) format.  These contain
`datasets` together with a set of `attributes` for each dataset.

Datasets are arranged in a heirarchical name space similar to Unix
file system.  Each namespace is called a `group`.  Datasets are
stored in a group in an area of the file called a `dataspace`.

This library simplifies much of this and supports:

- Datasets consisting of a vector ([]i64, []f64, etc).
- Datasets consisting of a 2-d array ([][]u8, [][]i16, etc).
- Datasets consisting of a 3-d array ([][][]u32, [][][]f32, etc).
- Any number of attributes for each dataset (int, []f64, string, etc).
  Attributes can be scalars or vectors. These are often metadata
  of the dataset describing how it was acquired or created.

Currently we do not support:

- Writing to groups other than "/" (which is the default)
- Datasets of arrays of strings.
- Compound data structures (akin to `struct`).
- Images or tables.
- Compression.
- Distributed datasets (pointers to other HDF5 files).
- Parallel reading or writing.

The functions described in this chapter are declared in the module `vsl.hdf5`

## ToDo List

Fixing the error processing arrangement, which is currently a mix of
option and result types.

Fix the memory consumption for writing 2-d or 3-d arrays: currently this uses
the flatten() function which is a copy operation.

Add more examples.

Add more datatypes, especially images.

Consider adding a file open-for-update function.

Add automatic group paths.

## Usage example

```v
import hdf5
import math.stats
import rand

fn main() {
	mut linedata := []f64{len: 21}
	mut meanv := f64(0)
	hdffile := c'hdffile.h5'

	for i in 0 .. linedata.len {
		linedata[i] = rand.f64()
	}
	meanv = stats.mean(linedata)

	f := hdf5.new_file(hdffile)?
	f.write_dataset1d(c'/randdata', linedata)?
	f.write_attribute(c'/randdata', c'mean', meanv)?
	f.close()
}
```

You can view the result with `h5dump hdffile.h5`.

## Functions

```v ignore
fn new_file(filename &char) ?HDF_File
```

This function opens a file for writing, truncating it if it already
exists.

```v ignore
fn open_file(filename &char) ?HDF_File
```

This opens an existing file for reading.

```v ignore
fn close(file_desc HDF_File)
```

Closes a file opened for reading or writing.

```v ignore
fn write_dataset1d(dset_name &char, buffer []T) ?HDF5_herr_t
```

Writes a vector of type T with the dataset name.  Similar routines
exist for 2d and 3d for types [][]T and [][][]T.

```v ignore
fn read_dataset1d(dset_name &char, mut dataset []T)
```

Reads the named dataset into the variable dataset, changing it's size
as required for the data in the file.  Similar routines
exist for 2d for types [][]T.

```v ignore
fn write_attribute(dset_name &char, attr_name &char, buffer T) ?HDF5_herr_t
```

This writes a scalar number or string under the attr_name and associated with
the named dataset.  You can add any number of attributes to a dataset.

```v ignore
fn write_attribute1d(dset_name &char, attr_name &char, buffer []T) ?HDF5_herr_t
```

This writes a numeric vector with the attr_name and associated with
the named dataset.  You can add any number of attributes to a dataset.

```v ignore
fn read_attribute(dset_name &char, attr_name &char, mut buffer T) ?HDF5_herr_t
```

This reads a scalar attribute (number or string) associated with the dataset.

```v ignore
fn read_attribute1d(dset_name &char, attr_name &char, mut buffer []T) ?HDF5_herr_t
```

This reads a numeric vector attribute associated with the dataset. The given
1d array is changed as required to fit the size of the vector.


## References and Further Reading

See the [HDF5](https://hdfgroup.org) website for documentation and examples
in C or Fortran.
