module hdf5

import arrays { flatten }
import math

type Hdf5HidT = i64
type Hdf5HsizeT = u64
type Hdf5HerrT = int
type Hdf5ClassT = int
type Hdf5SizeT = usize

fn C.H5Fcreate(filename &char, flags int, fcpl_id Hdf5HidT, fapl_id Hdf5HidT) Hdf5HidT
fn C.H5Fopen(filename &char, flags int, fcpl_id Hdf5HidT) Hdf5HidT

fn C.H5Dget_space(dset_id Hdf5HidT) Hdf5HidT
fn C.H5Dread(dset_id Hdf5HidT, mem_type_id Hdf5HidT, mem_space_id Hdf5HidT, file_space_id Hdf5HidT, dxpl_id Hdf5HidT, buf &voidptr) Hdf5HerrT

fn C.H5Dopen2(loc_id Hdf5HidT, dset &char, dapl_id Hdf5HidT) Hdf5HidT

fn C.H5LTset_attribute_int(loc_id Hdf5HidT, name &char, aname &char, buffer &voidptr, bsize Hdf5HsizeT) Hdf5HidT
fn C.H5LTset_attribute_uint(loc_id Hdf5HidT, name &char, aname &char, buffer &voidptr, bsize Hdf5HsizeT) Hdf5HidT
fn C.H5LTset_attribute_long(loc_id Hdf5HidT, name &char, aname &char, buffer &voidptr, bsize Hdf5HsizeT) Hdf5HidT
fn C.H5LTset_attribute_ulong(loc_id Hdf5HidT, name &char, aname &char, buffer &voidptr, bsize Hdf5HsizeT) Hdf5HidT
fn C.H5LTset_attribute_short(loc_id Hdf5HidT, name &char, aname &char, buffer &voidptr, bsize Hdf5HsizeT) Hdf5HidT
fn C.H5LTset_attribute_ushort(loc_id Hdf5HidT, name &char, aname &char, buffer &voidptr, bsize Hdf5HsizeT) Hdf5HidT
fn C.H5LTset_attribute_char(loc_id Hdf5HidT, name &char, aname &char, buffer &voidptr, bsize Hdf5HsizeT) Hdf5HidT
fn C.H5LTset_attribute_uchar(loc_id Hdf5HidT, name &char, aname &char, buffer &voidptr, bsize Hdf5HsizeT) Hdf5HidT
fn C.H5LTset_attribute_long_long(loc_id Hdf5HidT, name &char, aname &char, buffer &voidptr, bsize Hdf5HsizeT) Hdf5HidT
fn C.H5LTset_attribute_double(loc_id Hdf5HidT, name &char, aname &char, buffer &voidptr, bsize Hdf5HsizeT) Hdf5HidT
fn C.H5LTset_attribute_float(loc_id Hdf5HidT, name &char, aname &char, buffer &voidptr, bsize Hdf5HsizeT) Hdf5HidT
fn C.H5LTset_attribute_string(loc_id Hdf5HidT, name &char, aname &char, buffer &char) Hdf5HidT

fn C.H5LTfind_attribute(loc_id Hdf5HidT, aname &char) Hdf5HerrT

fn C.H5LTget_attribute_ndims(loc_id Hdf5HidT, name &char, aname &char, rank &int) Hdf5HerrT
fn C.H5LTget_attribute_info(loc_id Hdf5HidT, name &char, aname &char, dims &Hdf5HsizeT, type_class &Hdf5ClassT, type_size &Hdf5SizeT) Hdf5HerrT
fn C.H5LTget_attribute_double(loc_id Hdf5HidT, name &char, aname &char, buf &f64) Hdf5HerrT
fn C.H5LTget_attribute_float(loc_id Hdf5HidT, name &char, aname &char, buf &f32) Hdf5HerrT
fn C.H5LTget_attribute_long(loc_id Hdf5HidT, name &char, aname &char, buf &i64) Hdf5HerrT
fn C.H5LTget_attribute_int(loc_id Hdf5HidT, name &char, aname &char, buf &int) Hdf5HerrT
fn C.H5LTget_attribute_short(loc_id Hdf5HidT, name &char, aname &char, buf &i16) Hdf5HerrT
fn C.H5LTget_attribute_char(loc_id Hdf5HidT, name &char, aname &char, buf &i8) Hdf5HerrT
fn C.H5LTget_attribute_ulong(loc_id Hdf5HidT, name &char, aname &char, buf &u64) Hdf5HerrT
fn C.H5LTget_attribute_uint(loc_id Hdf5HidT, name &char, aname &char, buf &u32) Hdf5HerrT
fn C.H5LTget_attribute_ushort(loc_id Hdf5HidT, name &char, aname &char, buf &u16) Hdf5HerrT
fn C.H5LTget_attribute_uchar(loc_id Hdf5HidT, name &char, aname &char, buf &u8) Hdf5HerrT
fn C.H5LTget_attribute_string(loc_id Hdf5HidT, name &char, aname &char, buf &voidptr) Hdf5HerrT

