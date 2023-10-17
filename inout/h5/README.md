# HDF5

The functions described in this chapter will read or write data to
a file in the [HDF5](https://hdfgroup.org) format. These contain
`datasets` together with a set of `attributes` for each dataset.

Datasets are arranged in a heirarchical name space similar to Unix
file system. Each namespace is called a `group`. Datasets are
stored in a group in an area of the file called a `dataspace`.

## Supported Features

- Datasets consisting of a vector (`[]i64`, `[]f64`, etc).
- Datasets consisting of a 2-d array (`[][]u8`, `[][]i16`, etc).
- Datasets consisting of a 3-d array (`[][][]u32`, `[][][]f32`, etc).
- Any number of attributes for each dataset (`int`, `[]f64`, `string`, etc).
  Attributes can be scalars or vectors. These are often metadata
  of the dataset describing how it was acquired or created.

## Unsupported Features - Planned

- Writing to groups other than `/` (which is the default)
- Datasets of arrays of strings.
- Compound data structures (akin to `struct`).
- Images or tables.
- Compression.
- Distributed datasets (pointers to other HDF5 files).
- Parallel reading or writing.

## References and Further Reading

See the [HDF5](https://hdfgroup.org) website for documentation and examples
in C or Fortran.
