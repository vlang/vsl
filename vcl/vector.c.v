module vcl

// Vector is a memory buffer on device that holds []T
pub struct Vector[T] {
mut:
	buf &Buffer = unsafe { nil }
}

// vector allocates new vector buffer with specified length
pub fn (d &Device) vector[T](length int) !&Vector[T] {
	size := length * int(sizeof(T))
	buffer := d.buffer(size)!
	return &Vector[T]{
		buf: buffer
	}
}

// Length the length of the vector
pub fn (v &Vector[T]) length() int {
	return v.buf.size / int(sizeof(T))
}

// Release releases the buffer on the device
pub fn (v &Vector[T]) release() ! {
	return v.buf.release()
}

// load copies the T data from host data to device buffer
// it's a non-blocking call, channel will return an error or nil if the data transfer is complete
pub fn (mut v Vector[T]) load(data []T) chan IError {
	if v.length() != data.len {
		ch := chan IError{cap: 1}
		ch <- error('vector length not equal to data length')
		return ch
	}
	return v.buf.load(data.len * int(sizeof(T)), unsafe { &data[0] })
}

// data gets T data from device, it's a blocking call
pub fn (v &Vector[T]) data() ![]T {
	mut data := []T{len: int(v.buf.size / int(sizeof(T)))}
	ret := cl_enqueue_read_buffer(v.buf.device.queue, v.buf.memobj, true, 0, usize(v.buf.size),
		unsafe { &data[0] }, 0, unsafe { nil }, unsafe { nil })
	return error_or_default(ret, data)
}

// map applies an map kernel on all elements of the vector
pub fn (v &Vector[T]) map(k &Kernel) chan IError {
	return k.global(v.length()).local(1).run(v.buffer())
}

// buffer returns the underlying buffer
pub fn (v &Vector[T]) buffer() &Buffer {
	return v.buf
}

// VectorF32 is an OpenCL buffer for f32 data. It provides a concrete type for
// compiler versions that cannot instantiate the generic Vector[f32] in C code.
pub struct VectorF32 {
mut:
	buf &Buffer = unsafe { nil }
}

// vector_f32 allocates a new f32 vector buffer with the specified length.
pub fn (d &Device) vector_f32(length int) !&VectorF32 {
	if length <= 0 {
		return error('vector length must be greater than zero')
	}
	buffer := d.buffer(length * int(sizeof(f32)))!
	return &VectorF32{
		buf: buffer
	}
}

// load copies f32 values from host memory to the device buffer.
pub fn (mut v VectorF32) load(data []f32) chan IError {
	if v.length() != data.len {
		ch := chan IError{cap: 1}
		ch <- error('vector length not equal to data length')
		return ch
	}
	if data.len == 0 {
		ch := chan IError{cap: 1}
		ch <- none
		return ch
	}
	return v.buf.load(data.len * int(sizeof(f32)), unsafe { &data[0] })
}

// data copies f32 values from the device buffer to host memory.
pub fn (v &VectorF32) data() ![]f32 {
	mut data := []f32{len: int(v.buf.size / int(sizeof(f32)))}
	if data.len == 0 {
		return data
	}
	ret := cl_enqueue_read_buffer(v.buf.device.queue, v.buf.memobj, true, 0, usize(v.buf.size),
		unsafe { &data[0] }, 0, unsafe { nil }, unsafe { nil })
	return error_or_default(ret, data)
}

// length returns the number of f32 values in the device buffer.
pub fn (v &VectorF32) length() int {
	return v.buf.size / int(sizeof(f32))
}

// buffer returns the underlying device buffer.
pub fn (v &VectorF32) buffer() &Buffer {
	return v.buf
}

// release releases the device buffer.
pub fn (v &VectorF32) release() ! {
	return v.buf.release()
}