fn C.H5LTmake_dataset(loc_id Hdf5HidT, dset_name &char, rank int, dims []Hdf5HsizeT, type_id Hdf5HidT, buffer &voidptr) Hdf5HerrT

fn C.H5LTget_dataset_ndims(loc_id Hdf5HidT, name &char, rank &int) Hdf5HerrT
fn C.H5LTget_dataset_info(loc_id Hdf5HidT, name &char, dims &Hdf5HsizeT, class_id &Hdf5ClassT, type_size &Hdf5SizeT) Hdf5HerrT
fn C.H5LTread_dataset(loc_id Hdf5HidT, name &char, type_id Hdf5HidT, buffer &voidptr) Hdf5HerrT

fn C.H5Aclose(dset_id Hdf5HidT) Hdf5HerrT
fn C.H5Dclose(dset_id Hdf5HidT) Hdf5HerrT
fn C.H5Sclose(dset_id Hdf5HidT) Hdf5HerrT
fn C.H5Fclose(file_id Hdf5HidT) Hdf5HerrT

fn make1type[T](a int) []T {
	return []T{len: a}
}

fn make2type[T](a int, b int) [][]T {
	return [][]T{len: a, init: []T{len: b}}
}

fn make3type[T](a int, b int, c int) [][][]T {
	return [][][]T{len: a, init: make2type[T](b, c)}
}

// hdftype is a Templated function to convert a type to an external const
// It maps the V type name to an HDF5 type name (f64 -> C.H5T_IEEE_F64LE).
// Not valid for read with Big Endian architectures (SPARC, some POWER machines)
fn hdftype[T](x T) Hdf5HidT {
	$if T is f64 {
		return C.H5T_IEEE_F64LE
	} $else $if T is f32 {
		return C.H5T_IEEE_F32LE
	} $else $if T is i64 {
		return C.H5T_STD_I64LE
	} $else $if T is i32 { // note i32 is an alias for int
		return C.H5T_STD_I32LE
	} $else $if T is int {
		return C.H5T_STD_I32LE
	} $else $if T is i16 {
		return C.H5T_STD_I16LE
	} $else $if T is i8 {
		return C.H5T_STD_I8LE
	} $else $if T is u64 {
		return C.H5T_STD_U64LE
	} $else $if T is u32 {
		return C.H5T_STD_U32LE
	} $else $if T is u16 {
		return C.H5T_STD_U16LE
	} $else $if T is u8 {
		return C.H5T_STD_U8LE
	} $else $if T is string {
		return C.H5T_C_S1
	} $else {
		// only at runtime:
		eprintln('hdf5 unsupported type: ${typeof(x).name}')
	}
	return C.H5T_STD_U8LE
}

pub struct HdfFile {
mut:
	filedesc Hdf5HidT
}

// new_file creates a new HDF5 file, or truncates an existing file.
pub fn new_file(filename string) ?HdfFile {
	mut f := HdfFile{
		filedesc: C.H5Fcreate(unsafe { filename.str }, C.H5F_ACC_TRUNC, C.H5P_DEFAULT,
			C.H5P_DEFAULT)
	}
	return f
}

// WRITERS

// write_dataset1d writes a 1-d numeric array (vector) to a named HDF5 dataset in an HDF5 file.
pub fn (f &HdfFile) write_dataset1d[T](dset_name string, buffer []T) ?Hdf5HerrT {
	rank := int(1)
	dims := [i64(buffer.len)]
	dtype := hdftype(buffer[0])
	mut errc := C.H5LTmake_dataset(f.filedesc, dset_name.str, rank, unsafe { dims.data },
		dtype, unsafe { buffer.data })
	return errc
}

