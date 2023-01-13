module vcl

// Vector is a memory buffer on device that holds []T
pub struct Vector[T] {
mut:
	buf &Buffer
}

// vector allocates new vector buffer with specified length
pub fn (d &Device) vector[T](length int) ?&Vector[T] {
	size := length * int(sizeof(T))
	buffer := d.buffer(size)?
	buf := &Buffer{
		memobj: buffer.memobj
		device: d
		size: size
	}
	return &Vector[T]{
		buf: buf
	}
}

// Length the length of the vector
pub fn (v &Vector[T]) length() int {
	return v.buf.size / int(sizeof(T))
}

// Release releases the buffer on the device
pub fn (v &Vector[T]) release() ? {
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
pub fn (v &Vector[T]) data() ?[]T {
	mut data := []T{len: int(v.buf.size / int(sizeof(T)))}
	ret := clEnqueueReadBuffer(v.buf.device.queue, v.buf.memobj, true, 0, v.buf.size,
		unsafe { &data[0] }, 0, unsafe { nil }, unsafe { nil })
	if ret != success {
		return vcl_error(ret)
	}
	return data
}

// map applies an map kernel on all elements of the vector
pub fn (v &Vector[T]) map(k &Kernel) chan IError {
	return k.global(v.length()).local(1).run(v)
}