// write_dataset2d writes a 2-d numeric array to a named HDF5 dataset in an HDF5 file.
// Note: creates a temporary copy of the array.
pub fn (f &HdfFile) write_dataset2d[T](dset_name string, buffer [][]T) ?Hdf5HerrT {
	rank := int(2)
	dims := [i64(buffer.len), buffer[0].len]
	dtype := hdftype(buffer[0][0])
	mut errc := C.H5LTmake_dataset(f.filedesc, dset_name.str, rank, unsafe { dims.data },
		dtype, unsafe { flatten(buffer).data })
	return errc
}

// write_dataset3d writes a numeric 3-d array (layers of 2-d arrays) to a named HDF5 dataset in an HDF5 file.
// Note: creates a temporary copy of the array.
pub fn (f &HdfFile) write_dataset3d[T](dset_name string, buffer [][][]T) ?Hdf5HerrT {
	rank := int(3)
	dims := [i64(buffer.len), buffer[0].len, buffer[0][0].len]
	dtype := hdftype(buffer[0][0][0])
	// must flatten[T] else V cannot guess correctly
	mut errc := C.H5LTmake_dataset(f.filedesc, dset_name.str, rank, unsafe { dims.data },
		dtype, unsafe { flatten[T](flatten(buffer)).data })
	return errc
}

// write_attribute1d adds a named 1-d numeric array (vector) attribute to a named HDF5 dataset.
pub fn (f &HdfFile) write_attribute1d[T](dset_name string, attr_name string, buffer []T) ?Hdf5HerrT {
	$if T is f64 {
		return C.H5LTset_attribute_double(f.filedesc, dset_name.str, attr_name.str, unsafe { buffer.data },
			u64(buffer.len))
	} $else $if T is f32 {
		return C.H5LTset_attribute_float(f.filedesc, dset_name.str, attr_name.str, unsafe { buffer.data },
			u64(buffer.len))
	} $else $if T is i64 {
		return C.H5LTset_attribute_long_long(f.filedesc, dset_name.str, attr_name.str,
			unsafe { buffer.data }, u64(buffer.len))
	} $else $if T is int {
		return C.H5LTset_attribute_int(f.filedesc, dset_name.str, attr_name.str, unsafe { buffer.data },
			u64(buffer.len))
	} $else $if T is i16 {
		return C.H5LTset_attribute_short(f.filedesc, dset_name.str, attr_name.str, unsafe { buffer.data },
			u64(buffer.len))
	} $else $if T is i8 {
		return C.H5LTset_attribute_char(f.filedesc, dset_name.str, attr_name.str, unsafe { buffer.data },
			u64(buffer.len))
	} $else $if T is u64 {
		return C.H5LTset_attribute_ulong(f.filedesc, dset_name.str, attr_name.str, unsafe { buffer.data },
			u64(buffer.len))
	} $else $if T is u32 {
		return C.H5LTset_attribute_uint(f.filedesc, dset_name.str, attr_name.str, unsafe { buffer.data },
			u64(buffer.len))
	} $else $if T is u16 {
		return C.H5LTset_attribute_ushort(f.filedesc, dset_name.str, attr_name.str, unsafe { buffer.data },
			u64(buffer.len))
	} $else $if T is u8 {
		return C.H5LTset_attribute_uchar(f.filedesc, dset_name.str, attr_name.str, unsafe { buffer.data },
			u64(buffer.len))
	} $else {
		return Hdf5HerrT(-1)
	}
}

// write_attribute adds a named scalar attribute to a named HDF5 dataset.
//   This is a helper function to avoid an array temporary; it writes a single element vector.
//   It also supports writing a string attribute.
pub fn (f &HdfFile) write_attribute[T](dset_name string, attr_name string, buffer T) ?Hdf5HerrT {
	$if T is f64 {
		return C.H5LTset_attribute_double(f.filedesc, dset_name.str, attr_name.str, &buffer,
			u64(1))
	} $else $if T is f32 {
		return C.H5LTset_attribute_float(f.filedesc, dset_name.str, attr_name.str, &buffer,
			u64(1))
	} $else $if T is i64 {
		return C.H5LTset_attribute_long_long(f.filedesc, dset_name.str, attr_name.str,
			&buffer, u64(1))
	} $else $if T is i32 {
		return C.H5LTset_attribute_int(f.filedesc, dset_name.str, attr_name.str, &buffer,
			u64(1))
	} $else $if T is i16 {
		return C.H5LTset_attribute_short(f.filedesc, dset_name.str, attr_name.str, &buffer,
			u64(1))
	} $else $if T is i8 {
		return C.H5LTset_attribute_char(f.filedesc, dset_name.str, attr_name.str, &buffer,
			u64(1))
	} $else $if T is u64 {
		return C.H5LTset_attribute_ulong(f.filedesc, dset_name.str, attr_name.str, &buffer,
			u64(1))
	} $else $if T is u32 {
		return C.H5LTset_attribute_uint(f.filedesc, dset_name.str, attr_name.str, &buffer,
			u64(1))
	} $else $if T is u16 {
		return C.H5LTset_attribute_ushort(f.filedesc, dset_name.str, attr_name.str, &buffer,
			u64(1))
	} $else $if T is u8 {
		return C.H5LTset_attribute_uchar(f.filedesc, dset_name.str, attr_name.str, &buffer,
			u64(1))
	} $else $if T is string {
		return C.H5LTset_attribute_string(f.filedesc, dset_name.str, attr_name.str, &char(buffer.str))
	} $else {
		return Hdf5HerrT(-1)
	}
}

// READERS

// open_file opens an existing HDF5 file
pub fn open_file(filename string) ?HdfFile {
	mut f := HdfFile{
		filedesc: C.H5Fopen(unsafe { filename.str }, C.H5F_ACC_RDONLY, C.H5P_DEFAULT)
	}
	return f
}

// read_dataset1d reads a 1-d numeric array (vector) from a named HDF5 dataset in an HDF5 file.
//   Replaces the value of the array.
//   Maximum dimension is math.max_i32 or less (this is checked).
pub fn (f &HdfFile) read_dataset1d[T](dset_name string, mut dataset []T) {
	mut rank := 0
	mut class_id := Hdf5ClassT(0)
	mut type_size := Hdf5SizeT(0)

	mut errc := C.H5LTget_dataset_ndims(f.filedesc, dset_name.str, &rank)
	assert errc >= 0
	assert rank == 1

	mut curdims := []Hdf5HsizeT{len: rank, init: 0}
	errc = C.H5LTget_dataset_info(f.filedesc, dset_name.str, unsafe { curdims.data },
		&class_id, &type_size)
	assert errc >= 0
	assert curdims[0] > 0
	assert curdims[0] < math.max_i32

	dtype := hdftype(dataset[0])
	// note: V dims are int while hdf5 dims are u64
	mut x := []T{len: int(curdims[0])}
	errc = C.H5LTread_dataset(f.filedesc, dset_name.str, dtype, unsafe { x.data })
	assert errc >= 0

	unsafe {
		dataset = x
	}
}

// read_dataset2d reads a 2-d numeric array from a named HDF5 dataset in an HDF5 file.
//   Replaces the value of the array.
//   Maximum of any dimension is math.max_i32 or less (this is checked).
//   Maximum total elements is also math.max_i32.
pub fn (f &HdfFile) read_dataset2d[T](dset_name string, mut dataset [][]T) {
	mut rank := 0
	mut class_id := Hdf5ClassT(0)
	mut type_size := Hdf5SizeT(0)

	mut errc := C.H5LTget_dataset_ndims(f.filedesc, dset_name.str, &rank)
	assert errc >= 0
	assert rank == 2

	mut curdims := []Hdf5HsizeT{len: rank, init: 0}
	errc = C.H5LTget_dataset_info(f.filedesc, dset_name.str, unsafe { curdims.data },
		&class_id, &type_size)
	assert errc >= 0
	assert curdims[0] > 0
	assert curdims[1] > 0
	assert curdims[0] < math.max_i32
	assert curdims[1] < math.max_i32

	dtype := hdftype(dataset[0][0])
	mut y := make1type[T](int(curdims[0] * curdims[1]))

	errc = C.H5LTread_dataset(f.filedesc, dset_name.str, dtype, unsafe { y.data })
	assert errc >= 0

	dataset = reshape(y, curdims) or {
		println(' dataset ${dset_name} reshape failed')
		return
	}
}

// read_dataset3d reads a 3-d numeric array from a named HDF5 dataset in an HDF5 file.
//   Replaces the value of the array with correctly dimensioned array.
//   Maximum of any dimension is math.max_i32 or less (this is checked).
//   Maximum total elements is also math.max_i32.
pub fn (f &HdfFile) read_dataset3d[T](dset_name string, mut dataset [][][]T) {
	mut rank := 0
	mut class_id := Hdf5ClassT(0)
	mut type_size := Hdf5SizeT(0)

	mut errc := C.H5LTget_dataset_ndims(f.filedesc, dset_name.str, &rank)
	assert errc >= 0
	assert rank == 3

	mut curdims := []Hdf5HsizeT{len: rank, init: 0}
	errc = C.H5LTget_dataset_info(f.filedesc, dset_name.str, unsafe { curdims.data },
		&class_id, &type_size)
	assert errc >= 0
	assert curdims[0] > 0
	assert curdims[1] > 0
	assert curdims[2] > 0
	assert curdims[0] < math.max_i32
	assert curdims[1] < math.max_i32
	assert curdims[2] < math.max_i32

	dtype := hdftype(dataset[0][0][0])
	mut y := make1type[T](int(curdims[0] * curdims[1] * curdims[2]))

	errc = C.H5LTread_dataset(f.filedesc, dset_name.str, dtype, unsafe { y.data })
	assert errc >= 0

	dataset = reshape3(y, curdims) or {
		println(' dataset ${dset_name} reshape failed')
		return
	}
}

// reshape returns [][]x using []y and intended dimensions.
// y.len() == product(dimensions) else error.
fn reshape[T](y []T, dims []Hdf5HsizeT) ![][]T {
	mut proddims := Hdf5HsizeT(1)
	leny := Hdf5HsizeT(u64(y.len))
	for i in 0 .. dims.len {
		proddims = proddims * dims[i]
	}
	if leny != proddims {
		return error(' reshape dimensions not equal to array length')
	}
	mut idims := []int{len: 2}
	idims[0] = int(dims[0])
	idims[1] = int(dims[1])

	res := make2type[T](idims[0], 1)
	unsafe {
		for i in 0 .. idims[0] {
			res[i].len = idims[1]
			res[i].cap = idims[1]
			res[i].data = &y[i * idims[1]]
		}
	}
	return res
}

// reshape3 returns [][][]x using []y and intended dimensions.
// y.len() == product(dimensions) else error.
fn reshape3[T](y []T, dims []Hdf5HsizeT) ![][][]T {
	mut proddims := Hdf5HsizeT(1)
	leny := Hdf5HsizeT(u64(y.len))
	for i in 0 .. dims.len {
		proddims = proddims * dims[i]
	}
	if leny != proddims {
		return error(' reshape3 dimensions not equal to array length')
	}
	mut idims := []int{len: 3}
	idims[0] = int(dims[0])
	idims[1] = int(dims[1])
	idims[2] = int(dims[2])

	res := make3type[T](idims[0], idims[1], 1)
	unsafe {
		for i in 0 .. idims[0] {
			for k in 0 .. idims[1] {
				res[i][k].len = idims[2]
				res[i][k].cap = idims[2]
				res[i][k].data = &y[i * idims[1] * idims[2] + k * idims[2]]
			}
		}
	}
	return res
}

// getattr_class_size reads back the HDF5 class (float, int, string) and size (1, 2, 4, 8) of a scalar attribute.
// This is a helper function for read_attribute<T> for a scalar or read_attribute1d<T> for a vector.
// Assumes the attribute and dataset exist.
fn (f &HdfFile) getattr_class_size(dset_name string, attr_name string) (Hdf5ClassT, Hdf5SizeT) {
	mut rank := int(0)
	mut type_class := Hdf5ClassT(0)
	mut type_size := Hdf5SizeT(0)

	mut errc := C.H5LTget_attribute_ndims(f.filedesc, dset_name.str, attr_name.str, &rank)
	assert errc >= 0
	assert rank == 1

	mut curdims := []Hdf5HsizeT{len: if rank == 1 { rank } else { 1 }, init: 0}
	errc = C.H5LTget_attribute_info(f.filedesc, dset_name.str, attr_name.str, unsafe { curdims.data },
		&type_class, &type_size)
	assert errc >= 0
	assert curdims[0] >= 1
	return type_class, type_size
}

// checkdsetattr verifies dataset and attribute exist
fn (f &HdfFile) checkdsetattr(dset_name string, attr_name string) bool {
	mut dset_id := C.H5Dopen2(f.filedesc, dset_name.str, C.H5P_DEFAULT)
	defer {
		C.H5Dclose(dset_id)
	}
	if dset_id < 0 {
		return false
	}

	errc := C.H5LTfind_attribute(dset_id, attr_name.str)
	if errc == 0 {
		return false
	} else {
		return true
	}
}

// checktype verifies name, class and type-size for an attribute.
// Returns true only if the name exists and class and type-size match.
fn (f &HdfFile) checktype(dset_name string, attr_name string, type_class Hdf5ClassT, type_size Hdf5SizeT) bool {
	mut x_type_class := Hdf5ClassT(0)
	mut x_type_size := Hdf5SizeT(0)

	mut dset_id := C.H5Dopen2(f.filedesc, dset_name.str, C.H5P_DEFAULT)
	defer {
		C.H5Dclose(dset_id)
	}

	errc := C.H5LTfind_attribute(dset_id, attr_name.str)

	if errc == 0 {
		return false
	}

	x_type_class, x_type_size = f.getattr_class_size(dset_name, attr_name)
	if type_class == x_type_class && type_size == x_type_size {
		return true
	} else {
		return false
	}
}

// getstringattr gets a variable-length string attribute.
// This is a helper function to check existance of and process string copies.
// Strings are a special case since the length varies.
// Assumes the dataset exists but does check the attribute exists.
fn (f &HdfFile) getstringattr(dset_name string, attr_name string) !string {
	mut type_class := Hdf5ClassT(0)
	mut type_size := Hdf5SizeT(0)
	mut curdims := Hdf5HsizeT(0)

	mut dset_id := C.H5Dopen2(f.filedesc, dset_name.str, C.H5P_DEFAULT)
	defer {
		C.H5Dclose(dset_id)
	}

	mut errc := C.H5LTfind_attribute(dset_id, attr_name.str)
	if errc == 0 {
		return error(' dataset ${dset_name} no attribute ${attr_name}')
	}

	// we don't use our getattr_class_size() because strings have rank==0 and dims[0]==0
	errc = C.H5LTget_attribute_info(f.filedesc, dset_name.str, attr_name.str, unsafe { &curdims },
		&type_class, &type_size)
	assert errc >= 0
	assert type_class == C.H5T_STRING

	if type_class == C.H5T_STRING {
		mut buffer := vcalloc(type_size)
		errc = C.H5LTget_attribute_string(f.filedesc, dset_name.str, attr_name.str, buffer)
		assert errc >= 0
		vs := unsafe { cstring_to_vstring(buffer) }
		unsafe {
			return vs
		}
	} else {
		return error(' dataset ${dset_name} attribute ${attr_name} not a string')
	}
}

// readattribute gets a named scalar attribute from a named HDF5 dataset.
//   This is a helper function to avoid an array temporary; it gets a single element vector.
//   It also supports reading a string attribute.
pub fn (f &HdfFile) read_attribute[T](dset_name string, attr_name string, mut attr_value T) ?bool {
	mut errc := Hdf5HerrT(0)

	if !f.checkdsetattr(dset_name, attr_name) {
		return false
	}

	$if T is f64 {
		if f.checktype(dset_name, attr_name, C.H5T_FLOAT, 8) {
			errc = C.H5LTget_attribute_double(f.filedesc, dset_name.str, attr_name.str,
				&attr_value)
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is f32 {
		if f.checktype(dset_name, attr_name, C.H5T_FLOAT, 4) {
			errc = C.H5LTget_attribute_float(f.filedesc, dset_name.str, attr_name.str,
				&attr_value)
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is i64 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 8) {
			errc = C.H5LTget_attribute_long(f.filedesc, dset_name.str, attr_name.str,
				&attr_value)
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is i32 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 4) {
			errc = C.H5LTget_attribute_int(f.filedesc, dset_name.str, attr_name.str, &attr_value)
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is i16 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 2) {
			errc = C.H5LTget_attribute_short(f.filedesc, dset_name.str, attr_name.str,
				&attr_value)
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is i8 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 1) {
			errc = C.H5LTget_attribute_char(f.filedesc, dset_name.str, attr_name.str,
				&attr_value)
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is u64 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 8) {
			errc = C.H5LTget_attribute_ulong(f.filedesc, dset_name.str, attr_name.str,
				&attr_value)
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is u32 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 4) {
			errc = C.H5LTget_attribute_uint(f.filedesc, dset_name.str, attr_name.str,
				&attr_value)
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is u16 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 2) {
			errc = C.H5LTget_attribute_ushort(f.filedesc, dset_name.str, attr_name.str,
				&attr_value)
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is u8 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 1) {
			errc = C.H5LTget_attribute_uchar(f.filedesc, dset_name.str, attr_name.str,
				&attr_value)
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is string {
		attr_value = f.getstringattr(dset_name, attr_name) or {
			attr_value = 'not available'
			return false
		}
		return true
	} $else {
		eprintln('hdf5 getattr unsupported type: ${typeof(attr_value).name}')
		return false
	}
}

// read_attribute1d reads a 1-d numeric array (vector) from a named HDF5 dataset and named attribute in an HDF5 file.
//   Replaces the value of the given array.
//   Maximum dimension is math.max_i32 or less (this is checked).
pub fn (f &HdfFile) read_attribute1d[T](dset_name string, attr_name string, mut attr_value []T) ?bool {
	mut rank := 0
	mut class_id := Hdf5ClassT(0)
	mut type_size := Hdf5SizeT(0)

	if !f.checkdsetattr(dset_name, attr_name) {
		return false
	}

	mut errc := C.H5LTget_attribute_ndims(f.filedesc, dset_name.str, attr_name.str, &rank)
	assert errc >= 0
	assert rank == 1

	mut curdims := []Hdf5HsizeT{len: rank, init: 0}
	errc = C.H5LTget_attribute_info(f.filedesc, dset_name.str, attr_name.str, unsafe { curdims.data },
		&class_id, &type_size)
	assert errc >= 0
	assert curdims[0] > 0
	assert curdims[0] <= math.max_i32
	if curdims[0] > math.max_i32 {
		return false
	}

	// note: V dims are int while hdf5 dims are u64
	mut x := []T{len: int(curdims[0])}
	unsafe {
		attr_value = x
	}
	$if T is f64 {
		if f.checktype(dset_name, attr_name, C.H5T_FLOAT, 8) {
			errc = C.H5LTget_attribute_double(f.filedesc, dset_name.str, attr_name.str,
				unsafe { attr_value.data })
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is f32 {
		if f.checktype(dset_name, attr_name, C.H5T_FLOAT, 4) {
			errc = C.H5LTget_attribute_float(f.filedesc, dset_name.str, attr_name.str,
				unsafe { attr_value.data })
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is i64 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 8) {
			errc = C.H5LTget_attribute_long(f.filedesc, dset_name.str, attr_name.str,
				unsafe { attr_value.data })
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is i32 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 4) {
			errc = C.H5LTget_attribute_int(f.filedesc, dset_name.str, attr_name.str, unsafe { attr_value.data })
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is i16 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 2) {
			errc = C.H5LTget_attribute_short(f.filedesc, dset_name.str, attr_name.str,
				unsafe { attr_value.data })
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is i8 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 1) {
			errc = C.H5LTget_attribute_char(f.filedesc, dset_name.str, attr_name.str,
				unsafe { attr_value.data })
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is u64 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 8) {
			errc = C.H5LTget_attribute_ulong(f.filedesc, dset_name.str, attr_name.str,
				attr_value.data)
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is u32 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 4) {
			errc = C.H5LTget_attribute_uint(f.filedesc, dset_name.str, attr_name.str,
				unsafe { attr_value.data })
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is u16 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 2) {
			errc = C.H5LTget_attribute_ushort(f.filedesc, dset_name.str, attr_name.str,
				unsafe { attr_value.data })
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is u8 {
		if f.checktype(dset_name, attr_name, C.H5T_INTEGER, 1) {
			errc = C.H5LTget_attribute_uchar(f.filedesc, dset_name.str, attr_name.str,
				unsafe { attr_value.data })
			assert errc >= 0
			return true
		}
		return false
	} $else $if T is string {
		attr_value = f.getstringattr(dset_name, attr_name) or {
			attr_value = 'not available'
			return false
		}
		return true
	} $else {
		eprintln('hdf5 getattr unsupported type: ${typeof(attr_value).name}')
		return false
	}
}

// close releases memory resources for HDF5 files.
pub fn (f &HdfFile) close() {
	C.H5Fclose(f.filedesc)
}
